#' pipe-like operator that pastes together the output of two functions
#'
#' @param step_1 a function call returning a charater string
#' @param step_2 a fuction call returning a character string which should be pasted to \code{step_1}
#' @return a character string of the pasted output of \code{step_1} and \code{step_2}
#' @export
#'
#' @examples
#'
#' go("https://www.wikipedia.org/") %>>%
#' goback()

`%>>%` <- function(step_1, step_2){
  return(paste(step_1,step_2, sep = " \n \n "))
}



