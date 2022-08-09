test_that("The convert2HYY works as expected", {

  result <- convert2HYY(
    data2convert = ChirchikRiverBasin |> dplyr::filter(resolution == "mon"),
    stationCode = "16300",
    typeSel = "Q")

  expect_equal(79, dim(result)[1])
  expect_equal(4, dim(result)[2])
  expect_lt(abs(32.0847 - result$Q_mean_ws[1]), 0.01)

})
