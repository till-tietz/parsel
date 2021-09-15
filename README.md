
<!-- README.md is generated from README.Rmd. Please edit that file -->

# parsel

<!-- badges: start -->

[![R-CMD-check](https://github.com/till-tietz/parsel/workflows/R-CMD-check/badge.svg)](https://github.com/till-tietz/parsel/actions)
<!-- badges: end -->

badgecreatr::badgeplacer()

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
#>   ..$ random_article  : chr "Bhakkar (Distrikt)"
#>   ..$ first_link_title: chr "Pakistan"
#>   ..$ first_link_text : chr "Pakistan (Urdu <U+067E><U+0627><U+06A9><U+0633><U+062A><U+0627><U+0646>  [pa<U+02D0>k<U+026A>st<U+032A>a<U+02D0"| __truncated__
#>  $ 2 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Tomas Andersson Wij"
#>   ..$ first_link_title: chr "6. Februar"
#>   ..$ first_link_text : chr "Der 6. Februar ist der 37. Tag des gregorianischen Kalenders, somit bleiben 328 Tage (in Schaltjahren 329 Tage)"| __truncated__
#>  $ 3 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr ""
#>   ..$ first_link_title: logi NA
#>   ..$ first_link_text : logi NA
#>  $ 4 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Erlöser (Zürich-Riesbach)"
#>   ..$ first_link_title: chr "Römisch-katholische Kirche"
#>   ..$ first_link_text : chr "Die römisch-katholische Kirche („katholisch“ von griechisch <U+03BA>a<U+03B8><U+03BF><U+03BB><U+03B9><U+03BA><U"| __truncated__
#>  $ 5 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "GQ Lupi"
#>   ..$ first_link_title: chr "Stern"
#>   ..$ first_link_text : chr "Unter einem Stern (altgriechisch <U+1F00>st<U+03AE><U+03C1>, <U+1F04>st<U+03C1><U+03BF><U+03BD> aster, astron u"| __truncated__
#>  $ 6 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Nocturnal Breed"
#>   ..$ first_link_title: chr "Norwegen"
#>   ..$ first_link_text : chr "Norwegen (norwegisch: Norge (Bokmål) oder Noreg (Nynorsk); nordsamisch: Norga; lulesamisch: Vuodna; südsamisch:"| __truncated__
#>  $ 7 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Orthodoxe Johanneskapelle (Kevelaer)"
#>   ..$ first_link_title: chr "Orthodoxie"
#>   ..$ first_link_text : chr "Orthodoxie (altgriechisch <U+1F40><U+03C1><U+03B8><U+03CC><U+03C2> orthós „richtig“, „geradlinig“ und d<U+03CC>"| __truncated__
#>  $ 8 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Hartwig Möller"
#>   ..$ first_link_title: chr "1944"
#>   ..$ first_link_text : chr "Das Jahr 1944 ist von der Eröffnung der „Zweiten Front“ in Westeuropa im Zweiten Weltkrieg gegen das Deutsche R"| __truncated__
#>  $ 9 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Nadelsiepen"
#>   ..$ first_link_title: chr "Radevormwald"
#>   ..$ first_link_text : chr "Radevormwald – ortsübliche Kurzform: Rade – gehört zu den ältesten Städten im Bergischen Land in Nordrhein-West"| __truncated__
#>  $ 10:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Georgia Langhans"
#>   ..$ first_link_title: chr "4. Juli"
#>   ..$ first_link_text : chr "Der 4. Juli ist der 185. Tag des gregorianischen Kalenders (der 186. in Schaltjahren), somit bleiben 180 Tage b"| __truncated__
#>  $ 11:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Boisse-Penchot"
#>   ..$ first_link_title: logi NA
#>   ..$ first_link_text : logi NA
#>  $ 12:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Nächte des Grauens (1916)"
#>   ..$ first_link_title: chr "Stummfilm"
#>   ..$ first_link_text : chr "Als Stummfilm wird seit der Verbreitung des Tonfilms in den 1920er-Jahren ein Film ohne technisch-mechanisch vo"| __truncated__
#>  $ 13:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "William Gay Brown senior"
#>   ..$ first_link_title: chr "25. September"
#>   ..$ first_link_text : chr "Der 25. September ist der 268. Tag des gregorianischen Kalenders (der 269. in Schaltjahren). Zum Jahresende ver"| __truncated__
#>  $ 14:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Annika Graser"
#>   ..$ first_link_title: chr "3. September"
#>   ..$ first_link_text : chr "Der 3. September ist der 246. Tag des gregorianischen Kalenders (der 247. in Schaltjahren), somit bleiben 119 T"| __truncated__
#>  $ 15:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Comandante Luis Piedra Buena"
#>   ..$ first_link_title: chr "Departamento Corpen Aike"
#>   ..$ first_link_text : chr "Das Departamento Corpen Aike liegt im Osten der Provinz Santa Cruz im Süden Argentiniens und ist eine der siebe"| __truncated__
#>  $ 16:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Großer Preis von Deutschland"
#>   ..$ first_link_title: chr "Automobilsport"
#>   ..$ first_link_text : chr "Der Automobilsport als Form des Motorsports umfasst alle Disziplinen und Wettbewerbe, die das möglichst schnell"| __truncated__
#>  $ 17:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Río Aysén"
#>   ..$ first_link_title: chr "Patagonien"
#>   ..$ first_link_text : chr "Patagonien bezeichnet den Teil Südamerikas, der sich südlich der Flüsse Río Colorado in Argentinien und Río Bío"| __truncated__
#>  $ 18:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Moritz August von Obernitz"
#>   ..$ first_link_title: chr "14. September"
#>   ..$ first_link_text : chr "Der 14. September ist der 257. Tag des gregorianischen Kalenders (der 258. in Schaltjahren), somit bleiben noch"| __truncated__
#>  $ 19:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Claudius Berenicianus"
#>   ..$ first_link_title: chr "Praenomen"
#>   ..$ first_link_text : chr "Das Praenomen war im antiken Rom das erste Glied der dreiteiligen Namensform (tria nomina) männlicher römischer"| __truncated__
#>  $ 20:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Bernhard Weisser"
#>   ..$ first_link_title: chr "1964"
#>   ..$ first_link_text : chr "Einträge von Leichtathletik-Weltrekorden siehe unter der jeweiligen Disziplin unter Leichtathletik."
str(wiki_text[["not_scraped"]])
#>  NULL
```
