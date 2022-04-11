test_that("Loading the test file works", {
  test_data <- load_minerve_input_csv("hepler_test_load_minerve_input_csv.csv")
  expect_equal(test_data$date[1], lubridate::as_datetime("1981-01-01 01:00:00"))
  expect_equal(test_data$type[1], "T")
})

test_that("Loading the glacier forcing test file works", {
  test_data <- load_minerve_input_csv("hepler_test_load_minerve_glacier_forcing_input_csv.csv")
  expect_equal(test_data$date[1], lubridate::as_datetime("1981-01-01 01:00:00"))
  expect_equal(test_data$type[1], "T")
})

