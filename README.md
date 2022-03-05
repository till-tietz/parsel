
<!-- README.md is generated from README.Rmd. Please edit that file -->

# parsel

<!-- badges: start -->

[![R-CMD-check](https://github.com/till-tietz/parsel/workflows/R-CMD-check/badge.svg)](https://github.com/till-tietz/parsel/actions)
<!-- badges: end -->

`parsel` is a framework for parallel execution of RSelenium. It allows
you to easily and conveniently run multiple RSelenium browsers
simultaneously to speed up your dynamic web scraping jobs.

## Installation

You can install the development version of `parsel` from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("till-tietz/parsel")
```

## Example

The following toy example will hopefully serve to illustrate the
functions and ideas behind how `parsel` operates. We’ll set up the
following scraping job:

1.  navigate to a random wikipedia article
2.  retrieve its title
3.  navigate to the first linked page on the article
4.  retrieve the linked page’s title and first section

and parallelize it with `parsel`.

`parsel` requires two things:

1.  some scraping function defining the actions to be executed in each
    RSelenium instance
2.  some input to those actions (e.g. search terms to be entered in
    search boxes or links to navigate to etc.)

<!-- end list -->

``` r
library(RSelenium)
library(parsel)

#let's define our scraping function input 
#we want to run our function 20 times and we want it to start on the wikipedia main page each time 
#(we obviously don't have to start from the main page each time but let's run with this for illustrative purposes)

input <- rep("https://de.wikipedia.org",20)

#let's define our scraping function 

get_wiki_text <- function(x){
  input_i <- x
  
  #navigate to input page (i.e wikipedia)
  remDr$navigate(input_i)
  
  #find and click random article 
  rand_art <- remDr$findElement(using = "xpath", "/html/body/div[5]/div[2]/nav[1]/div/ul/li[3]/a")
  rand_art$clickElement()
  
  #get random article title 
  title <- remDr$findElement(using = "id", "firstHeading")
  title <- title$getElementText()[[1]]
  
  #check if there is a linked page
  link_exists <- try(remDr$findElement(using = "xpath", "/html/body/div[3]/div[3]/div[5]/div[1]/p[1]/a[1]"))
  
  #if no linked page fill output with NA
  if(is(link_exists,"try-error")){
    first_link_title <- NA
    first_link_text <- NA
  
  #if there is a linked page
  } else {
    #click on link
    link <- remDr$findElement(using = "xpath", "/html/body/div[3]/div[3]/div[5]/div[1]/p[1]/a[1]")
    link$clickElement()
    
    #get link page title
    title_exists <- try(remDr$findElement(using = "id", "firstHeading"))
    if(is(title_exists,"try-error")){
      first_link_title <- NA
    }else{
      first_link_title <- remDr$findElement(using = "id", "firstHeading")
      first_link_title <- first_link_title$getElementText()[[1]]
    }
    
    #get 1st section of link page
    text_exists <- try(remDr$findElement(using = "xpath", "/html/body/div[3]/div[3]/div[5]/div[1]/p[1]"))
    if(is(text_exists,"try-error")){
      first_link_text <- NA
    }else{
      first_link_text <- remDr$findElement(using = "xpath", "/html/body/div[3]/div[3]/div[5]/div[1]/p[1]")
      first_link_text <- first_link_text$getElementText()[[1]]
    }
  }
  out <- data.frame("random_article" = title,
                    "first_link_title" = first_link_title,
                    "first_link_text" = first_link_text)
  return(out)
}
```

Now that we have our scrape function + input we can parallelize the
execution of the function. parscrape will show a progress bar, as well
as elapsed and estimated remaining time indicators so you can keep track
of scraping progress.

``` r
wiki_text <- parsel::parscrape(scrape_fun = get_wiki_text,
                               scrape_input = input,
                               cores = 4,
                               packages = c("RSelenium","XML"),
                               browser = "firefox",
                               scrape_tries = 1)
```

parsel returns a list with two elements:

1.  a list of your scrape function output
2.  a list of elements it was unable to scrape

<!-- end list -->

``` r
str(wiki_text[["scraped_results"]])
#> List of 20
#>  $ 1 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Wat Rachathiwat"
#>   ..$ first_link_title: chr "Thailändische Sprache"
#>   ..$ first_link_text : chr "Die thailändische Sprache (das Thai, <U+0E20><U+0E32><U+0E29><U+0E32><U+0E44><U+0E17><U+0E22> – gesprochen: [p<"| __truncated__
#>  $ 2 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Michel Graeff"
#>   ..$ first_link_title: chr "11. März"
#>   ..$ first_link_text : chr "Der 11. März ist der 70. Tag des gregorianischen Kalenders (der 71. in Schaltjahren), somit bleiben 295 Tage bi"| __truncated__
#>  $ 3 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Martin Hackleman"
#>   ..$ first_link_title: chr "1952"
#>   ..$ first_link_text : chr "Das Jahr 1952 war geprägt von dem weiterhin andauernden Koreakrieg. In Europa wird mit der Montanunion die Grun"| __truncated__
#>  $ 4 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Cela (Angola)"
#>   ..$ first_link_title: chr "Angola"
#>   ..$ first_link_text : chr "Angola (deutsch [a<U+014B>'go<U+02D0>la], portugiesisch [<U+0250><U+014B>'g<U+0254>l<U+0250>]; auf Kimbundu, Um"| __truncated__
#>  $ 5 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Yamatanoorochi"
#>   ..$ first_link_title: chr "Kojiki"
#>   ..$ first_link_text : chr "Das Kojiki (jap. <U+53E4><U+4E8B><U+8A18>, dt. „Aufzeichnung alter Geschehnisse“), selten auch in Kun-Lesung Fu"| __truncated__
#>  $ 6 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Helmut Reuter"
#>   ..$ first_link_title: chr "9. August"
#>   ..$ first_link_text : chr "Der 9. August ist der 221. Tag des gregorianischen Kalenders (der 222. in Schaltjahren), somit bleiben 144 Tage"| __truncated__
#>  $ 7 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Nekrolog 1482"
#>   ..$ first_link_title: logi NA
#>   ..$ first_link_text : logi NA
#>  $ 8 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Unified Memory Architecture"
#>   ..$ first_link_title: chr "Prozessor"
#>   ..$ first_link_text : chr ""
#>  $ 9 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Alexandre Emery"
#>   ..$ first_link_title: chr "9. März"
#>   ..$ first_link_text : chr "Der 9. März ist der 68. Tag des gregorianischen Kalenders (der 69. in Schaltjahren), somit bleiben 297 Tage bis"| __truncated__
#>  $ 10:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Split"
#>   ..$ first_link_title: chr "Kroatien"
#>   ..$ first_link_text : chr "Kroatien (kroatisch Hrvatska?/i [xr<U+0329><U+028B>a<U+02D0>tska<U+02D0>], amtlich Republik Kroatien, kroatisch"| __truncated__
#>  $ 11:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Kreis Kalocsa"
#>   ..$ first_link_title: chr "Komitat Bács-Kiskun"
#>   ..$ first_link_text : chr "Bács-Kiskun ['ba<U+02D0><U+02A7> 'ki<U+0283>kun] ist ein Komitat (Verwaltungsbezirk) in Südungarn. Es grenzt an"| __truncated__
#>  $ 12:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Salomon David Steinberg"
#>   ..$ first_link_title: chr "25. Juni"
#>   ..$ first_link_text : chr "Der 25. Juni ist der 176. Tag des gregorianischen Kalenders (der 177. in Schaltjahren), somit verbleiben noch 1"| __truncated__
#>  $ 13:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Somewhere in My Memory"
#>   ..$ first_link_title: chr "John Williams (Komponist)"
#>   ..$ first_link_text : chr "John Towner Williams (* 8. Februar 1932 in Flushing, Queens, New York City, New York) ist ein US-amerikanischer"| __truncated__
#>  $ 14:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Landkreis Bitterfeld (Provinz Sachsen)"
#>   ..$ first_link_title: chr "Landkreis"
#>   ..$ first_link_text : chr "Ein Landkreis (abgekürzt: Lk, Lkr, Lkrs oder Landkrs.) oder Kreis (abgekürzt: Kr) ist nach deutschem Kommunalre"| __truncated__
#>  $ 15:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Maria Collm"
#>   ..$ first_link_title: chr "2. Juli"
#>   ..$ first_link_text : chr "Der 2. Juli ist der 183. Tag des gregorianischen Kalenders (der 184. in Schaltjahren), somit bleiben 182 Tage b"| __truncated__
#>  $ 16:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "FSV Oppenheim"
#>   ..$ first_link_title: chr "Oppenheim"
#>   ..$ first_link_text : chr "Oppenheim ist eine Stadt am Oberrhein im Landkreis Mainz-Bingen, Rheinland-Pfalz. Sie ist Verwaltungssitz der V"| __truncated__
#>  $ 17:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Leo Weber (Politiker)"
#>   ..$ first_link_title: chr "24. Juni"
#>   ..$ first_link_text : chr "Der 24. Juni ist der 175. Tag des gregorianischen Kalenders (der 176. in Schaltjahren), somit verbleiben noch 1"| __truncated__
#>  $ 18:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Ture (Name)"
#>   ..$ first_link_title: chr "Nordgermanische Sprachen"
#>   ..$ first_link_text : chr "Die nordgermanischen Sprachen (auch skandinavische oder nordische Sprachen genannt) umfassen die Sprachen Islän"| __truncated__
#>  $ 19:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Palais Minucci"
#>   ..$ first_link_title: chr "Palast"
#>   ..$ first_link_text : chr "Ein Palast ist ein in einer Stadt erbauter, schlossähnlicher und repräsentativer Prachtbau. Der Begriff „Palast"| __truncated__
#>  $ 20:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Piers Sellers"
#>   ..$ first_link_title: chr "11. April"
#>   ..$ first_link_text : chr "Der 11. April ist der 101. Tag des gregorianischen Kalenders (der 102. in Schaltjahren), somit bleiben 264 Tage"| __truncated__
str(wiki_text[["not_scraped"]])
#>  NULL
```
