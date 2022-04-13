#' wrapper around \code{RSelenium remDr$mavigate} to generate safe navigation code
#'
#'|@param url a character string specifying the name of the variable holding the url string or the url string the function should navigate to.
#' @return a character string defining 'RSelenium' navigation instructions that can be pasted into a scraping function
#' @export
#'
#' @examples
#'
#' go("https://www.wikipedia.org/")


go <- function(url){

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



  return(out)
}

#' wrapper around \code{RSelenium remDr$goBack} to generate safe backwards navigation code
#'
#' @return a character string defining 'RSelenium' backwards navigation instructions that can be pasted into a scraping function
#' @export
#'
#' @examples
#'
#' goback()

goback <- function(){

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

  return(out)
}








