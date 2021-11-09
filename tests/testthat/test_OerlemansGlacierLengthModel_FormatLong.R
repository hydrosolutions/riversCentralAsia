test_that("Oerlemans Model (format long) runs with correct input", {
  glaciers <- dplyr::tibble(ID = c(1, 2, 3),
                            Lmax = c(500, 5000, 13000),
                            Slope = c(30, 16, 20))
  temperature_annomaly <-
    rbind(tidyr::tibble(Year = c(2000:2010),
                        RCP = "RCP1",
                        Model = "ModelA",
                        V1 = seq(0, 5,  0.5),
                        V2 = seq(0, 2,  0.2),
                        V3 = seq(0, 2,  0.2)) |>
            tidyr::pivot_longer(dplyr::starts_with("V"),
                                values_to = "Ta [deg K]", names_to = "Glacier"),
          tidyr::tibble(Year = c(2000:2010),
                        RCP = "RCP1",
                        Model = "ModelB",
                        V1 = seq(0.1, 5.1,  0.5),
                        V2 = seq(0.2, 2.2,  0.2),
                        V3 = seq(0.1, 2.1,  0.2)) |>
            tidyr::pivot_longer(dplyr::starts_with("V"),
                                values_to = "Ta [deg K]", names_to = "Glacier"),
          tidyr::tibble(Year = c(2000:2010),
                        RCP = "RCP2",
                        Model = "ModelA",
                        V1 = seq(0.8, 5.8,  0.5),
                        V2 = seq(0.9, 2.9,  0.2),
                        V3 = seq(0.8, 2.9,  0.2)) |>
            tidyr::pivot_longer(dplyr::starts_with("V"),
                                values_to = "Ta [deg K]", names_to = "Glacier"),
          tidyr::tibble(Year = c(2000:2010),
                        RCP = "RCP2",
                        Model = "ModelB",
                        V1 = seq(0.4, 5.4,  0.5),
                        V2 = seq(0.5, 2.5,  0.2),
                        V3 = seq(0.4, 2.4,  0.2)) |>
            tidyr::pivot_longer(dplyr::starts_with("V"),
                                values_to = "Ta [deg K]", names_to = "Glacier")
    )
  precipitation <-
    rbind(dplyr::tibble(Year = c(2000:2010),
                        RCP = "RCP1",
                        Model = "ModelA",
                        V1 = seq(0.7, 0.705,  0.0005),
                        V2 = seq(0.7, 0.5,  -0.02),
                        V3 = seq(1.500, 1.505,  0.0005)) |>
            tidyr::pivot_longer(dplyr::starts_with("V"),
                                values_to = "P [m/a]", names_to = "Glacier"),
          dplyr::tibble(Year = c(2000:2010),
                        RCP = "RCP1",
                        Model = "ModelB",
                        V1 = seq(0.7, 0.705,  0.0005),
                        V2 = seq(0.7, 0.5,  -0.02),
                        V3 = seq(1.500, 1.505,  0.0005)) |>
            tidyr::pivot_longer(dplyr::starts_with("V"),
                                values_to = "P [m/a]", names_to = "Glacier"),
          dplyr::tibble(Year = c(2000:2010),
                        RCP = "RCP2",
                        Model = "ModelA",
                        V1 = seq(0.7, 0.705,  0.0005),
                        V2 = seq(0.7, 0.5,  -0.02),
                        V3 = seq(1.500, 1.505,  0.0005)) |>
            tidyr::pivot_longer(dplyr::starts_with("V"),
                                values_to = "P [m/a]", names_to = "Glacier"),
          dplyr::tibble(Year = c(2000:2010),
                        RCP = "RCP2",
                        Model = "ModelB",
                        V1 = seq(0.7, 0.705,  0.0005),
                        V2 = seq(0.7, 0.5,  -0.02),
                        V3 = seq(1.500, 1.505,  0.0005)) |>
            tidyr::pivot_longer(dplyr::starts_with("V"),
                                values_to = "P [m/a]", names_to = "Glacier"))
  test_data <- OerlemansGlacierLengthModel_FormatLong(temperature_annomaly,
                                                      precipitation, 0,
                                                      glaciers)
  dL <- test_data[[1]]
  L <- test_data[[2]]
  expect_equal(dL$`dL(t) [km]`[1], 0)
  expect_equal(L$`L(t) [km]`[1], glaciers$Lmax[1]/1000)
})


test_that("Oerlemans Model (format long) runs with realistic glacier names", {

  load("test_OerlemansGlacierLengthModel_FormatLong.RData")

  test_data <- OerlemansGlacierLengthModel_FormatLong(
    annual_temperature_annomaly = annual_temperature_annomaly,
    annual_precipitation = annual_precipitation,
    years_baseline_period = 0,
    rgi_data_set = rgi)

  dL <- test_data[[1]]
  L <- test_data[[2]]
  expect_equal(dL$`dL(t) [km]`[1], 0)
  expect_equal(L$`L(t) [km]`[1], rgi$Lmax[1]/1000)

})






