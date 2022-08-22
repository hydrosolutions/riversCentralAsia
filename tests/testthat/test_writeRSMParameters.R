test_that("writeRSMParameters returns expected", {

  readfilepath <- normalizePath(file.path("RSM_parameters_write_test_initial.txt"),
                                mustWork = FALSE)
  writefilepath <- normalizePath(file.path("RSM_parameters_write_test.txt"),
                                 mustWork = FALSE)

  params <- riversCentralAsia::readRSMParameters(readfilepath)

  newparams <- params |>
    dplyr::mutate(Values = ifelse((Object == "HBV92" & Parameters == "Kgl [1/d]"),
                                  Values*2, Values))

  expect_null(riversCentralAsia::writeRSMParameters(newparams, writefilepath))
  testparams <- riversCentralAsia::readRSMParameters(writefilepath)

  expect_equal(sum(sum(params != testparams, na.rm = TRUE)), 0)
})


