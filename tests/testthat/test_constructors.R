testthat::test_that(
  "constructors go() input handling",
  {
    expect_error(go(url = 1))
  }
)

testthat::test_that(
  "constructors show() throws error when there is nothing to show",
  {
    expect_error(show())
  }
)

testthat::test_that(
  "constructors click() input handling",
  {
    expect_error(click(using = 1, value = "a"))
    expect_error(click(using = "a", value = 1))
    expect_error(click(using = "a", value = "a", name = 1))
    expect_error(click(using = "a", value = "a", new_page = 1))
  }
)


testthat::test_that(
  "constructors type() input handling",
  {
    expect_error(type(using = 1, value = "a", text = "a"))
    expect_error(type(using = "a", value = 1, text = "a"))
    expect_error(type(using = "a", value = "a", name = 1, text = "a"))
    expect_error(type(using = "a", value = "a", text = "a", text_object = "a"))
    expect_error(type(using = "a", value = "a", text = 1))
    expect_error(type(using = "a", value = "a", text_object = 1))
    expect_error(type(using = "a", value = "a", text_object = c("a","b")))
    expect_error(type(using = "a", value = "a", text = "a", new_page = 1))
  }
)


testthat::test_that(
  "constructors get_element() input handling",
  {
    expect_error(get_element(using = 1, value = "a"))
    expect_error(get_element(using = "a", value = 1))
    expect_error(get_element(using = "a", value = "a", name = 1))
    expect_error(get_element(using = "a", value = "a", name = "a", multiple = 1))
  }
)


testthat::test_that(
  "constructos pipe throws error when rhs has no prev argument",
  {
    expect_error(go("www.wikipedia.org") %>>% start_scraper("x"))
  }
)


testthat::test_that(
  "start_scraper() input handling",
  {
    expect_error(start_scraper(args = 1))
    expect_error(start_scraper(args = c("x","y"), name = 1))

  }
)

testthat::test_that(
  "build_scraper() throws error when no previous start_scraper() call in pipe",
  {
    expect_error(go("www.wikipedia.org") %>>% build_scraper())
  }

)

testthat::test_that(
  "build_scraper() throws error when there are no constructors in pipe",
  {
    expect_error(build_scraper())
  }
)

