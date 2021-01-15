context("Aggregation of sub-monthly time series data")

correct_data_tibble_only_Q <- tibble::tribble(
  ~type, ~code, ~date, ~data,
  "Q",   "123", as.Date("2019-01-15"), 10,
  "Q",   "123", as.Date("2019-02-15"), 10,
  "Q",   "123", as.Date("2019-03-15"), 10,
  "Q",   "123", as.Date("2019-04-15"), 10,
  "Q",   "123", as.Date("2019-05-15"), 10,
  "Q",   "123", as.Date("2019-06-15"), 10,
  "Q",   "123", as.Date("2019-07-15"), 10,
  "Q",   "123", as.Date("2019-08-15"), 10,
  "Q",   "123", as.Date("2019-09-15"), 10,
  "Q",   "123", as.Date("2019-10-15"), 10,
  "Q",   "123", as.Date("2019-11-15"), 10,
  "Q",   "123", as.Date("2019-12-15"), 10,
)

correct_funcTypeLib_only_Q <- list("mean" = c("Q"))

test_that("The aggregation sums up as expected", {

})
