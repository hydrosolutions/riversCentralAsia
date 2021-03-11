context("Loading of RS Minerve csv data")

test_that("Loading the test file works", {
  test_data <- load_minerve_input_csv("hepler_test_load_minerve_input_csv.csv")
})
