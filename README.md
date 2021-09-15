
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
#>   ..$ random_article  : chr "Uralan Elista"
#>   ..$ first_link_title: chr "Transliteration"
#>   ..$ first_link_text : chr "Transliteration (von lateinisch trans ‚hinüber‘ und litera (auch littera) ‚Buchstabe‘) bezeichnet in der angewa"| __truncated__
#>  $ 2 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Sven Metzger"
#>   ..$ first_link_title: chr "7. Januar"
#>   ..$ first_link_text : chr "Der 7. Januar (in Österreich und Südtirol: 7. Jänner) ist der 7. Tag des gregorianischen Kalenders, somit verbl"| __truncated__
#>  $ 3 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Karl Stephan (Propst)"
#>   ..$ first_link_title: chr "1700"
#>   ..$ first_link_text : logi NA
#>  $ 4 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Enid Lake"
#>   ..$ first_link_title: chr "Stausee"
#>   ..$ first_link_text : chr "Ein Stausee, vor allem in Österreich auch Speicher genannt, ist ein künstlich angelegter See, der sich in einem"| __truncated__
#>  $ 5 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Gustav Mahler"
#>   ..$ first_link_title: chr "7. Juli"
#>   ..$ first_link_text : chr "Der 7. Juli ist der 188. Tag des gregorianischen Kalenders (der 189. in Schaltjahren), somit bleiben 177 Tage b"| __truncated__
#>  $ 6 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Buddhas Fußabdruck"
#>   ..$ first_link_title: chr "Buddha"
#>   ..$ first_link_text : chr ""
#>  $ 7 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Heinrich Göckenjan"
#>   ..$ first_link_title: chr "30. September"
#>   ..$ first_link_text : chr "Der 30. September ist der 273. Tag des gregorianischen Kalenders (der 274. in Schaltjahren), somit bleiben 92 T"| __truncated__
#>  $ 8 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Landhotel Falkner"
#>   ..$ first_link_title: chr "„Marsbach (Gemeinde Hofkirchen)“ – Erstellen"
#>   ..$ first_link_text : logi NA
#>  $ 9 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Heinrich Modersohn"
#>   ..$ first_link_title: chr "1948"
#>   ..$ first_link_text : chr "Im Jahr 1948 steht vor allem die Zuspitzung der alliierten Gegensätze in der deutschen Frage im Mittelpunkt des"| __truncated__
#>  $ 10:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Digitalisierung von Schiffsplänen"
#>   ..$ first_link_title: chr "Deutsches Schifffahrtsmuseum"
#>   ..$ first_link_text : chr "Das Deutsche Schifffahrtsmuseum (DSM) in Bremerhaven ist das nationale Schifffahrtsmuseum in Deutschland. Es ge"| __truncated__
#>  $ 11:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Claes Nordin"
#>   ..$ first_link_title: chr "20. Juli"
#>   ..$ first_link_text : chr "Der 20. Juli ist der 201. Tag des gregorianischen Kalenders (der 202. in Schaltjahren), somit bleiben 164 Tage "| __truncated__
#>  $ 12:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Victor Kolyvagin"
#>   ..$ first_link_title: logi NA
#>   ..$ first_link_text : logi NA
#>  $ 13:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Geschichte des Oberleitungsbusses"
#>   ..$ first_link_title: chr "Oberleitungsbus"
#>   ..$ first_link_text : chr "Ein Oberleitungsbus – auch Oberleitungsomnibus, Obus, O-Bus, Trolleybus, Trolley oder veraltet gleislose Bahn[1"| __truncated__
#>  $ 14:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Reipisch"
#>   ..$ first_link_title: chr "Frankleben"
#>   ..$ first_link_text : chr "Frankleben ist seit dem 1. Januar 2004 ein Ortsteil von Braunsbedra[1] im Saalekreis in Sachsen-Anhalt."
#>  $ 15:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Liste der Monuments historiques in Forbach"
#>   ..$ first_link_title: chr "Frankreich"
#>   ..$ first_link_text : chr "Frankreich  ['f<U+0281>a<U+014B>k<U+0281>a<U+026A><U+032F>ç] (französisch France?/i [f<U+0281><U+0251>~s], amtl"| __truncated__
#>  $ 16:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Schaufenster Elektromobilität"
#>   ..$ first_link_title: chr "Bundesregierung (Deutschland)"
#>   ..$ first_link_text : chr "Die Bundesregierung (Abkürzung BReg),[1] auch Bundeskabinett genannt, ist ein Verfassungsorgan der Bundesrepubl"| __truncated__
#>  $ 17:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Heinz Rotholz"
#>   ..$ first_link_title: chr "28. Mai"
#>   ..$ first_link_text : chr "Der 28. Mai ist der 148. Tag des gregorianischen Kalenders (der 149. in Schaltjahren), somit verbleiben noch 21"| __truncated__
#>  $ 18:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Inger-Marie Ytterhorn"
#>   ..$ first_link_title: chr "18. September"
#>   ..$ first_link_text : chr "Der 18. September ist der 261. Tag des gregorianischen Kalenders (der 262. in Schaltjahren). Zum Jahresende ver"| __truncated__
#>  $ 19:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Adelheid von Sachsen-Meiningen (1792–1849)"
#>   ..$ first_link_title: chr "13. August"
#>   ..$ first_link_text : chr "Der 13. August ist der 225. Tag des gregorianischen Kalenders (der 226. in Schaltjahren), somit bleiben 140 Tag"| __truncated__
#>  $ 20:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Die Neunte Kompanie"
#>   ..$ first_link_title: chr "Fjodor Sergejewitsch Bondartschuk"
#>   ..$ first_link_text : chr "Fjodor Sergejewitsch Bondartschuk (russisch <U+0424><U+0451><U+0434><U+043E><U+0440> <U+0421><U+0435><U+0440><U"| __truncated__
str(wiki_text[["not_scraped"]])
#>  NULL
```
