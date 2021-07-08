test_that("Oerlemans Model runs with correct input", {
  glaciers <- dplyr::tibble(ID = c(1, 2, 3),
                           Lmax = c(500, 5000, 13000),
                           Slope = c(30, 16, 20))
  temperature_annomaly <- dplyr::tibble(Year = c(2000:2010),
                                        V1 = seq(0, 5,  0.5),
                                        V2 = seq(0, 2,  0.2),
                                        V3 = seq(0, 2,  0.2))
  precipitation <- dplyr::tibble(Year = c(2000:2010),
                                 V1 = seq(0.7, 0.705,  0.0005),
                                 V2 = seq(0.7, 0.5,  -0.02),
                                 V3 = seq(1.500, 1.505,  0.0005))
  test_data <- OerlemansGlacierLengthModel(temperature_annomaly, precipitation,
                                           0, glaciers)
  dL <- test_data[[1]]
  L <- test_data[[2]]
  expect_equal(dL$V1[1], 0)
  expect_equal(L$V1[1], glaciers$Lmax[1]/1000)
})
