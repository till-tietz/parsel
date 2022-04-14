#' pipe-like operator that pastes together the output of two functions
#'
#' @param lhs a function call returning a charater string
#' @param rhs a fuction call returning a character string which should be pasted to step_1
#' @return a character string of the pasted output of step_1 and step_2
#' @export
#'
#' @examples
#' \dontrun{
#'
#' go("https://www.wikipedia.org/") %>>%
#' goback()
#'
#' }



`%>>%` <- function(lhs,rhs){

  call_rhs <- as.list(substitute(rhs))
  f_rhs <- eval(call_rhs[[1]])

  all_args_rhs <- as.list(rlang::fn_fmls(f_rhs))
  call_rhs <- call_rhs[-1]

  if(all(names(call_rhs) != "")){

    rhs_out <- do.call(f_rhs, append(call_rhs, list(prev = lhs)))

  }
  return(rhs_out)
}




