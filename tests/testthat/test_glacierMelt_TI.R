

test_that("glacierMelt_TI works as expected", {

  number_of_glaciers <- 10
  number_of_days <- 50*365
  temperature <- matrix(1, nrow = number_of_days, ncol = number_of_glaciers)
  colnames(temperature) <- paste0("Gl", 1:number_of_glaciers)
  # Generate sample melt factors
  MF <- temperature[1, ] * 0 + 1:number_of_glaciers
  # Calculate glacier melt assuming a threshold temperature for glacier melt of
  # 1 degree Celcius.
  melt <- glacierMelt_TI(temperature, MF, threshold_temperature = 0)

  expect_equal(as.numeric(melt[1,1]), 1)
  expect_equal(as.numeric(melt[1,10]), 10)

})



