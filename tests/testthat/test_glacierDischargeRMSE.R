# Write tests for daily temperature input
test_that("glacierDischargeRSME can handle both daily and annual temperature input", {

  parameters_daily <- c(2, 0)
  parameters_annual <- c(20, -10)
  dates <- seq(as.Date("2000-01-01"), as.Date("2003-12-31"), 1)
  temperature <- tibble::tibble(date = dates,
                                "RGI60-13.00001_1" = 1:length(dates)*0-5,
                                "RGI60-13.00002_1" = 1:length(dates)*0+5,
                                "RGI60-13.00002_2" = 1:length(dates)*0+1)
  miles <- tibble::tibble(RGIID = c("RGI60-13.00001", "RGI60-13.00002"),
                          totAbl = c(0.5*10^6, 10^6),
                          Area_m2 = c(10^6, 2*10^6))
  rmse_daily <- glacierDischargeRMSE(
    parameters = parameters_daily,
    temperature = temperature,
    observed = miles,
    index = 1)
  rmse_annual <- glacierDischargeRMSE(
    parameters = parameters_annual,
    temperature = temperature |>
      dplyr::mutate(year = lubridate::year(date)) |>
      dplyr::select(-date) |>
      dplyr::group_by(year) |>
      dplyr::summarise(dplyr::across(dplyr::starts_with("RGI"), mean)) |>
      dplyr::ungroup(),
    observed = miles,
    index = 1)

  # Calculate melt
  melt <- glacierMelt_TI(temperature = temperature |>
                           dplyr::select(-.data$date),
                         MF = as.numeric(parameters_daily[1]),
                         threshold_temperature = as.numeric(parameters_daily[2]))

  # reformat and compare to observed melt
  cal <- melt |>
    tibble::as_tibble() |>
    dplyr::mutate(year = lubridate::year(temperature$date)) |>
    tidyr::pivot_longer(-.data$year, names_to = "ID", values_to = "melt_mma") |>
    dplyr::group_by(year, ID) |>
    dplyr::summarise(melt_mma = sum(melt_mma)) |>
    dplyr::ungroup() |>
    tidyr::separate(.data$ID, into = c("RGIId", "layer"), sep = "_") |>
    dplyr::group_by(RGIId) |>
    dplyr::summarise(melt_mma = mean(melt_mma)) |>
    dplyr::ungroup() |>
    dplyr::left_join(miles |> dplyr::select(RGIID, totAbl, Area_m2),
                     by = c("RGIId" = "RGIID")) |>
    dplyr::mutate(totAbl = totAbl / Area_m2 * 10^3) |>  # to mm/a
    tidyr::drop_na() |>
    dplyr::group_by(RGIId) |>
    dplyr::summarise(rsme =sqrt(sum((.data$melt_mma - .data$totAbl)^2)))

  expect_equal(rmse_annual, -400)
  expect_lte(rmse_daily - (-1)*cal$rsme[1], 10^(-3))

})

test_that("glacierDischargeRSME works as expected for annual temperature input", {

  parameters <- c(20, -10)
  temperature <- tibble::tibble(year = 2001:2010,
                                 "RGI60-13.00001_1" = 1:10*0-5,
                                 "RGI60-13.00002_1" = 1:10*0+5)
  miles <- tibble::tibble(RGIID = c(rep("RGI60-13.00001", 10),
                                    rep("RGI60-13.00002", 10)),
                          totAbl = c(rep(0.5*10^6, 10), rep(10^6, 10)),
                          Area_m2 = c(rep(10^6, 10), rep(2*10^6, 10)))
  rmse <- glacierDischargeRMSE(
    parameters = parameters,
    temperature = temperature,
    observed = miles,
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
    dplyr::group_by(RGIId, layer) |>
    dplyr::summarise(melt_mma = mean(melt_mma)) |>
    dplyr::ungroup() |>
    dplyr::left_join(miles |> dplyr::select(RGIID, totAbl, Area_m2),
                     by = c("RGIId" = "RGIID")) |>
    dplyr::mutate(totAbl = totAbl / Area_m2 * 10^3) |>  # to mm/a
    tidyr::drop_na() |>
    dplyr::group_by(RGIId) |>
    dplyr::summarise(rsme =sqrt(sum((.data$melt_mma - .data$totAbl)^2)))

  expect_lte(rmse - (-1)*cal$rsme[1], 10^(-3))

})

test_that("Default index works as expected for annual temperature input", {

  parameters <- c(1, 0)
  temperature <- tibble::tibble(year = 2001:2010,
                                "RGI60-13.00001_1" = 1:10*0-5,
                                "RGI60-13.00002_1" = 1:10*0+5)
  miles <- tibble::tibble(RGIID = c(rep("RGI60-13.00001", 10),
                                       rep("RGI60-13.00002", 10)),
                          totAbl = c(rep(0.5*10^6, 10), rep(0.5*10^6, 10)),
                          Area_m2 = c(rep(10^6, 10), rep(10^7, 10)))
  rmse <- glacierDischargeRMSE(
    parameters = parameters,
    temperature = temperature,
    observed = miles)

  expect_equal(length(rmse), 2)

})





