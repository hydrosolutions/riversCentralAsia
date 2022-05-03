

test_that("glacierRSME works as expected", {

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
    miles = miles,
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
    dplyr::left_join(miles |> dplyr::select(RGIID, totAbl, Area_m2),
                     by = c("RGIId" = "RGIID")) |>
    tidyr::drop_na() |>
    dplyr::mutate(totAbl = totAbl / Area_m2 * 10^3) |>  # to mm/a
    dplyr::group_by(RGIId) |>
    dplyr::summarise(rsme =sqrt(sum((.data$melt_mma - .data$totAbl)^2)))

  expect_lte(rmse, cal$rsme[1])

})

test_that("Default index works as expected", {

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
    miles = miles)

  expect_equal(length(rmse), 2)

})





