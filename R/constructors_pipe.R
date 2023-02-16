#' pipe-like operator that passes the output of lhs to the prev argument of rhs to paste together a scraper function in sequence.
#'
#' @param lhs a parsel constructor function call
#' @param rhs a parsel constructor function call that should accept lhs as its prev argument
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
  f_rhs_name <- as.character(call_rhs[[1]])
  f_rhs_name <- f_rhs_name[!f_rhs_name %in% c("::","parsel")]

  all_args_rhs <- as.list(
    rlang::fn_fmls(base::get(f_rhs_name, envir = as.environment("package:parsel")))
    )

  if(!"prev" %in% names(all_args_rhs)) {
    stop(paste("cannot pipe into", f_rhs_name, "as it does not have a 'prev' argument.", sep = " "))
  }

  all_args_rhs <- all_args_rhs[-which(names(all_args_rhs) == "prev")]

  call_rhs <- call_rhs[-1]

  if(f_rhs_name == "show"){

    do.call(f_rhs, append(call_rhs, list(prev = lhs)))

  } else {

    if(is.null(names(call_rhs))){

      names(call_rhs) <- names(all_args_rhs)

    } else if(sum(names(call_rhs) == "") > 0){

      to_name <- which(names(call_rhs) == "")
      names(call_rhs)[to_name] <- names(all_args_rhs)[to_name]

    }

    rhs_out <- do.call(f_rhs, append(call_rhs, list(prev = lhs)))

    return(rhs_out)

  }

}






