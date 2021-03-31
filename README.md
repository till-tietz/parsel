
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
execution of the function

``` r
wiki_text <- parsel::parscrape(scrape_fun = get_wiki_text,
                               scrape_input = input,
                               cores = 4,
                               packages = c("RSelenium","XML"),
                               browser = "firefox",
                               chunk_size = 4,
                               scrape_tries = 1)
#> [1] "chunk 1 scraped"
#> [1] "chunk 2 scraped"
#> [1] "chunk 3 scraped"
#> [1] "chunk 4 scraped"
#> [1] "chunk 5 scraped"
```

parsel returns a list with two elements:

1.  a list of your scrape function output
2.  a list of elements it was unable to scrape

<!-- end list -->

``` r
str(wiki_text[["scraped_results"]])
#> List of 20
#>  $ 1 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "HD-Telefonie"
#>   ..$ first_link_title: chr "Gigaset"
#>   ..$ first_link_text : chr ""
#>  $ 2 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Christian Friedrich Minameyer"
#>   ..$ first_link_title: chr "25. Oktober"
#>   ..$ first_link_text : chr "Der 25. Oktober ist der 298. Tag des gregorianischen Kalenders (der 299. in Schaltjahren), somit bleiben 67 Tag"| __truncated__
#>  $ 3 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "DSB MX (II)"
#>   ..$ first_link_title: chr "Dieselelektrischer Antrieb"
#>   ..$ first_link_text : chr "Der dieselelektrische Antrieb ist ein Übertragungssystem, mit dem die von großen Dieselmotoren erzeugte mechani"| __truncated__
#>  $ 4 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Émile Cornic"
#>   ..$ first_link_title: chr "23. Februar"
#>   ..$ first_link_text : chr "Der 23. Februar ist der 54. Tag des gregorianischen Kalenders, somit bleiben 311 Tage (in Schaltjahren 312 Tage"| __truncated__
#>  $ 5 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Flughafen Kadala"
#>   ..$ first_link_title: chr "IATA-Flughafencode"
#>   ..$ first_link_text : chr "Der IATA-Flughafencode (engl. IATA airport code oder IATA station code, manchmal auch IATA (Airport) Three Lett"| __truncated__
#>  $ 6 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Werner Philipp"
#>   ..$ first_link_title: chr "13. März"
#>   ..$ first_link_text : chr "Der 13. März ist der 72. Tag des gregorianischen Kalenders (der 73. in Schaltjahren), somit bleiben 293 Tage bi"| __truncated__
#>  $ 7 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Saxler"
#>   ..$ first_link_title: chr "Ortsgemeinde (Rheinland-Pfalz)"
#>   ..$ first_link_text : chr "Als Ortsgemeinde wird in Rheinland-Pfalz eine rechtlich eigenständige Gemeinde, die einer Verbandsgemeinde als "| __truncated__
#>  $ 8 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "NaturVision"
#>   ..$ first_link_title: chr "Filmfestival"
#>   ..$ first_link_text : chr "Ein Filmfestival ist eine periodisch stattfindende kulturwirtschaftliche Veranstaltung, bei der an einem bestim"| __truncated__
#>  $ 9 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Helmut Büttner (Richter)"
#>   ..$ first_link_title: chr "13. November"
#>   ..$ first_link_text : chr "Der 13. November ist der 317. Tag des gregorianischen Kalenders (der 318. in Schaltjahren), somit bleiben 48 Ta"| __truncated__
#>  $ 10:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Anne Beathe Tvinnereim"
#>   ..$ first_link_title: chr "22. Mai"
#>   ..$ first_link_text : chr "Der 22. Mai ist der 142. Tag des gregorianischen Kalenders (der 143. in Schaltjahren), somit verbleiben noch 22"| __truncated__
#>  $ 11:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Liste der Staatsoberhäupter 1226"
#>   ..$ first_link_title: logi NA
#>   ..$ first_link_text : logi NA
#>  $ 12:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Burg Mündelstein"
#>   ..$ first_link_title: chr "Burgstall"
#>   ..$ first_link_text : chr "Als Burgstall (Singular der Burgstall, Plural die Burgställe, altertümlich die Burgstähl[1]), auch Burgstelle, "| __truncated__
#>  $ 13:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Karl Schultheiss (Maler)"
#>   ..$ first_link_title: chr "21. August"
#>   ..$ first_link_text : chr "Der 21. August ist der 233. Tag des gregorianischen Kalenders (der 234. in Schaltjahren), somit bleiben 132 Tag"| __truncated__
#>  $ 14:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Rungwe"
#>   ..$ first_link_title: chr "Vulkan"
#>   ..$ first_link_text : chr "Ein Vulkan ist eine geologische Struktur, die entsteht, wenn Magma (Gesteinsschmelze) bis an die Oberfläche ein"| __truncated__
#>  $ 15:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Chris Abrahams"
#>   ..$ first_link_title: chr "9. April"
#>   ..$ first_link_text : chr "Der 9. April ist der 99. Tag des gregorianischen Kalenders (der 100. in Schaltjahren), somit bleiben 266 Tage b"| __truncated__
#>  $ 16:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Hawaii Railway"
#>   ..$ first_link_title: chr "Hawaii"
#>   ..$ first_link_text : chr "Hawaii ([ha'va<U+035C>ii], englisch [h<U+0259>'w<U+0251><U+02D0>i<U+02D0>], hawaiisch Hawai<U+02BB>i bzw. Mokup"| __truncated__
#>  $ 17:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "IC 3223"
#>   ..$ first_link_title: logi NA
#>   ..$ first_link_text : logi NA
#>  $ 18:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Wittekind zu Waldeck und Pyrmont"
#>   ..$ first_link_title: chr "9. März"
#>   ..$ first_link_text : chr "Der 9. März ist der 68. Tag des gregorianischen Kalenders (der 69. in Schaltjahren), somit bleiben 297 Tage bis"| __truncated__
#>  $ 19:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Pfarrhaus Aich (Fürstenfeldbruck)"
#>   ..$ first_link_title: chr "Aich (Fürstenfeldbruck)"
#>   ..$ first_link_text : chr "Aich ist ein amtlich benannter Gemeindeteil der Oberbayerischen Stadt Fürstenfeldbruck in Bayern."
#>  $ 20:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Liste der Baudenkmäler in Schwanenberg"
#>   ..$ first_link_title: chr "Denkmalschutz"
#>   ..$ first_link_text : chr "Denkmalschutz dient dem Schutz von Kulturdenkmälern und kulturhistorisch relevanten Gesamtanlagen (Ensembleschu"| __truncated__
str(wiki_text[["not_scraped"]])
#>  NULL
```
