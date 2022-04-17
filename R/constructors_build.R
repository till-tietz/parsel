#' renders the output of the piped functions to the console via cat()
#'
#' @param prev a placeholder for the output of functions being piped into show(). Defaults to NULL and should not be altered.
#' @return None (invisible NULL)
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
