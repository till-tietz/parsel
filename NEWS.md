# parsel 0.3.0

* Added `start_scraper` and `build_scraper` functions, which jointly allow users to turn scraper functionality defined by `parsel` 
constructors into scraping functions. Scraping code can now not only be dumped to the console via `show` but be returned to the 
environment as a function. 

# parsel 0.2.1

* fixed `parscrape` row number mismatch bug in the construction of the unscraped data.frame when chunks contain different numbers of scrape elements. 

# parsel 0.2.0

* Added 'RSelenium' constructor functions. These functions are wrappers around 'RSelenium' methods that allow you to quickly and easily render safe, ready to use
'RSelenium' scraping code to the console and paste it into your scraping functions. 
Constructors can be piped together via `%>>%` to allow for intuitive, sequential 
construction of scraping code. 


# parsel 0.1.0

* Added a `NEWS.md` file to track changes to the package.
