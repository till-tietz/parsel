#' pipe-like operator that passes the ouput of lhs to the prev argument of rhs to paste together a scraper function in sequence.
#'
#' @param lhs a parsel constructor function call
#' @param rhs a parsel constructor fuction call that should accept lhs as its prev argument
#' @return the output of rhs evaluated with lhs as the prev argument
#' @export
#'
#' @examples
#' \dontrun{
#'
#' #paste together the go and goback output in sequence
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

  } else {

    to_name <- which(names(call_rhs) == "")
    names(call_rhs)[to_name] <- names(all_args_rhs)[to_name]

    rhs_out <- do.call(f_rhs, append(call_rhs, list(prev = lhs)))

  }

  return(rhs_out)
}




