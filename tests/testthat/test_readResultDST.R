test_that("readResultsDXT returns expected", {
  filepath <- normalizePath(file.path("Tutorial01-results.dst"))
  start_date <- "09.02.2013 00:00:00"  # format = "%m.%d.%Y %H:%M:%S"
  end_date <- "09.09.2013 00:00:00"  # format = "%m.%d.%Y %H:%M:%S"
  recordingTimeStep <- "3600"
  chunk_size <- getChunkSize(
    lubridate::as_datetime(start_date,format = "%m.%d.%Y %H:%M:%S"),
    lubridate::as_datetime(end_date, format = "%m.%d.%Y %H:%M:%S"),
    recordingTimeStep
  )

  result <- readResultDST(filepath, chunk_size)

  expect_false(is.null(result))

  testvalue <- result %>%
    dplyr::filter(Variable == "Station:ETP",
                  Object == "Estacion SOCONT 3",
                  Datetime == lubridate::as_datetime("2013-09-09 00:00:00"))

  expect_equal(12168, dim(result)[1])
  expect_equal(4, dim(result)[2])
  expect_equal(0, testvalue$Value)

})

test_that("readResultsDXT returns expected for the Sokh example", {
  filepath <- normalizePath(file.path("Test-Sokh-results.dst"))
  start_date <- lubridate::as_datetime("01.01.1991 01:00:00",
                                       format = "%m.%d.%Y %H:%M:%S")
  end_date <- lubridate::as_datetime("12.31.2013 23:00:00",
                                     format = "%m.%d.%Y %H:%M:%S")
  recordingTimeStep <- "2592000"
  chunk_size <- getChunkSize(start_date, end_date, recordingTimeStep)

  result <- readResultDST(filepath, chunk_size)

  expect_false(is.null(result))

  testvalue <- result %>%
    dplyr::filter(Variable == "GSM:Qglacier",
                  Object == "Akterek_eb3",
                  Datetime == lubridate::as_datetime("2003-09-01 01:00:00"))

  expect_equal(554, dim(result)[1])
  expect_equal(4, dim(result)[2])
  expect_equal(16.75677, testvalue$Value)

})

test_that("readResultsDXT returns expected for the Sokh example", {
  filepath <- normalizePath(file.path("Test-Sokh-results-full.dst"))
  start_date <- lubridate::as_datetime("01.01.1991 01:00:00",
                                       format = "%m.%d.%Y %H:%M:%S")
  end_date <- lubridate::as_datetime("12.31.2013 23:00:00",
                                     format = "%m.%d.%Y %H:%M:%S")
  recordingTimeStep <- "2592000"
  chunk_size <- getChunkSize(start_date, end_date, recordingTimeStep)

  result <- readResultDST(filepath, chunk_size)

  expect_false(is.null(result))

  testvalue <- result %>%
    dplyr::filter(Variable == "GSM:Qglacier",
                  Object == "Akterek_eb3",
                  Datetime == lubridate::as_datetime("2003-09-01 01:00:00"))

  expect_equal(1939, dim(result)[1])
  expect_equal(4, dim(result)[2])
  expect_equal(16.75677, testvalue$Value)

})
