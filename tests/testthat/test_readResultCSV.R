test_that("readResultsCSV returns expected", {

  filepath <- normalizePath(file.path("test_readResultCSV.csv"))
  result <- readResultCSV(filepath)

  expect_false(is.null(result))

  testvalue <- result |>
    dplyr::filter(model == "GSM 1",
                  variable == "Qglacier",
                  date == lubridate::as_datetime("2013-09-09 00:00:00",
                                                 tz = "UTC"))

  expect_equal(169, dim(result)[1])
  expect_equal(5, dim(result)[2])
  expect_equal(0.02953923, testvalue$value)

})


test_that("readResultsCSV also reads ;-separated files", {

  filepath <- normalizePath(file.path("test_readResultCSV_semicolon.csv"))
  result <- readResultCSV(filepath)

  expect_false(is.null(result))

  testvalue <- result |>
    dplyr::filter(model == "So_Sokh_eb20",
                  variable == "Qglacier",
                  date == lubridate::as_datetime("1981-02-01 01:00:00",
                                                 tz = "UTC"))

  expect_equal(1634, dim(result)[1])
  expect_equal(5, dim(result)[2])
  expect_equal(0.00118812, testvalue$value)


})

test_that("reads even funny file format", {

  filepath <- normalizePath(file.path("Koksu_Results_Kichkinesay.csv"))
  result <- readResultCSV(filepath)

  expect_false(is.null(result))

  testvalue <- result |>
    dplyr::filter(model == "Kichkinesay",
                  variable == "QDown",
                  date == lubridate::as_datetime("1979-01-01 00:00:00",
                                                 tz = "UTC"))

  expect_equal(24, dim(result)[1])
  expect_equal(5, dim(result)[2])
  expect_equal(2.240976, testvalue$value)

})

test_that("reads also this result file correctly", {

  filepath <- normalizePath(file.path("test_readResultCSV2.csv"))
  result <- readResultCSV(filepath)

  expect_false(is.null(result))

  testvalue <- result |>
    dplyr::filter(model == "Comparator 1",
                  variable == "QSimulation",
                  date == lubridate::as_datetime("1979-01-01",
                                                 tz = "UTC"))

  expect_equal(2193, dim(result)[1])
  expect_equal(5, dim(result)[2])
  expect_equal(1.908915, testvalue$value)

})
