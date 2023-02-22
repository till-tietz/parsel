
<!-- README.md is generated from README.Rmd. Please edit that file -->

# parsel

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/parsel)](https://CRAN.R-project.org/package=parsel)
[![License:
MIT](https://img.shields.io/badge/License-MIT-orange.svg)](https://opensource.org/license/mit/)
![](https://cranlogs.r-pkg.org/badges/grand-total/parsel?color)
<!-- badges: end -->

`parsel` is a framework for parallelized dynamic web-scraping using
`RSelenium`. Leveraging parallel processing, it allows you to run any
`RSelenium` web-scraping routine on multiple browser instances
simultaneously, thus greatly increasing the efficiency of your scraping.
`parsel` utilizes chunked input processing as well as error catching and
logging, to ensure seamless execution of your scraping routine and
minimal data loss, even in the presence of unforeseen `RSelenium`
errors. `parsel` additionally provides convenient wrapper functions
around `RSelenium` methods, that allow you to quickly generate safe
scraping code with minimal coding on your end.

## Installation

``` r
# Install parsel from CRAN
install.packages("parsel")

# Or the development version from GitHub:
# install.packages("devtools")
devtools::install_github("till-tietz/parsel")
```

## Usage

### Parallel Scraping

The following example will hopefully serve to illustrate the
functionality and ideas behind how `parsel` operates. We’ll set up the
following scraping job:

1.  navigate to a random Wikipedia article
2.  retrieve its title
3.  navigate to the first linked page on the article
4.  retrieve the linked page’s title and first section

and parallelize it with `parsel`.

`parsel` requires two things:

1.  a scraping function defining the actions to be executed in each
    `RSelenium` instance. Actions to be executed in each browser
    instance should be written in the conventional `RSelenium` syntax
    with `remDr$` specifying the remote driver.  
2.  some input `x` to those actions (e.g. search terms to be entered in
    search boxes or links to navigate to etc.)

``` r
library(RSelenium)
library(parsel)

#let's define our scraping function input 
#we want to run our function 4 times and we want it to start on the wikipedia main page each time 
input <- rep("https://de.wikipedia.org",4)

#let's define our scraping function 

get_wiki_text <- function(x){
  input_i <- x
  
  #navigate to input page (i.e wikipedia)
  remDr$navigate(input_i)
  
  #find and click random article 
  rand_art <- remDr$findElement(using = "id", "n-randompage")$clickElement()
  
  #get random article title 
  title <- remDr$findElement(using = "id", "firstHeading")$getElementText()[[1]]
  
  #check if there is a linked page
  link_exists <- try(remDr$findElement(using = "xpath", "/html/body/div[3]/div[3]/div[5]/div[1]/p[1]/a[1]"))
  
  #if no linked page fill output with NA
  if(is(link_exists,"try-error")){
    first_link_title <- NA
    first_link_text <- NA
    
    #if there is a linked page
  } else {
    #click on link
    link <- remDr$findElement(using = "xpath", "/html/body/div[3]/div[3]/div[5]/div[1]/p[1]/a[1]")$clickElement()
    
    #get link page title
    first_link_title <- try(remDr$findElement(using = "id", "firstHeading"))
    if(is(first_link_title,"try-error")){
      first_link_title <- NA
    }else{
      first_link_title <- first_link_title$getElementText()[[1]]
    }
    
    #get 1st section of link page
    first_link_text <- try(remDr$findElement(using = "xpath", "/html/body/div[3]/div[3]/div[5]/div[1]/p[1]"))
    if(is(first_link_text,"try-error")){
      first_link_text <- NA
    }else{
      first_link_text <- first_link_text$getElementText()[[1]]
    }
  }
  out <- data.frame("random_article" = title,
                    "first_link_title" = first_link_title,
                    "first_link_text" = first_link_text)
  return(out)
}
```

Now that we have our scrape function and input we can parallelize the
execution of the function. For speed and efficiency reasons, it is
advisable to specify the headless browser option in the
`extraCapabilities` argument. `parscrape` will show a progress bar, as
well as elapsed and estimated remaining time so you can keep track of
scraping progress.

``` r
wiki_text <- parsel::parscrape(scrape_fun = get_wiki_text,
                               scrape_input = input,
                               cores = 2,
                               packages = c("RSelenium","XML"),
                               browser = "firefox",
                               scrape_tries = 1,
                               extraCapabilities = list(
                                     "moz:firefoxOptions" = list(args = list('--headless'))
                                     ))
```

`parscrape` returns a list with two elements:

1.  a list of your scrape function output
2.  a data.frame of inputs it was unable to scrape, and the associated
    error messages

### RSelenium Constructors

`parsel` allows you to generate safe scraping code with minimal hassle
by simply composing `constructor` functions that effectively act as
wrappers around `RSelenium` methods in a pipe. You can return a scraper
function defined by `constructors` to the environment by starting your
pipe with `start_scraper()` and ending it with `build_scraper()`.
Alternatively you can dump the code generated by your `constructor` pipe
to the console via `show()`. We’ll reproduce a slightly stripped down
version of the `RSelenium` code in the above wikipedia scraping routine
via the `parsel` `constructor` functions.

``` r
library(parsel)

# returning a scaper function 
start_scraper(args = "x", name = "get_wiki_text") %>>%
  click(using = "id", value = "'n-randompage'", name = "rand_art") %>>%
  get_element(using = "id", value = "'firstHeading'", name = "title") %>>%
  click(using = "xpath", value = "'/html/body/div[3]/div[3]/div[5]/div[1]/p[1]/a[1]'", name = "link") %>>%
  get_element(using = "id", value = "'firstHeading'", name = "first_link_title") %>>%
  get_element(using = "xpath", value = "'/html/body/div[3]/div[3]/div[5]/div[1]/p[1]'", name = "first_link_text") %>>%
  build_scraper()
#> [1] "scraping function get_wiki_text constructed and in environment"
#> [1] "scraping function get_wiki_text constructed and in environment"

ls()  
#> [1] "get_wiki_text"

# dumping generated code to console 
go(url = "x") %>>%
  click(using = "id", value = "'n-randompage'", name = "rand_art") %>>%
  get_element(using = "id", value = "'firstHeading'", name = "title") %>>%
  click(using = "xpath", value = "'/html/body/div[3]/div[3]/div[5]/div[1]/p[1]/a[1]'", name = "link") %>>%
  get_element(using = "id", value = "'firstHeading'", name = "first_link_title") %>>%
  get_element(using = "xpath", value = "'/html/body/div[3]/div[3]/div[5]/div[1]/p[1]'", name = "first_link_text") %>>%
  show()
#> # navigate to url
#> not_loaded <- TRUE
#> remDr$navigate(x)
#> while(not_loaded){
#> Sys.sleep(0.25)
#> current <- remDr$getCurrentUrl()[[1]]
#> if(current == x){
#> not_loaded <- FALSE
#> }
#> } 
#>  
#>  rand_art <- remDr$findElement(using = 'id', 'n-randompage')
#> rand_art$clickElement()
#> Sys.sleep(0.25) 
#>  
#>  title <- try(remDr$findElement(using = 'id', 'firstHeading')) 
#> if(is(title,'try-error')){ 
#> title <- NA 
#> } else { 
#> title <- title$getElementText()[[1]] 
#> } 
#>  
#>  link <- remDr$findElement(using = 'xpath', '/html/body/div[3]/div[3]/div[5]/div[1]/p[1]/a[1]')
#> link$clickElement()
#> Sys.sleep(0.25) 
#>  
#>  first_link_title <- try(remDr$findElement(using = 'id', 'firstHeading')) 
#> if(is(first_link_title,'try-error')){ 
#> first_link_title <- NA 
#> } else { 
#> first_link_title <- first_link_title$getElementText()[[1]] 
#> } 
#>  
#>  first_link_text <- try(remDr$findElement(using = 'xpath', '/html/body/div[3]/div[3]/div[5]/div[1]/p[1]')) 
#> if(is(first_link_text,'try-error')){ 
#> first_link_text <- NA 
#> } else { 
#> first_link_text <- first_link_text$getElementText()[[1]] 
#> }
```
