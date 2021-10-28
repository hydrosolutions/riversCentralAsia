test_that("Daily flow duration curve works", {

  Qtest <- tibble::tibble(
    Date = seq.Date(from = lubridate::as_date("2021-01-01"),
                    to = lubridate::as_date("2023-12-31"),
                    by = "day"),
    Q = rep(c(1:182, 183:1), 3)
  )
  Dtest <- computeAnnualFlowDurationCurve(Qtest, "Q", "Date")
  expect_equal(Dtest$na[1], 273)
})

test_that("Monthly flow duration curve works", {

  Qtest <- tibble::tibble(
    Date = seq.Date(from = lubridate::as_date("2020-01-01"),
                    to = lubridate::as_date("2022-12-13"),
                    by = "month"),
    Q = rep(c(1:6, 6:1), 3)
  )
  Dtest <- computeAnnualFlowDurationCurve(Qtest, "Q", "Date")
  expect_equal(Dtest$na[1], 9)
})

test_that("Monthly flow duration curve with different name for date column", {
  Qtest <- tibble::tribble(
    ~type, ~code, ~date, ~data, ~norm, ~resolution,
    "Q", "123", as.Date("2019-01-01"), 10, 2, "mon",
    "Q", "123", as.Date("2019-02-01"), 100, 3, "mon",
    "Q", "123", as.Date("2019-03-01"), 1000, 4, "mon",
    "Q", "123", as.Date("2019-04-01"), 101, 5, "mon",
    "Q", "123", as.Date("2019-05-01"), 1011, 6, "mon",
    "Q", "123", as.Date("2019-06-01"), 1001, 7, "mon",
    "Q", "123", as.Date("2019-07-01"), 1002, 8, "mon",
    "Q", "123", as.Date("2019-08-01"), 1003, 9, "mon",
    "Q", "123", as.Date("2019-09-01"), 1022, 10, "mon",
    "Q", "123", as.Date("2019-10-01"), 1033, 11, "mon",
    "Q", "123", as.Date("2019-11-01"), 1044, 12, "mon",
    "Q", "123", as.Date("2019-12-01"), 104, 13, "mon") |>
    dplyr::select(date, data, type, code) |>
    tidyr::pivot_wider(values_from = data, names_from = c(type, code),
                       names_sep  = "_")
  Dtest <- computeAnnualFlowDurationCurve(Qtest, "Q_123", "date")
  expect_equal(Dtest$HYear[1], 2019)
})
