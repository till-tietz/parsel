
<!-- README.md is generated from README.Rmd. Please edit that file -->

# parsel

<!-- badges: start -->

[![R-CMD-check](https://github.com/till-tietz/parsel/workflows/R-CMD-check/badge.svg)](https://github.com/till-tietz/parsel/actions)
[![Codecov test
coverage](https://codecov.io/gh/till-tietz/parsel/branch/master/graph/badge.svg)](https://codecov.io/gh/till-tietz/parsel?branch=master)
<!-- badges: end -->

parsel parallelizes the execution of RSelenium. It allows you to easily
and conveniently run multiple RSelenium browsers simultaneously to speed
up your dynamic web scraping jobs.

## Installation

You can install the development version of parsel from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("till-tietz/parsel")
```

## Example

The following quick (and slightly silly) example will hopefully serve to
illustrate the functions and ideas behind how parsel operates. We’ll set
up the following scraping job:

1.  navigate to a random wikipedia article
2.  retrieve its title
3.  navigate to the first linked page on the article
4.  retrieve the linked page’s title and first section

and parallelize it with parsel.

parsel requires two things:

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
#>   ..$ random_article  : chr "Borcke (Familienname)"
#>   ..$ first_link_title: logi NA
#>   ..$ first_link_text : logi NA
#>  $ 2 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Douze"
#>   ..$ first_link_title: chr "Frankreich"
#>   ..$ first_link_text : chr "Frankreich  ['f<U+0281>a<U+014B>k<U+0281>a<U+026A><U+032F>ç] (französisch France?/i [f<U+0281><U+0251>~s], amtl"| __truncated__
#>  $ 3 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Liste der Kulturdenkmäler in Wörth am Rhein"
#>   ..$ first_link_title: chr "Kulturdenkmal"
#>   ..$ first_link_text : chr "Ein Kulturdenkmal ist im allgemeinen Sprachgebrauch laut Duden ein Objekt oder Werk, „das als Zeugnis einer Kul"| __truncated__
#>  $ 4 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Hot Spring County"
#>   ..$ first_link_title: chr "County (Vereinigte Staaten)"
#>   ..$ first_link_text : chr "Ein County (das oder die County, Plural: englisch counties, deutsch Countys) ist in 48 der 50 Bundesstaaten der"| __truncated__
#>  $ 5 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Långe Erik"
#>   ..$ first_link_title: chr "Leuchtturm"
#>   ..$ first_link_text : chr "Als Leuchtturm wird ein Turm bezeichnet, der eine Befeuerung trägt. Leuchttürme sind insbesondere nachts weithi"| __truncated__
#>  $ 6 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Tischtennisweltmeisterschaft 1983"
#>   ..$ first_link_title: chr "28. April"
#>   ..$ first_link_text : chr "Der 28. April ist der 118. Tag des gregorianischen Kalenders (der 119. in Schaltjahren), somit verbleiben 247 T"| __truncated__
#>  $ 7 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Opuntien-Grundfink"
#>   ..$ first_link_title: chr "Singvögel"
#>   ..$ first_link_text : chr "Die Singvögel (Passeri oder auch Oscines) sind in der Ornithologie eine Unterordnung der Sperlingsvögel (Passer"| __truncated__
#>  $ 8 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Thomas Placidus Fleming"
#>   ..$ first_link_title: chr "15. Oktober"
#>   ..$ first_link_text : chr "Der 15. Oktober ist der 288. Tag des gregorianischen Kalenders (der 289. in Schaltjahren), somit bleiben 77 Tag"| __truncated__
#>  $ 9 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Chassanbi Urusbijewitsch Taow"
#>   ..$ first_link_title: chr "5. November"
#>   ..$ first_link_text : chr "Der 5. November ist der 309. Tag des gregorianischen Kalenders (der 310. in Schaltjahren), somit bleiben 56 Tag"| __truncated__
#>  $ 10:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Joseph Michel (Komponist)"
#>   ..$ first_link_title: chr "1679"
#>   ..$ first_link_text : chr "Wien wird von einer Pestepidemie heimgesucht. Die Legende des lieben Augustin entsteht. Auf der Flucht aus der "| __truncated__
#>  $ 11:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "AFC Cup 2009"
#>   ..$ first_link_title: chr "Asian Football Confederation"
#>   ..$ first_link_text : chr "Die Asian Football Confederation (dt.: Asiatische Fußball-Konföderation), auch AFC, ist der asiatische Fußballv"| __truncated__
#>  $ 12:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Giacinto Cornacchioli"
#>   ..$ first_link_title: chr "1599"
#>   ..$ first_link_text : logi NA
#>  $ 13:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Sajzy"
#>   ..$ first_link_title: chr "Deutsche Sprache"
#>   ..$ first_link_text : chr "Die deutsche Sprache bzw. das Deutsche ([d<U+0254><U+026A><U+032F>t<U+0283>];[26] abgekürzt dt. oder dtsch.) is"| __truncated__
#>  $ 14:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Josef Wolfsberger"
#>   ..$ first_link_title: chr "5. Juli"
#>   ..$ first_link_text : chr "Der 5. Juli ist der 186. Tag des gregorianischen Kalenders (der 187. in Schaltjahren), somit bleiben 179 Tage b"| __truncated__
#>  $ 15:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Communauté de communes du Pays d’Argentat"
#>   ..$ first_link_title: chr "Frankreich"
#>   ..$ first_link_text : chr "Frankreich  ['f<U+0281>a<U+014B>k<U+0281>a<U+026A><U+032F>ç] (französisch France?/i [f<U+0281><U+0251>~s], amtl"| __truncated__
#>  $ 16:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Lao Army FC"
#>   ..$ first_link_title: chr "Laos"
#>   ..$ first_link_text : chr "Laos (['la<U+02D0><U+0254>s], laotisch <U+0E9B><U+0EB0><U+0EC0><U+0E97><U+0E94><U+0EA5><U+0EB2><U+0EA7>, amtlic"| __truncated__
#>  $ 17:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Michel Poffet (Fechter)"
#>   ..$ first_link_title: chr "24. August"
#>   ..$ first_link_text : chr "Der 24. August ist der 236. Tag des gregorianischen Kalenders (der 237. in Schaltjahren), somit bleiben 129 Tag"| __truncated__
#>  $ 18:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Juri Michailowitsch Swirin"
#>   ..$ first_link_title: chr "29. Januar"
#>   ..$ first_link_text : chr "Der 29. Januar (in Österreich und Südtirol: 29. Jänner) ist der 29. Tag des gregorianischen Kalenders, somit bl"| __truncated__
#>  $ 19:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Brenham"
#>   ..$ first_link_title: chr "County Seat"
#>   ..$ first_link_text : chr "Ein County Seat ist der Verwaltungssitz eines Countys in den Vereinigten Staaten und in Kanada."
#>  $ 20:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Léon Taverdet"
#>   ..$ first_link_title: chr "17. Juli"
#>   ..$ first_link_text : chr "Der 17. Juli ist der 198. Tag des gregorianischen Kalenders (der 199. in Schaltjahren), somit bleiben noch 167 "| __truncated__
str(wiki_text[["not_scraped"]])
#>  NULL
```
