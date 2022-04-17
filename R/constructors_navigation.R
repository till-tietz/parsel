#' wrapper around remDr$mavigate to generate safe navigation code
#'
#' @param url a character string specifying the name of the variable holding the url string or the url string the function should navigate to.
#' @param prev a placeholder for the output of functions being piped into go(). Defaults to NULL and should not be altered.
#' @return a character string defining 'RSelenium' navigation instructions that can be pasted into a scraping function
#' @export
#'
#' @examples
#' \dontrun{
#'
#' go("https://www.wikipedia.org/")
#'
#' }


go <- function(url, prev = NULL){

  if(!is.character(url)){
    stop("url is not of type character")
  }

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

  out <- paste(not_loaded, navigate, while_loop, sep = "\n")

  if(!is.null(prev)){
    out <- paste(prev, out, sep = " \n \n ")
  }

  return(out)
}

#' wrapper around remDr$goBack to generate safe backwards navigation code
#'
#' @param prev a placeholder for the output of functions being piped into goback(). Defaults to NULL and should not be altered.
#' @return a character string defining 'RSelenium' backwards navigation instructions that can be pasted into a scraping function
#' @export
#'
#' @examples
#' \dontrun{
#'
#' goback()
#'
#' }

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

  out <- paste(not_returned, from, go_back, while_loop, sep = "\n")

  if(!is.null(prev)){
    out <- paste(prev, out, sep = " \n \n ")
  }

  return(out)
}



