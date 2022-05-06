test_that("getChunkSize returns as expected", {
  start_date <- lubridate::as_datetime("01.20.2021 00:00:00",
                                       format = "%m.%d.%Y %H:%M:%S")
  end_date <- lubridate::as_datetime("01.25.2021 00:00:00",
                                     format = "%m.%d.%Y %H:%M:%S")
  recordingTimeStep <- "3600"
  expect_equal(122, getChunkSize(start_date, end_date, recordingTimeStep))
})

test_that("getChunkSize try numeric, hourly recordingTimeStep", {
  start_date <- lubridate::as_datetime("01.20.2021 00:00:00",
                                       format = "%m.%d.%Y %H:%M:%S")
  end_date <- lubridate::as_datetime("01.25.2021 00:00:00",
                                     format = "%m.%d.%Y %H:%M:%S")
  recordingTimeStep <- 60*60
  expect_equal(122, getChunkSize(start_date, end_date, recordingTimeStep))
})

test_that("getChunkSize try numeric, daily recordingTimeStep", {
  start_date <- lubridate::as_datetime("01.20.2021 00:00:00",
                                       format = "%m.%d.%Y %H:%M:%S")
  end_date <- lubridate::as_datetime("01.25.2021 00:00:00",
                                     format = "%m.%d.%Y %H:%M:%S")
  recordingTimeStep <- 60*60*24
  expect_equal(7, getChunkSize(start_date, end_date, recordingTimeStep))
})

test_that("getChunkSize try numeric, decadal recordingTimeStep", {
  start_date <- lubridate::as_datetime("01.20.2021 00:00:00",
                                       format = "%m.%d.%Y %H:%M:%S")
  end_date <- lubridate::as_datetime("01.25.2021 00:00:00",
                                     format = "%m.%d.%Y %H:%M:%S")
  recordingTimeStep <- 60*60*24*10
  expect_equal(NULL, getChunkSize(start_date, end_date, recordingTimeStep))
})



test_that("getChunkSize returns as expected", {
  start_date <- lubridate::as_datetime("01.01.1991 01:00:00",
                                       format = "%m.%d.%Y %H:%M:%S")
  end_date <- lubridate::as_datetime("12.31.2013 23:00:00",
                                     format = "%m.%d.%Y %H:%M:%S")
  recordingTimeStep <- "2592000"  # Monthly 60*60*24*30, or also possible 60*60*24*365/12
  expect_equal(278, getChunkSize(start_date, end_date, recordingTimeStep))
})

test_that("getChunkSize returns as expected", {
  start_date <- lubridate::as_datetime("01.01.1991 01:00:00",
                                       format = "%m.%d.%Y %H:%M:%S")
  end_date <- lubridate::as_datetime("12.31.2013 23:00:00",
                                     format = "%m.%d.%Y %H:%M:%S")
  recordingTimeStep <- "2292000"  # bi-monthly
  expect_equal(NULL, getChunkSize(start_date, end_date, recordingTimeStep))
})
