source("library.R")
set.seed(543)
x <- seq(as.Date("2016-01-01"), by = "day", length.out = 366)
x <- x[sample(1:366, 200)] %>% sort
x_df <- data_frame(x  = x,
                   y1 = runif(200, 10, 20) %>% round,
                   y2 = runif(200, 1, 50) %>% round,
                   y3 = rep(10, 200) %>% round,
                   y4 = rep(letters[1:4], c(80, 60, 40, 20))) %>% pad

context("Test the fill functions")

test_that("fill_ functions break with wrong input", {
  expect_error(x_df %>% as.list %>% fill_by_value(y1))
  expect_error(x_df %>% as.list %>% fill_by_function(y1))
  expect_error(x_df %>% as.list %>% fill_by_prevalent(y1))
  expect_error(x_df$y1 %>% as.list %>% fill_by_value(y1))
  expect_error(x_df$y1 %>% as.list %>% fill_by_function(y1))
  expect_error(x_df$y1 %>% as.list %>% fill_by_prevalent(y1))
  expect_error(x_df %>% fill_by_value(y1), NA)
  expect_error(x_df %>% fill_by_function(y1), NA)
  expect_error(x_df %>% fill_by_prevalent(y4), NA)
})

test_that("fill_by_value gives expected outcomes", {
  expect_equal( fill_by_value(x_df, y1)$y1[2], 0)
  expect_equal( fill_by_value(x_df, y1, y2)$y1[2], 0)
  expect_equal( fill_by_value(x_df, y1, y2)$y2[2], 0)
  expect_equal( fill_by_value(x_df, y1, value = 42)$y1[2], 42)
  expect_equal( fill_by_value(x_df, y1, y2, value = 42)$y1[2], 42)
  expect_equal( fill_by_value(x_df, y1, y2, value = 42)$y2[2], 42)
})

test_that("fill_by_function gives expected outcomes", {
  expect_error( fill_by_function(x_df, y1, fun = y2) )
  expect_equal( fill_by_function(x_df, y1)$y1 %>% median, 14.77)
  expect_equal( fill_by_function(x_df, y1, y2)$y1 %>% median, 14.77)
  expect_equal( fill_by_function(x_df, y1, y2)$y2 %>% median, 22.765)
  expect_equal( fill_by_function(x_df, y1, fun = median)$y1 %>% median, 15)
  expect_equal( fill_by_function(x_df, y1, y2, fun = median)$y1 %>% median, 15)
})

test_that("fill_by_prevalent gives expected outcomes", {
  expect_equal( fill_by_prevalent(x_df, y4)$y4[2], "a")
  expect_equal( fill_by_prevalent(x_df, y3)$y3[2], 10)
  expect_equal( fill_by_prevalent(x_df, y3, y4)$y4[2], "a")
  expect_equal( fill_by_prevalent(x_df, y3, y4)$y3[2], 10)
  expect_error( fill_by_prevalent(x_df, y1))
})

test_that("get_the_inds works properly", {
  x <- coffee %>% thicken('day') %>% group_by(time_stamp_day) %>%
    summarise(a = sum(amount)) %>% pad
  x$b <- NA
  cols <- colnames(x)
  make_funargs <- function(x, ...) return(as.list(match.call()))
  no_cols <- make_funargs(x)
  one_col <- make_funargs(x, a)
  two_cols <- make_funargs(x, a, b)

  expect_error(get_the_inds(cols, no_cols))
  expect_equal(get_the_inds(cols, one_col), 2)
  expect_equal(get_the_inds(cols, two_cols), 2:3)
})
