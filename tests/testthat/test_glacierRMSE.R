

test_that("glacierRSME works as expected", {

  parameters <- c(1, 0)
  temperature <- tibble::tibble(year = 2001:2010,
                                 "RGI60-13.00001_1" = 1:10*0-5,
                                 "RGI60-13.00002_1" = 1:10*0+5)
  hugonnet <- tibble::tibble(rgiid = c(rep("RGI60-13.00001", 10),
                                       rep("RGI60-13.00002", 10)),
                             start = lubridate::as_date(
                               paste0(c(2001:2010, 2001:2010),"-01-01")),
                             dmdtda = c(rep(-0.5, 10), rep(-0.5, 10)))
  rmse <- glacierRMSE(parameters = parameters,
                      temperature = temperature,
                      hugonnet = hugonnet,
                      index = 1)

  expect_lte(rmse, 1.58114)

})

test_that("Default index works as expected", {

  parameters <- c(1, 0)
  temperature <- tibble::tibble(year = 2001:2010,
                                "RGI60-13.00001_1" = 1:10*0-5,
                                "RGI60-13.00002_1" = 1:10*0+5)
  hugonnet <- tibble::tibble(rgiid = c(rep("RGI60-13.00001", 10),
                                       rep("RGI60-13.00002", 10)),
                             start = lubridate::as_date(
                               paste0(c(2001:2010, 2001:2010),"-01-01")),
                             dmdtda = c(rep(-0.5, 10), rep(-0.5, 10)))
  rmse <- glacierRMSE(parameters = parameters,
                      temperature = temperature,
                      hugonnet = hugonnet)

  expect_equal(length(rmse), 2)

})

test_that("Shorter observation periods are treated as expected", {

  parameters <- c(1, 0)
  temperature <- tibble::tibble(year = 2001:2010,
                                "RGI60-13.00001_1" = 1:10*0-5,
                                "RGI60-13.00002_1" = 1:10*0+5)
  hugonnet <- tibble::tibble(rgiid = c(rep("RGI60-13.00001", 1),
                                       rep("RGI60-13.00002", 1)),
                             start = lubridate::as_date(
                               paste0(c(2010, 2010),"-01-01")),
                             dmdtda = c(rep(-0.5, 1), rep(-0.5, 1)))
  rmse <- glacierRMSE(parameters = parameters,
                      temperature = temperature,
                      hugonnet = hugonnet)

  expect_equal(rmse[1], 0.5)

})



