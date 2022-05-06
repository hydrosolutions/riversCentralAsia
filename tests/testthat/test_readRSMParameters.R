test_that("read parameters correctly", {

  filepath <- normalizePath(file.path("Tutorial_Parameters.txt"))
  testvar <- readRSMParameters(filepath)
  val1 <- testvar %>% dplyr::filter(Object == "Comparator") %>%
    dplyr::select(Zone)
  expect_equal("A", val1$Zone)

  filepath <- normalizePath(file.path("Model_test_PAR.txt"))
  testvar <- readRSMParameters(filepath)
  val2 <- testvar %>% dplyr::filter(Object == "HBV92",
                                    Parameters == "Kr [1/d]")
  expect_equal(0.3, val2$Values)

})
