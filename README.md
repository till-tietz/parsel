
<!-- README.md is generated from README.Rmd. Please edit that file -->

# parsel

<!-- badges: start -->

[![R-CMD-check](https://github.com/till-tietz/parsel/workflows/R-CMD-check/badge.svg)](https://github.com/till-tietz/parsel/actions)
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
#>   ..$ random_article  : chr "Pfarrkirche Gorentschach"
#>   ..$ first_link_title: chr "Römisch-katholische Kirche"
#>   ..$ first_link_text : chr "Die römisch-katholische Kirche („katholisch“ von griechisch <U+03BA>a<U+03B8><U+03BF><U+03BB><U+03B9><U+03BA><U"| __truncated__
#>  $ 2 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "The Return of Bruno"
#>   ..$ first_link_title: chr "Musikalbum"
#>   ..$ first_link_text : chr "Ein Musikalbum (auch kurz Album) ist in der Musikindustrie die Bezeichnung für eine vom Tonträger unabhängige Z"| __truncated__
#>  $ 3 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Driss Guiga"
#>   ..$ first_link_title: chr "Arabische Sprache"
#>   ..$ first_link_text : chr "Die arabische Sprache (kurz Arabisch; Eigenbezeichnung <U+0627><U+064E><U+0644><U+0644><U+064F><U+0651><U+063A>"| __truncated__
#>  $ 4 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Liste der Lokomotiven und Triebwagen der BBÖ"
#>   ..$ first_link_title: logi NA
#>   ..$ first_link_text : logi NA
#>  $ 5 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Mersea Island"
#>   ..$ first_link_title: logi NA
#>   ..$ first_link_text : logi NA
#>  $ 6 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Tjautjas"
#>   ..$ first_link_title: chr "Nordsamische Sprache"
#>   ..$ first_link_text : chr "Nordsamisch (auch Saamisch, Sámi; Eigenbezeichnung davvisámegiella) ist die mit Abstand größte Sprache aus der "| __truncated__
#>  $ 7 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Varkaus"
#>   ..$ first_link_title: chr "Gemeinde (Finnland)"
#>   ..$ first_link_text : chr "Die Gemeinden (finnisch kunta, schwedisch kommun; auch als ‚Kommune‘ übersetzt) bilden in Finnland die lokale E"| __truncated__
#>  $ 8 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Barnabas der Vampir"
#>   ..$ first_link_title: chr "„William Edward Daniel Ross“ – Erstellen"
#>   ..$ first_link_text : logi NA
#>  $ 9 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Tower Hill (London Underground)"
#>   ..$ first_link_title: chr "U-Bahnhof"
#>   ..$ first_link_text : chr "Als U-Bahnhof (alternativ auch U-Bahn-Station oder U-Bahn-Haltestelle, abgekürzt U-Bf., U-Bhf. oder U-Hst.) wer"| __truncated__
#>  $ 10:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Seyhan Derin"
#>   ..$ first_link_title: chr "1. Juli"
#>   ..$ first_link_text : chr "Der 1. Juli ist der 182. Tag des gregorianischen Kalenders (der 183. in Schaltjahren), somit bleiben 183 Tage b"| __truncated__
#>  $ 11:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Kirill Gennadjewitsch Prigoda"
#>   ..$ first_link_title: chr "29. Dezember"
#>   ..$ first_link_text : chr "Der 29. Dezember ist der 363. Tag des gregorianischen Kalenders (der 364. in Schaltjahren), somit bleiben 2 Tag"| __truncated__
#>  $ 12:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Veronika Olbrich"
#>   ..$ first_link_title: chr "1. September"
#>   ..$ first_link_text : chr "Der 1. September ist der 244. Tag des gregorianischen Kalenders (der 245. in Schaltjahren), somit bleiben noch "| __truncated__
#>  $ 13:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Liste von Seehäfen"
#>   ..$ first_link_title: chr "Seehafen"
#>   ..$ first_link_text : chr "Ein Seehafen ist ein Hafen, der von Seeschiffen angelaufen werden kann. Seehäfen können an der Küste, an Flüsse"| __truncated__
#>  $ 14:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Hudson Hoagland"
#>   ..$ first_link_title: chr "5. Dezember"
#>   ..$ first_link_text : chr "Der 5. Dezember ist der 339. Tag des gregorianischen Kalenders (der 340. in Schaltjahren), somit bleiben 26 Tag"| __truncated__
#>  $ 15:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Stefan Bogoridi"
#>   ..$ first_link_title: logi NA
#>   ..$ first_link_text : logi NA
#>  $ 16:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Agesipolis I."
#>   ..$ first_link_title: chr "Pausanias (König)"
#>   ..$ first_link_text : chr "Pausanias (altgriechisch <U+03A0>a<U+03C5>sa<U+03BD><U+03AF>a<U+03C2> Pausanías) war ein König von Sparta aus d"| __truncated__
#>  $ 17:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Codes im Neuromarketing"
#>   ..$ first_link_title: chr "Neuromarketing"
#>   ..$ first_link_text : chr ""
#>  $ 18:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Her First Adventure"
#>   ..$ first_link_title: chr "Vereinigte Staaten"
#>   ..$ first_link_text : chr "Die Vereinigten Staaten von Amerika (englisch United States of America; abgekürzt USA), kurz Vereinigte Staaten"| __truncated__
#>  $ 19:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Absperrhahn"
#>   ..$ first_link_title: chr "Armatur"
#>   ..$ first_link_text : chr "Eine Armatur (lateinisch armare „ausrüsten“) in Sanitärtechnik und Anlagenbau bezeichnet ein Bauteil zum Veränd"| __truncated__
#>  $ 20:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "August Brehm"
#>   ..$ first_link_title: chr "15. Oktober"
#>   ..$ first_link_text : chr "Der 15. Oktober ist der 288. Tag des gregorianischen Kalenders (der 289. in Schaltjahren), somit bleiben 77 Tag"| __truncated__
str(wiki_text[["not_scraped"]])
#>  NULL
```
