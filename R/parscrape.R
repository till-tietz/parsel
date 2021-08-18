#' parallelize execution of RSelenium
#' @param scrape_fun a function with input x sending instructions to remDr (remote driver)/ scraping function to be parallelized
#' @param scrape_input a data frame, list, or vector where each element is an input to be passed to scrape_function
#' @param cores number of cores to run RSelenium instances on
#' @param packages a character vector with package names of packages used in scrape_function
#' @param browser a character vector specifying the browser to be used
#' @param ports vector of ports for RSelenium instances (if left at default NULL parscrape will randomly generate ports)
#' @param chunk_size number of scrape_input elements to be processed per round of scrape_function (parscrape splits scrape_input into chunks and runs scrape_function in multiple rounds to avoid loosing data due to errors). Defaults to number of cores.
#' @param scrape_tries sets number of times parscrape will re-try to scrape a chunk when encountering an error
#' @return list with output of scrape_fun in "scraped_results" and a vector of indices of scrape_input elements that could not be scraped in "not_scaped"
#' @export

parscrape <- function(scrape_fun, scrape_input, cores, packages = c("base"), browser, ports = NULL, chunk_size = NULL, scrape_tries = 2){

  if(missing(scrape_fun)){
    stop("missing scrape_fun")
  }

  if(!is.function(scrape_fun)){
    stop("scrape_fun is not a function")
  }

  if(missing(scrape_input)){
    stop("missing scrape_input")
  }

  if(missing(cores)){
    stop("missing cores")
  }

  if(missing(packages)){
    stop("missing packages")
  }

  if(missing(browser)){
    stop("missing browser")
  }

  if(missing(ports)){
    stop("missing ports")
  }

  if(missing(chunk_size)){
    stop("missing chunk_size")
  }

  if(missing(scrape_tries)){
    stop("missing scrape_tries")
  }

  if(is.null(ports)){
    ports <- sample(1000:9999, cores, replace = FALSE)
  }

  if(is.null(chunk_size)){
    chunk_size <- cores
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

  for(i in c(1:length(result_list))){
    chunk_i <- chunks[[i]]
    input_i <- scrape_input[chunk_i]
    n_tries <- 0
    while(TRUE){
      scrape_out <- try(parallel::parLapply(clust, input_i, scrape_fun), silent=TRUE)
      n_tries <- n_tries + 1
      if(!is(scrape_out, 'try-error')){
        print(paste(paste("chunk", i, sep = " "), "scraped", sep = " "))
        break
      }
      if(n_tries == scrape_tries){
        warning(paste(paste("parsel encountered the following ERROR while trying to scrape chunk", i, sep = " "), ":", sep = ""),
                scrape_out[1],
                "check under not_scraped of this function's output for the indices of elements in scrape_input that could not be
                scraped and may have caused the error")

        scrape_out <- "RSelenium ERROR"
        break
      }
    }
    result_list[[i]] <- scrape_out
  }

  if("RSelenium ERROR" %in% result_list){
    unscraped <- unlist(chunks[which(result_list == "RSelenium ERROR")])
    results <- result_list[-which(result_list == "RSelenium ERROR")]
  } else {
    unscraped <- NULL
    results <- result_list
  }

  results <- unlist(results, recursive = FALSE)
  return(list("scraped_results" = results, "not_scraped" = unscraped))

  close_rselenium()
  parallel::stopCluster(clust)
}



