test_that("readSelectionCHK returns expected", {

  filepath <- normalizePath(file.path("test_writeSelectionCHK.chk"),
                            mustWork = FALSE)
  Object_IDs <- c("SOCONT 1", "SOCONT 2", "SOCONT 3")
  data <- tibble::tibble(
    Model = rep("Tutorial_Model", length(Object_IDs)),
    Object = rep("SOCONT", length(Object_IDs)),
    ID = Object_IDs,
    Variable = rep("Qtot (m3/s)")
  )
  name <- "SOCONT Qtot"
  writeSelectionCHK(filepath, data, name)

  testlist <- readSelectionCHK(filepath)
  expect_equal(name, testlist[[1]])
})


