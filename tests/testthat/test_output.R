skip_scrape <- function(){
  testthat::skip("skipping scraping")
}

testthat::skip_on_cran()
testthat::test_that(
  "parscrape produces expected output",
  {
    testthat::skip_on_cran()
    skip_scrape()
    input_error <- c(".central-textlogo__image",".central-textlogo__imagerrrr")
    input_noerror <- c(".central-textlogo__image",".central-textlogo__image")

    scrape_fun <- function(x){
      input_i <- x

      remDr$navigate("https://www.wikipedia.org/")

      element <- remDr$findElement(using = "css", input_i)
      element <- element$getElementText()

      return(element)
    }

    out_error <- parsel::parscrape(scrape_fun = scrape_fun,
                                   scrape_input = input_error,
                                   cores = 2,
                                   packages = c("RSelenium"),
                                   browser = "firefox",
                                   scrape_tries = 1,
                                   chunk_size = 1,
                                   extraCapabilities = list(
                                     "moz:firefoxOptions" = list(args = list('--headless'))
                                     )
                                   )

    out_noerror <- parsel::parscrape(scrape_fun = scrape_fun,
                                     scrape_input = input_noerror,
                                     cores = 2,
                                     packages = c("RSelenium"),
                                     browser = "firefox",
                                     scrape_tries = 1,
                                     chunk_size = 1,
                                     extraCapabilities = list(
                                       "moz:firefoxOptions" = list(args = list('--headless'))
                                       )
                                     )

    expect_equal(nrow(out_error[["not_scraped"]]),1)
    expect_equal(ncol(out_error[["not_scraped"]]),3)
    expect_equal(class(out_error[["not_scraped"]]),"data.frame")
    expect_equal(out_error[["scraped_results"]][[1]][[1]], "Wikipedia")
    expect_equal(is.null(out_noerror[["not_scraped"]]), TRUE)
  }
)




