

test_that("glacierRSME works as expected", {

  parameters <- c(20, -10)
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

  # Calculate melt
  melt <- glacierMelt_TI(temperature = temperature |>
                           dplyr::select(-.data$year),
                         MF = as.numeric(parameters[1]),
                         threshold_temperature = as.numeric(parameters[2]))

  # reformat and compare to observed melt
  cal <- melt |>
    tibble::as_tibble() |>
    dplyr::mutate(year = temperature$year) |>
    tidyr::pivot_longer(-.data$year, names_to = "ID", values_to = "melt_mma") |>
    tidyr::separate(.data$ID, into = c("RGIId", "layer"), sep = "_") |>
    dplyr::left_join(hugonnet |>
                       dplyr::mutate(year = lubridate::year(start),
                                     # dmdtda is glacier elevation change in m water equivalents per year. It is
                                     # negative for glacier mass loss and positive for glacier mass gain. To
                                     # compare it to glacier melt in mm/a of we multiply dmdtda by -1000.
                                     obs_melt_mma = ifelse(.data$dmdtda > 0, NA,
                                                           -.data$dmdtda*1000)) |>
                       dplyr::select(rgiid, year, obs_melt_mma),
                     by = c("RGIId" = "rgiid", "year" = "year")) |>
    tidyr::drop_na() |>
    dplyr::group_by(RGIId) |>
    dplyr::summarise(rsme =sqrt(sum((.data$melt_mma - .data$obs_melt_mma)^2)))

  expect_lte(rmse, cal$rsme[1])

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

  expect_equal(rmse[1], 500)

})



