test_that("reading of forcing string works as expected", {

  test_string <- tibble::tibble(Station = c("Station", "X", "Y", "Z", "Sensor",
                                    "Category", "Unit", "Interpolation",
                                    "01.01.1980 00:00:00", "02.01.1980 00:00:00",
                                    "03.01.1980 00:00:00", "04.01.1980 00:00:00"),
                        hru_1 = c("hru_1", "234", "345", "123", "P",
                                  "Precipitation", "mm/h", "Linear", "0", "1",
                                  "2", "3"),
                        hru_2 = c("hru_2", "234", "345", "123", "P",
                                  "Precipitation", "mm/h", "Linear", "0", "1",
                                  "2", "3"))

  test_output <- readForcingSTR(test_string)

  expect_equal(0, test_output$Value[1])
})
