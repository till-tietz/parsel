skip_scrape <- function(){
  testthat::skip("skipping scraping")
}

testthat::skip_on_cran()
testthat::test_that(
  "parscrape produces expected output",
  {
    testthat::skip_on_cran()
    skip_scrape()
    input <- c(".central-textlogo__image",".central-textlogo__imagerrrr")

    f <- function(x){
      input_i <- x

      remDr$navigate("https://www.wikipedia.org/")

      element <- remDr$findElement(using = "css", input_i)
      element <- element$getElementText()

      return(element)
    }

    out <- parsel::parscrape(scrape_fun = f,
                             scrape_input = input,
                             cores = 2,
                             packages = c("RSelenium"),
                             browser = "firefox",
                             scrape_tries = 1,
                             chunk_size = 1)

    expect_length(out[["not_scraped"]],1)
    expect_equal(out[["scraped_results"]][[1]][[1]], "Wikipedia")

  }
)



