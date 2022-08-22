test_that("Read correct monthly input file", {

  testData <- loadTabularData(
    fPath = "./",  # "tests/testthat/",
    fName = "test_loadTabularData_monthly.csv",
    code = "test",
    stationName = "test",
    rName = "test",
    rBasin = "test",
    dataType = "Q",
    units = "m3/s"
  )

  expect_equal(36, dim(testData)[1])
})

test_that("Read correct decadal input file", {

  testData <- loadTabularData(
    fPath = "./",  # "tests/testthat/",
    fName = "test_loadTabularData_decadal.csv",
    code = "test",
    stationName = "test",
    rName = "test",
    rBasin = "test",
    dataType = "Q",
    units = "m3/s"
  )

  expect_equal(3*36, dim(testData)[1])
})

test_that("Read incorrect monthly input file", {

  testData <- loadTabularData(
    fPath = "./",  # tests/testthat/",
    fName = "test_loadTabularData_monthlyError.csv",
    code = "test",
    stationName = "test",
    rName = "test",
    rBasin = "test",
    dataType = "Q",
    units = "m3/s"
  )

  expect_null(testData)
})
