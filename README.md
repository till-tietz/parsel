
<!-- README.md is generated from README.Rmd. Please edit that file -->

# parsel

<!-- badges: start -->

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
#>   ..$ random_article  : chr "Pazifikdegu"
#>   ..$ first_link_title: chr "Nagetiere"
#>   ..$ first_link_text : chr "Die Nagetiere (Rodentia) sind eine Ordnung der Säugetiere (Mammalia). Mit etwa 2500[1] bis 2600[2] Arten stelle"| __truncated__
#>  $ 2 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Fareva"
#>   ..$ first_link_title: chr "Holding"
#>   ..$ first_link_text : chr "Holding (Kurzform für Holding-Gesellschaft, Holding-Organisation oder auch Dachgesellschaft) ist der Anglizismu"| __truncated__
#>  $ 3 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Peter Fratzl"
#>   ..$ first_link_title: chr "13. September"
#>   ..$ first_link_text : chr "Der 13. September ist der 256. Tag des gregorianischen Kalenders (der 257. in Schaltjahren). Somit verbleiben n"| __truncated__
#>  $ 4 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Schlacht um Baku"
#>   ..$ first_link_title: chr "Osmanisches Reich"
#>   ..$ first_link_text : chr "Das Osmanische Reich (osmanisch <U+062F><U+0648><U+0644><U+062A> <U+0639><U+0644><U+06CC><U+0647> IA Devlet-i <"| __truncated__
#>  $ 5 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Lloyd Burdick"
#>   ..$ first_link_title: chr "8. August"
#>   ..$ first_link_text : chr "Der 8. August ist der 220. Tag des gregorianischen Kalenders (der 221. in Schaltjahren), somit bleiben 145 Tage"| __truncated__
#>  $ 6 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Liste der Nummer-eins-Hits in Australien (1969)"
#>   ..$ first_link_title: logi NA
#>   ..$ first_link_text : logi NA
#>  $ 7 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Maria-Josepha-Straße"
#>   ..$ first_link_title: chr "München"
#>   ..$ first_link_text : chr "München (hochdeutsch  ['m<U+028F>nçn<U+0329>] oder ['m<U+028F>nç<U+0259>n];[2] bairisch Minga?/i ['m<U+026A><U+"| __truncated__
#>  $ 8 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Gisela Enders"
#>   ..$ first_link_title: chr "25. Mai"
#>   ..$ first_link_text : chr "Der 25. Mai ist der 145. Tag des gregorianischen Kalenders (der 146. in Schaltjahren), somit bleiben 220 Tage b"| __truncated__
#>  $ 9 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Frauenthal (Weiding)"
#>   ..$ first_link_title: chr "Bayern"
#>   ..$ first_link_text : chr "Der Freistaat Bayern ( ['ba<U+026A><U+032F><U+0250>n]; Ländercode BY) ist mit mehr als 70.500 Quadratkilometern"| __truncated__
#>  $ 10:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Ponta da Garça (Príncipe)"
#>   ..$ first_link_title: chr "Príncipe"
#>   ..$ first_link_text : chr "Príncipe (portugiesisch für „Fürst“, „Prinz“), deutsch Prinzeninsel, ist die nördlichere der beiden Hauptinseln"| __truncated__
#>  $ 11:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Wladimir Apziauri"
#>   ..$ first_link_title: chr "4. Februar"
#>   ..$ first_link_text : chr "Der 4. Februar ist der 35. Tag des gregorianischen Kalenders, somit bleiben 330 Tage (in Schaltjahren 331 Tage)"| __truncated__
#>  $ 12:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Petros Markaris"
#>   ..$ first_link_title: chr "1. Januar"
#>   ..$ first_link_text : chr "Der 1. Januar (in Österreich und Südtirol: 1. Jänner) ist der 1. Tag des gregorianischen Kalenders,[1] somit bl"| __truncated__
#>  $ 13:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Condamine (Ain)"
#>   ..$ first_link_title: chr "Frankreich"
#>   ..$ first_link_text : chr "Frankreich  ['f<U+0281>a<U+014B>k<U+0281>a<U+026A><U+032F>ç] (französisch France?/i [f<U+0281><U+0251>~s], amtl"| __truncated__
#>  $ 14:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Spandauer SV"
#>   ..$ first_link_title: chr "Berlin-Spandau"
#>   ..$ first_link_text : chr "Spandau ist der namensgebende Ortsteil im Bezirk Spandau von Berlin."
#>  $ 15:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Heinrich Keller (Musiker)"
#>   ..$ first_link_title: chr "25. August"
#>   ..$ first_link_text : chr "Der 25. August ist der 237. Tag des gregorianischen Kalenders (der 238. in Schaltjahren), somit bleiben noch 12"| __truncated__
#>  $ 16:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "KZ-Außenlager Regensburg"
#>   ..$ first_link_title: chr "KZ-Außenlager"
#>   ..$ first_link_text : chr "Den Begriff KZ-Außenlager als Abkürzung für einen räumlich separat liegenden Teil eines Konzentrationslagers be"| __truncated__
#>  $ 17:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Herr Satan persönlich"
#>   ..$ first_link_title: logi NA
#>   ..$ first_link_text : logi NA
#>  $ 18:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Renaissance Tower"
#>   ..$ first_link_title: chr "Dallas"
#>   ..$ first_link_text : chr "Dallas (['dæl<U+0259>s]) ist nach Houston und San Antonio die drittgrößte Stadt im Bundesstaat Texas und die ne"| __truncated__
#>  $ 19:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Grootes Peak"
#>   ..$ first_link_title: chr "Berg"
#>   ..$ first_link_text : chr "Ein Berg ist eine Landform, die sich über die Umgebung erhebt. Er ist meist höher und steiler als ein Hügel, wo"| __truncated__
#>  $ 20:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Glücksindikator"
#>   ..$ first_link_title: chr "Kennzahl"
#>   ..$ first_link_text : chr "Eine Kennzahl ist eine Maßzahl, die zur Quantifizierung dient und der eine Vorschrift zur quantitativen reprodu"| __truncated__
str(wiki_text[["not_scraped"]])
#>  NULL
```
