#' wrapper for 'navigate'
#'
#' @export

go <- function(url, prev = NULL){

  not_loaded <- "not_loaded <- TRUE"

  navigate <- paste("remDr$navigate('",url,"')", sep = "")

  while_loop <- paste("while(not_loaded){",
                      "Sys.sleep(0.25)",
                      "current <- seleniumPipes::getCurrentUrl(remDr)",
                      paste("if(current == '",url,"'){", sep = ""),
                      "not_loaded <- FALSE",
                      "}",
                      "}",
                      sep = "\n")

  out <- list(paste(not_loaded, navigate, while_loop, sep = "\n"))

  if(is.null(prev)){
    return(out)
  } else {
    return(append(prev, out))
  }

}

#' wrapper for 'goBack'
#'
#' @export

goback <- function(prev = NULL){

  not_returned <- "not_returned <- TRUE"

  from <- "from <- seleniumPipes::getCurrentUrl(remDr)"

  go_back <- "remDr$goBack()"

  while_loop <- paste("while(not_returned){",
                      "Sys.sleep(0.25)",
                      "current <- seleniumPipes::getCurrentUrl(remDr)",
                      "if(current != from){",
                      "not_returned <- FALSE",
                      "}",
                      "}",
                      sep = "\n")

  out <- list(paste(not_returned, from, go_back, while_loop, sep = "\n"))

  if(is.null(prev)){
    return(out)
  } else {
    return(append(prev_out))
  }

}



