#' renders the output of the piped functions to the console via cat()
#'
#' @param prev a placeholder for the output of functions being piped into show(). Defaults to NULL and should not be altered.
#' @return None (invisible NULL)
#' @export
#'
#' @examples
#' \dontrun{
#'
#' go("https://www.wikipedia.org/") %>>%
#' goback() %>>%
#' show()
#'
#' }

show <- function(prev = NULL){

  if(!is.null(prev)){
    cat(prev, fill = FALSE)
  } else {
    stop("no function to show")
  }

}


#' sets function name and arguments of scraping function
#'
#' @param args a character vector of function arguments
#' @param name character string specifying the object name of the scraping function. If NULL defaults to 'scraper'
#' @return a character string starting a function definition
#' @export
#'
#' @examples
#' \dontrun{
#'
#' start_scraper(args = c("x","y"), name = "fun")
#'
#' }

start_scraper <- function(args, name = NULL) {

  if(!is.character(args)) {
    stop("args is not of type character")
  } else {
    args <- paste(args, collapse = ", ")
  }

  if(!is.null(name)) {
    if(!is.character(name)) {
      stop("name is not of type character")
    }
  } else {
    name <- "scraper"
  }

  out <- paste("$$PARSELFUNCTIONCALLSTART$$ ",name, " <- function(", args, ") { \n ", "$$PARSELFUNCTIONCALLEND$$",sep = "")

  return(out)

}


#' generates the scraping function defined by start_scraper and other constructors in your environment
#'
#' @param prev a placeholder for the output of functions being piped into show(). Defaults to NULL and should not be altered.
#' @return a function
#' @export
#'
#' @examples
#' \dontrun{
#'
#' start_scraper(args = c("x"), name = "fun") %>>%
#' go("x") %>>%
#' build_scraper()
#'
#'
#' }

build_scraper <- function(prev = NULL) {

  if(!is.null(prev)){
    call_start <- gregexpr("\\$\\$PARSELFUNCTIONCALLSTART\\$\\$", prev)[[1]]
    call_end <- gregexpr("\\$\\$PARSELFUNCTIONCALLEND\\$\\$", prev)[[1]]

    if(call_start[1] == -1 & call_end[1] == -1) {
      stop("cannot call build_scraper without initially calling start_scraper at the beginning of your constructor pipe")
    } else {
      prev <- gsub("\\$\\$PARSELFUNCTIONCALLSTART\\$\\$","",prev)
      prev <- gsub("\\$\\$PARSELFUNCTIONCALLEND\\$\\$","",prev)

      call <- paste(trimws(sub("^[^<-]*<-", "", prev)), "}", sep = "\n")
      name <- trimws(sub("<-.*", "", prev))

      pos <- 1
      envir <- as.environment(pos)
      assign(name, eval(parse(text = call)), envir = envir)
      print(paste("scraping function", name, "constructed and in environment", sep = " "))
    }
  } else {
    stop("no function to build")
  }
}
