testthat::test_that(
  "constructors go() input handling",
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

testthat::test_that(
  "constructors click() input handling",
  {
    expect_error(parsel::click(using = 1, value = "a"))
    expect_error(parsel::click(using = "a", value = 1))
    expect_error(parsel::click(using = "a", value = "a", name = 1))
  }
)


testthat::test_that(
  "constructors type() input handling",
  {
    expect_error(parsel::type(using = 1, value = "a", text = "a"))
    expect_error(parsel::type(using = "a", value = 1, text = "a"))
    expect_error(parsel::type(using = "a", value = "a", name = 1, text = "a"))
    expect_error(parsel::type(using = "a", value = "a", text = "a", text_object = "a"))
    expect_error(parsel::type(using = "a", value = "a", text = 1))
    expect_error(parsel::type(using = "a", value = "a", text_object = 1))
    expect_error(parsel::type(using = "a", value = "a", text_object = c("a","b")))
  }
)
