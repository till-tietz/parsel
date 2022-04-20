#' utility function to check for repeated and generate unique variable names
#'
#' @param input character string
#' @return  generated variable name as a character string
#' @keywords internal


gen_varname <- function(input){

  cont <- TRUE
  count <- 1

  while(cont){

    var <- paste("parsel_var", count, sep = "_")
    cont <- grepl(paste("\\b",var,"\\b", sep = ""), input)

    count <- count + 1

  }

  return(var)

}


#' wrapper around clickElement() method to generate safe scraping code
#'
#' @param using character string specifying locator scheme to use to search elements. Available schemes: "class name", "css selector", "id", "name", "link text", "partial link text", "tag name", "xpath".
#' @param value character string specifying the search target.
#' @param name character string specifying the object name the RSelenium "wElement" class object should be saved to.
#' @param prev a placeholder for the output of functions being piped into click(). Defaults to NULL and should not be altered.
#' @return a character string defining 'RSelenium' clicking instructions that can be pasted into a scraping function.
#' @export
#'
#' @examples
#' \dontrun{
#'
#' #navigate to wikipedia, click random article
#'
#' parsel::go("https://www.wikipedia.org/") %>>%
#' parsel::click(using = "id", value = "n-randompage") %>>%
#' show()
#'
#' }

click <- function(using, value, name = NULL, prev = NULL){

  if(!missing(using)){
    if(!is.character(using)){
      stop("using is not of type character")
    }
  }

  if(!missing(value)){
    if(!is.character(value)){
      stop("value is not of type character")
    }
  }

  if(!is.null(name)){
    if(!is.character(name)){
      stop("name is not of type character")
    }
  }

  if(is.null(name)){

    if(is.null(prev)){
      name <- gen_varname("")
    } else {
      name <- gen_varname(prev)
    }

  }

  finding <- paste(name, " <- ","remDr$findElement(using = '", using,"', '", value, "')", sep = "")
  clicking <- paste(name,"$clickElement()", sep = "")

  out <- paste(finding, clicking, sep = "\n")

  if(!is.null(prev)){
    out <- paste(prev, out, sep = " \n \n ")
  }

  return(out)

}




#' wrapper around sendKeysToElement() method to generate safe scraping code
#'
#' @param using character string specifying locator scheme to use to search elements. Available schemes: "class name", "css selector", "id", "name", "link text", "partial link text", "tag name", "xpath".
#' @param value character string specifying the search target.
#' @param name character string specifying the object name the RSelenium "wElement" class object should be saved to.If NULL a name will be generated automatically.
#' @param text a character vector specifying the text to be typed.
#' @param text_object a character string specifying the name of an external object holding the text to be typed. Note that the remDr$sendKeysToElement method only accepts list inputs.
#' @param prev a placeholder for the output of functions being piped into type(). Defaults to NULL and should not be altered.
#' @return a character string defining 'RSelenium' typing instructions that can be pasted into a scraping function.
#' @export
#'
#' @examples
#' \dontrun{
#'
#' #navigate to wikipedia, type "Hello" into the search box,  press enter
#'
#' parsel::go("https://www.wikipedia.org/") %>>%
#' parsel::type(using = "id",
#'              value = "searchInput",
#'              name = "searchbox",
#'              text = c("Hello","\uE007")) %>>%
#'              show()
#'
#' #navigate to wikipeda, type content stored in external object "x" into search box
#'
#' parsel::go("https://www.wikipedia.org/") %>>%
#' parsel::type(using = "id",
#'              value = "searchInput",
#'              name = "searchbox",
#'              text_object = "x") %>>%
#'              show()
#'
#' }

type <- function(using, value, name = NULL, text, text_object, prev = NULL){

  if(!missing(using)){
    if(!is.character(using)){
      stop("using is not of type character")
    }
  }

  if(!missing(value)){
    if(!is.character(value)){
      stop("value is not of type character")
    }
  }

  if(!is.null(name)){
    if(!is.character(name)){
      stop("name is not of type character")
    }
  }

  if(!missing(text) & !missing(text_object)){
    stop("please only define one of text or text_object")
  }


  if(!missing(text)){

    if(!is.character(text)){
      stop("text is not of type character")
    }

    text <- paste("'",text,"'", sep = "")

    if(length(text) > 1){
      text <- paste(text, collapse = ",")
    }

  }

  if(!missing(text_object)){

    if(length(text_object) > 1){
      stop("cannot define multiple text objects. please define a single text_object.")
    }

    if(!is.character(text_object)){
      stop("text_object is not of type character")
    }

  }

  defined <- which(c(!missing(text),!missing(text_object)))

  if(is.null(name)){

    if(is.null(prev)){
      name <- gen_varname("")
    } else {
      name <- gen_varname(prev)
    }

  }


  finding <- paste(name, " <- ","remDr$findElement(using = '", using,"', '", value, "')", sep = "")

  if(defined == 1){

    typing <- paste(name,"$sendKeysToElement(list(",text,"))", sep = "")

  } else {

    typing <- paste(name,"$sendKeysToElement(",text_object,")", sep = "")

  }

  out <- paste(finding, typing, sep = "\n")

  if(!is.null(prev)){
    out <- paste(prev, out, sep = " \n \n ")
  }

  return(out)

}


#' wrapper around getElementText() method to generate safe scraping code
#'
#' @param using character string specifying locator scheme to use to search elements. Available schemes: "class name", "css selector", "id", "name", "link text", "partial link text", "tag name", "xpath".
#' @param value character string specifying the search target.
#' @param name character string specifying the object name the RSelenium "wElement" class object should be saved to. If NULL a name will be generated automatically.
#' @param prev a placeholder for the output of functions being piped into get_element(). Defaults to NULL and should not be altered.
#' @return a character string defining 'RSelenium' getElementText() instructions that can be pasted into a scraping function.
#' @export
#'
#' @examples
#' \dontrun{
#'
#' #navigate to wikipedia, type "Hello" into the search box,
#' #press enter, get page header
#'
#' parsel::go("https://www.wikipedia.org/") %>>%
#' parsel::type(using = "id",
#'              value = "searchInput",
#'              name = "searchbox",
#'              text = c("Hello","\uE007")) %>>%
#' parsel::get_element(using = "id",
#'                     value = "firstHeading",
#'                     name = "header") %>>%
#'             show()
#'
#' #navigate to wikipedia, type "Hello" into the search box, press enter,
#' #get page header, save in external data.frame x.
#'
#' parsel::go("https://www.wikipedia.org/") %>>%
#' parsel::type(using = "id",
#'              value = "searchInput",
#'              name = "searchbox",
#'              text = c("Hello","\uE007")) %>>%
#' parsel::get_element(using = "id",
#'                     value = "firstHeading",
#'                     name = "x[,1]") %>>%
#'                     show()
#'
#' }

get_elemnt <- function(using, value, name = NULL, prev = NULL){

  if(!missing(using)){
    if(!is.character(using)){
      stop("using is not of type character")
    }
  }

  if(!missing(value)){
    if(!is.character(value)){
      stop("value is not of type character")
    }
  }

  if(!is.null(name)){
    if(!is.character(name)){
      stop("name is not of type character")
    }
  }

  if(is.null(name)){

    if(is.null(prev)){
      name <- gen_varname("")
    } else {
      name <- gen_varname(prev)
    }

  }

  finding <- paste(name, " <- ", "try(", "remDr$findElement(using = '", using,"', '", value, "')", ")", sep = "")

  out <- paste(finding,
               paste("if(is(", name, ",'try-error')){", sep = ""),
               paste(name, " <- NA", sep = ""),
               "} else {",
               paste(name, " <- ", name,"$getElementText()", sep = ""),
               "}",
               sep = " \n")

  if(!is.null(prev)){
    out <- paste(prev, out, sep = " \n \n ")
  }

  return(out)

}

