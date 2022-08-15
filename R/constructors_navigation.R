#' wrapper around remDr$navigate method to generate safe navigation code
#'
#' @param url a character string specifying the name of the object holding the url string or the url string the function should navigate to.
#' @param prev a placeholder for the output of functions being piped into go(). Defaults to NULL and should not be altered.
#' @return a character string defining 'RSelenium' navigation instructions that can be pasted into a scraping function
#' @export
#'
#' @examples
#' \dontrun{
#'
#' go("https://www.wikipedia.org/") %>>%
#' show()
#'
#' }


go <- function(url, prev = NULL){

  if(!is.character(url)){
    stop("url is not of type character")
  }

  not_loaded <- "not_loaded <- TRUE"

  navigate <- paste("remDr$navigate(",url,")", sep = "")

  while_loop <- paste("while(not_loaded){",
                      "Sys.sleep(0.25)",
                      "current <- remDr$getCurrentUrl()[[1]]",
                      paste("if(current == ",url,"){", sep = ""),
                      "not_loaded <- FALSE",
                      "}",
                      "}",
                      sep = "\n")

  out <- paste("# navigate to url", not_loaded, navigate, while_loop, sep = "\n")

  if(!is.null(prev)){
    out <- paste(prev, out, sep = " \n \n ")
  }

  return(out)
}

#' wrapper around remDr$goBack method to generate safe backwards navigation code
#'
#' @param prev a placeholder for the output of functions being piped into goback(). Defaults to NULL and should not be altered.
#' @return a character string defining 'RSelenium' backwards navigation instructions that can be pasted into a scraping function
#' @export
#'
#' @examples
#' \dontrun{
#'
#' goback() %>>%
#' show()
#'
#' }

goback <- function(prev = NULL){

  not_returned <- "not_returned <- TRUE"

  from <- "from <- seleniumPipes::getCurrentUrl(remDr)"

  go_back <- "remDr$goBack()"

  while_loop <- paste("while(not_returned){",
                      "Sys.sleep(0.25)",
                      "current <- remDr$getCurrentUrl()[[1]]",
                      "if(current != from){",
                      "not_returned <- FALSE",
                      "}",
                      "}",
                      sep = "\n")

  out <- paste("# navigate back to previous url", not_returned, from, go_back, while_loop, sep = "\n")

  if(!is.null(prev)){
    out <- paste(prev, out, sep = " \n \n ")
  }

  return(out)
}


#' wrapper around remDr$goForward method to generate safe forwards navigation code
#'
#' @param prev a placeholder for the output of functions being piped into goforward(). Defaults to NULL and should not be altered.
#' @return a character string defining 'RSelenium' forward navigation instructions that can be pasted into a scraping function.
#' @export
#'
#' @examples
#' \dontrun{
#'
#' goforward() %>>%
#' show()
#'
#' }

goforward <- function(prev = NULL){

  not_forward <- "not_forward <- TRUE"

  from <- "from <- remDr$getCurrentUrl()[[1]]"

  go_forward <- "remDr$goForward()"

  while_loop <- paste("while(not_forward){",
                      "Sys.sleep(0.25)",
                      "current <- remDr$getCurrentUrl()[[1]]",
                      "if(current != from){",
                      "not_forward <- FALSE",
                      "}",
                      "}",
                      sep = "\n")

  out <- paste("# navigate forward to new url", not_forward, from, go_forward, while_loop, sep = "\n")

  if(!is.null(prev)){
    out <- paste(prev, out, sep = " \n \n ")
  }

  return(out)
}
