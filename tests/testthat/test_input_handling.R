
testthat::test_that(
  "scrape fun only accepts functions",
  {
    expect_error(parsel::parscrape(scrape_fun = "a", scrape_input = c(1:10), browser = "firefox"))
  }
)

testthat::test_that(
  "cores only accepts numeric",
  {
    f <- function(){}
    expect_error(parsel::parscrape(scrape_fun = f, scrape_input = c(1:10), cores = "a", browser = "firefox"))
  }
)


testthat::test_that(
  "ports only accepts numeric and lenght(ports) must equal cores",
  {
    f <- function(){}
    expect_error(parsel::parscrape(scrape_fun = f, scrape_input = c(1:10), cores = 2, browser = "firefox", ports = "a"))
    expect_error(parsel::parscrape(scrape_fun = f, scrape_input = c(1:10), cores = 2, broweser = "firefox", ports = 1))
  }
)


testthat::test_that(
  "chunk size only accepts numeric",
  {
    f <- function(){}
    expect_error(parsel::parscrape(scrape_fun = f, scrape_input = c(1:10), browser = "firefox", chunk_size = "a"))
  }
)

testthat::test_that(
  "proxy only accepts function",
  {
    f <- function(){}
    expect_error(parsel::parscrape(scrape_fun = f, scrape_input = c(1:10), browser = "firefox", proxy = "a"))
  }
)

testthat::test_that(
  "extraCapabilities only accepts list",
  {
    f <- function(){}
    expect_error(parsel::parscrape(scrape_fun = f, scrape_input = c(1:10), browser = "firefox", extraCapabilities = "a"))
  }
)

