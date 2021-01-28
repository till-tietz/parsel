#' parallelize execution of RSelenium
#' @param scrape_function a function with input x sending instructions to remDr (remote driver)/ scraping function to be parallelized
#' @param scrape_input a data frame, list, or vector where each element is an input to be passed to scrape_function
#' @param cores number of cores to run RSelenium instances on
#' @param packages a character vector with package names of packages used in scrape_function
#' @param browser a character vector specifying the browser to be used
#' @param ports vector of ports for RSelenium instances (if left at default NULL parscrape will randomly generate ports)
#' @param chunk_size number of scrape_input elements to be processed per round of scrape_function (parscrape splits scrape_input into chunks and runs scrape_function in multiple rounds to avoid loosing data due to errors)
#' @return output of scrape_function
#' @export

parscrape <- function(scrape_fun, scrape_input, cores, packages, browser, ports = NULL, chunk_size = 10){

  if(is.null(ports)){
    ports <- sample(1000:9999, cores, replace = FALSE)
  }

  ports <- as.list(ports)

  clust <- parallel::makeCluster(cores)

  parallel::clusterApply(clust, ports, function(x){

    lapply(packages, require, character.only = TRUE)

    rD <<- RSelenium::rsDriver(
      browser = browser,
      port = x
    )

    remDr <<- rD[["client"]]
  })

  if(!is.list(scrape_input)){
    if(is.vector(scrape_input)){
      scrape_input <- split(scrape_input, seq(length(scrape_input)))
    }
  } else {
    if(is.data.frame(scrape_input)){
      scrape_input <- split(scrape_input, seq(nrow(scrape_input)))
    }
  }

  chunks <- split(c(1:length(scrape_input)), ceiling(seq_along(c(1:length(scrape_input)))/chunk_size))

  result_list <- vector(mode = "list", length = length(chunks))

  on.exit(close_rselenium())
  on.exit(parallel::stopCluster(clust))

  for(i in c(1:length(result_list))){
    chunk_i <- chunks[[i]]
    input_i <- scrape_input[chunk_i]
    while(TRUE){
      scrape_out <- try(parallel::parLapply(clust, input_i, scrape_fun), silent=TRUE)
      if(!is(scrape_out, 'try-error')) break
    }
    result_list[[i]] <- scrape_out
  }

  results <- unlist(result_list, recursive = FALSE)
  return(results)
}



