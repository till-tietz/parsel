testthat::test_that(
  "constructors go() only accepts url as character string",
  {
    expect_error(parsel::go(url = 1))
  }
)
