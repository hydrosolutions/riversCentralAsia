test_that("decadeMaker works as expected", {

  start = lubridate::as_date("2000-01-01")
  end = lubridate::as_date("2020-12-31")

  beginn_dates <- decadeMaker(start, end, 'start')
  mid_dates <- decadeMaker(start, end, 'mid')
  middle_dates <- decadeMaker(start, end, 'middle')
  end_dates <- decadeMaker(start, end, 'end')

  # Test consistent length of date vectors
  expect_equal(length(beginn_dates$date), length(mid_dates$date))
  expect_equal(length(beginn_dates$date), length(middle_dates$date))
  expect_equal(length(beginn_dates$date), length(end_dates$date))

  # Test mid and middle produce same result
  expect_equal(mid_dates, middle_dates)

  # Test that the first three dates are as expected
  expect_equal(beginn_dates$date[1:3],
               lubridate::as_date(c("2000-01-01", "2000-01-11", "2000-01-21")))
  expect_equal(mid_dates$date[1:3],
               lubridate::as_date(c("2000-01-05", "2000-01-15", "2000-01-25")))
  expect_equal(end_dates$date[1:3],
               lubridate::as_date(c("2000-01-10", "2000-01-20", "2000-01-31")))
})
