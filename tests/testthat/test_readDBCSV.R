test_that("Loading the test file works", {
  filename <- "hepler_test_load_minerve_input_csv.csv"
  test_data <- readDBCSV(filename)
  if ("type" %in% colnames(test_data)) {
    expect_equal(test_data$date[1], lubridate::as_datetime("1981-01-01 01:00:00"))
    expect_equal(test_data$type[1], "T")
  } else {
    expect_equal(test_data$Date[1], lubridate::as_datetime("1981-01-01 01:00:00"))
    expect_equal(test_data$Sensor[1], "T")
  }
})


test_that("Loading the other test file works", {
  filename <- "test_translateCSVtoDST.csv"
  test_data <- readDBCSV(filename)
  if ("type" %in% colnames(test_data)) {
    expect_equal(test_data$date[1], lubridate::as_datetime("1981-01-01 23:00:00"))
    expect_equal(test_data$type[1], "T")
  } else {
    expect_equal(test_data$Date[1], lubridate::as_datetime("1981-01-01 23:00:00"))
    expect_equal(test_data$Sensor[1], "T")
  }
})

test_that("Loading the glacier forcing test file works", {
  test_data <- readDBCSV("hepler_test_load_minerve_glacier_forcing_input_csv.csv")
  if ("type" %in% colnames(test_data)) {
    expect_equal(test_data$date[1], lubridate::as_datetime("1981-01-01 01:00:00"))
    expect_equal(test_data$type[1], "T")
  } else {
    expect_equal(test_data$Date[1], lubridate::as_datetime("1981-01-01 01:00:00"))
    expect_equal(test_data$Sensor[1], "T")
  }
})

