#' parallelize execution of RSelenium
#'
#' @param scrape_fun a function with input x sending instructions to remDr (remote driver)/ scraping function to be parallelized
#' @param scrape_input a data frame, list, or vector where each element is an input to be passed to scrape_fun
#' @param cores number of cores to run RSelenium instances on. Defaults to available cores - 1.
#' @param packages a character vector with package names of packages used in scrape_fun
#' @param browser a character vector specifying the browser to be used
#' @param ports vector of ports for RSelenium instances. If left at default NULL parscrape will randomly generate ports.
#' @param chunk_size number of scrape_input elements to be processed per round of scrape_fun. parscrape splits scrape_input into chunks and runs scrape_fun in multiple rounds to avoid loosing data due to errors. Defaults to number of cores.
#' @param scrape_tries number of times parscrape will re-try to scrape a chunk when encountering an error
#' @param proxy a proxy setting function that runs before scraping each chunk
#' @param extraCapabilities a list of extraCapabilities options to be passed to rsDriver
#' @return a list containing the elements: scraped_results and not_scraped. scraped_results is a list containing the output of scrape_fun. If there are no unscraped input elements then not_scraped is NULL. If there are unscraped elements not_scraped is a data.frame containing the scrape_input id, chunk id and associated error of all unscraped input elements.
#' @export
#'
#' @examples
#' \dontrun{
#'input <- c(".central-textlogo__image",".central-textlogo__image")
#'
#'scrape_fun <- function(x){
#'  input_i <- x
#'  remDr$navigate("https://www.wikipedia.org/")
#'  element <- remDr$findElement(using = "css", input_i)
#'  element <- element$getElementText()
#'  return(element)
#'}
#'
#'parsel_out <- parscrape(scrape_fun = scrape_fun,
#'                        scrape_input = input,
#'                        cores = 2,
#'                        packages = c("RSelenium"),
#'                        browser = "firefox",
#'                        scrape_tries = 1,
#'                        chunk_size = 2,
#'                        extraCapabilities = list(
#'                         "moz:firefoxOptions" = list(args = list('--headless'))
#'                         )
#'                        )
#'}


parscrape <- function(scrape_fun,
                      scrape_input,
                      cores = NULL,
                      packages = c("base"),
                      browser,
                      ports = NULL,
                      chunk_size = NULL,
                      scrape_tries = 1,
                      proxy = NULL,
                      extraCapabilities = list()) {


  if(!is.function(scrape_fun)){
    stop("scrape_fun is not a function")
  }

  if(is.null(cores)){
    cores <- parallel::detectCores() - 1
  } else if(!is.numeric(cores)){
    stop("cores is not numeric")
  }

  if(!is.character(packages)){
    stop("packages is not character")
  }

  if (!is.character(browser)) {
    stop("browser is not character")
  }

  if(is.null(ports)){
    ports <- sample(1000:9999, cores, replace = FALSE)
  } else if(!is.numeric(ports)){
    stop("ports is not numeric")
  } else if(length(ports) != cores){
    stop("mismatch between number of ports and cores: please specify a unique port for each core you wish to run")
  }

  if(is.null(chunk_size)){
    chunk_size <- cores
  } else if(!is.numeric(chunk_size)){
    stop("chunk size is not numeric")
  }

  if(!is.numeric(scrape_tries)){
    stop("scrape_tries not numeric")
  }

  if(!is.null(proxy) & !is.function(proxy)){
    stop("proxy is not a function")
  }

  if(!is.list(extraCapabilities)){
    stop("extraCapabilities is not a list")
  }

  ports <- as.list(ports)

  pos <- 1
  envir <- as.environment(pos)

  clust <- parallel::makeCluster(cores)

  parallel::clusterApply(clust, ports, function(x) {
    lapply(packages, require, character.only = TRUE)

    assign("rD", RSelenium::rsDriver(browser = browser, port = x,
                                     extraCapabilities = extraCapabilities),
           envir = envir)

    assign("remDr", rD[["client"]],
           envir = envir)
  })

  if (!is.list(scrape_input)) {
    if (is.vector(scrape_input)) {
      scrape_input <- split(scrape_input, seq(length(scrape_input)))
    }
  } else {
    if (is.data.frame(scrape_input)) {
      scrape_input <- split(scrape_input, seq(nrow(scrape_input)))
    }
  }

  chunks <- split(c(1:length(scrape_input)), ceiling(seq_along(c(1:length(scrape_input))) / chunk_size))

  result_list <- vector(mode = "list", length = length(chunks))
  error_list <- vector(mode = "list", length = length(chunks))
  lres <- length(result_list)

  pb <- txtProgressBar(
    min = 0, max = lres, style = 3,
    width = lres, char = "="
  )

  init <- numeric(lres)
  end <- numeric(lres)

  for (i in c(1:length(result_list))) {
    init[i] <- Sys.time()

    if (!is.null(proxy)) {
      proxy()
    }

    chunk_i <- chunks[[i]]
    input_i <- scrape_input[chunk_i]
    n_tries <- 0

    while (TRUE) {
      scrape_out <- try(parallel::parLapply(clust, input_i, scrape_fun), silent = TRUE)
      n_tries <- n_tries + 1
      if (!is(scrape_out, "try-error")) {
        break
      }
      if (n_tries == scrape_tries) {

        error_list[[i]] <- gsub("\t","",gsub("\n","",scrape_out))
        scrape_out <- NULL
        break

      }
    }

    result_list[[i]] <- scrape_out
    end[i] <- Sys.time()
    setTxtProgressBar(pb, i)

    time <- round(lubridate::seconds_to_period(sum(end - init)), 0)
    est <- lres * (mean(end[end != 0] - init[init != 0])) - time
    remainining <- round(lubridate::seconds_to_period(est), 0)

    cat(paste(
      " // Execution time:", time,
      " // Estimated time remaining:", remainining
    ), "")
  }

  close(pb)

  unscraped_chunks <- which(!sapply(error_list,is.null))

  if(length(unscraped_chunks) > 0){

    element_input_id <- unlist(chunks[unscraped_chunks])
    n_elements <- length(element_input_id)

    unscraped <- data.frame(
      element_input_id = element_input_id,
      element_chunk = rep(unscraped_chunks, each = chunk_size)[1:n_elements],
      error = rep(unlist(error_list), each = chunk_size)[1:n_elements]
    )

    warning("parscrape could not scrape certain elements. Check under not_scraped in the function output for element ids and errors.")

  } else {
    unscraped <- NULL
  }

  results <- unlist(purrr::compact(result_list), recursive = FALSE)
  return(list("scraped_results" = results, "not_scraped" = unscraped))

  close_rselenium(clust = clust)
  parallel::stopCluster(clust)
}
