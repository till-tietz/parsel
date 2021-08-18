
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
#>   ..$ random_article  : chr "Lucie Ribbe"
#>   ..$ first_link_title: chr "1898"
#>   ..$ first_link_text : chr "Kleinere Unglücksfälle sind in den Unterartikeln von Katastrophe aufgeführt."
#>  $ 2 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Joseph Brodmann"
#>   ..$ first_link_title: chr "3. September"
#>   ..$ first_link_text : chr "Der 3. September ist der 246. Tag des gregorianischen Kalenders (der 247. in Schaltjahren), somit bleiben 119 T"| __truncated__
#>  $ 3 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Haigermoos"
#>   ..$ first_link_title: chr "Gemeinde"
#>   ..$ first_link_text : chr "Als Gemeinde oder politische Gemeinde (auch Kommune) bezeichnet man Gebietskörperschaften (territoriale und hoh"| __truncated__
#>  $ 4 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Gmina Mucharz"
#>   ..$ first_link_title: chr "Gmina"
#>   ..$ first_link_text : chr "Eine Gmina ['gmina], im Plural Gminy, ist eine Verwaltungseinheit in Polen. Sie bildet die dritte Stufe der lok"| __truncated__
#>  $ 5 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Entschädigungseinrichtung der Wertpapierhandelsunternehmen"
#>   ..$ first_link_title: chr "Deutschland"
#>   ..$ first_link_text : chr "Deutschland ( ['d<U+0254><U+026A><U+032F>t<U+0361><U+0283>lant]; Vollform des Staatennamens seit 1949: Bundesre"| __truncated__
#>  $ 6 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Ócko"
#>   ..$ first_link_title: chr "Deutsche Sprache"
#>   ..$ first_link_text : chr "Die deutsche Sprache bzw. das Deutsche ([d<U+0254><U+026A><U+032F>t<U+0283>];[26] abgekürzt dt. oder dtsch.) is"| __truncated__
#>  $ 7 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Drew Tyler Bell"
#>   ..$ first_link_title: chr "29. Januar"
#>   ..$ first_link_text : chr "Der 29. Januar (in Österreich und Südtirol: 29. Jänner) ist der 29. Tag des gregorianischen Kalenders, somit bl"| __truncated__
#>  $ 8 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Konzert für zwei Klaviere (Poulenc)"
#>   ..$ first_link_title: chr "Francis Poulenc"
#>   ..$ first_link_text : chr "Francis Jean Marcel Poulenc [f<U+0280><U+0251>~'sis pu'l<U+025B>~k] (* 7. Januar 1899 in Paris; † 30. Januar 19"| __truncated__
#>  $ 9 :'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Thorakotomie"
#>   ..$ first_link_title: chr "Chirurgie"
#>   ..$ first_link_text : chr "Die Chirurgie (über lateinisch chirurgia von altgriechisch <U+03C7>e<U+03B9><U+03C1><U+03BF><U+03C5><U+03C1><U+"| __truncated__
#>  $ 10:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Geoje-Stadion"
#>   ..$ first_link_title: chr "Koreanisches Alphabet"
#>   ..$ first_link_text : chr "Das koreanische Alphabet (<U+D55C><U+AE00> Han’gul, Hangul,[1] Hangul, oder Hangeul bzw. <U+C870><U+C120><U+AE0"| __truncated__
#>  $ 11:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Walmdach"
#>   ..$ first_link_title: chr "Dachform"
#>   ..$ first_link_text : chr ""
#>  $ 12:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Kanton Meymac"
#>   ..$ first_link_title: chr "Frankreich"
#>   ..$ first_link_text : chr "Frankreich  ['f<U+0281>a<U+014B>k<U+0281>a<U+026A><U+032F>ç] (französisch France?/i [f<U+0281><U+0251>~s], amtl"| __truncated__
#>  $ 13:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Baron Strathcona and Mount Royal"
#>   ..$ first_link_title: chr "Peer (Adel)"
#>   ..$ first_link_text : chr "Ein Peer (vom lat. par „gleich, ebenbürtig“; französisch Pair) ist ein Angehöriger des britischen Hochadels."
#>  $ 14:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Georg Bauch"
#>   ..$ first_link_title: chr "7. September"
#>   ..$ first_link_text : chr "Der 7. September ist der 250. Tag des gregorianischen Kalenders (der 251. in Schaltjahren), somit bleiben 115 T"| __truncated__
#>  $ 15:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Udo Mantau"
#>   ..$ first_link_title: chr "17. Oktober"
#>   ..$ first_link_text : chr "Der 17. Oktober ist der 290. Tag des gregorianischen Kalenders (der 291. in Schaltjahren), somit verbleiben 75 "| __truncated__
#>  $ 16:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Bruno Wolke"
#>   ..$ first_link_title: chr "4. Mai"
#>   ..$ first_link_text : chr "Der 4. Mai ist der 124. Tag des gregorianischen Kalenders (der 125. in Schaltjahren), somit bleiben 241 Tage bi"| __truncated__
#>  $ 17:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Kalle Järvilehto"
#>   ..$ first_link_title: chr "21. Juli"
#>   ..$ first_link_text : chr "Der 21. Juli ist der 202. Tag des gregorianischen Kalenders (der 203. in Schaltjahren), somit bleiben 163 Tage "| __truncated__
#>  $ 18:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Wonder Why"
#>   ..$ first_link_title: chr "Nikolaus Brodszky"
#>   ..$ first_link_text : chr "Nikolaus Brodszky (auch Nicolas oder Miklós Brodszky; * 20. April 1905 in Odessa, Russisches Kaiserreich als Mi"| __truncated__
#>  $ 19:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "División de Honor (Schach) 1997"
#>   ..$ first_link_title: chr "Spanische Mannschaftsmeisterschaft im Schach"
#>   ..$ first_link_text : chr "Die spanische Mannschaftsmeisterschaft im Schach (spanisch Campeonato de España de Ajedrez por Equipos de Club)"| __truncated__
#>  $ 20:'data.frame':  1 obs. of  3 variables:
#>   ..$ random_article  : chr "Walter Buchebner"
#>   ..$ first_link_title: chr "1929"
#>   ..$ first_link_text : chr "Kleinere Unglücksfälle sind in den Unterartikeln von Katastrophe aufgeführt."
str(wiki_text[["not_scraped"]])
#>  NULL
```
