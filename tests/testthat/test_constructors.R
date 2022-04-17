testthat::test_that(
  "constructors go() only accepts url as character string",
  {
    expect_error(parsel::go(url = 1))
  }
)

testthat::test_that(
  "constructors show() produces error when there is nothing to show",
  {
    expect_error(parsel::show())
  }
)
