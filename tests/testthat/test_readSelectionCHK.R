test_that("readSelectionCHK returns expected", {

  filepath <- normalizePath(file.path("test_selection.chk"))

  xmldata <- readSelectionCHK(filepath)
  selection_name <- xmldata[[1]]
  selection_data <- xmldata[[2]]

  expect_equal(selection_name, "New selection")
  expect_equal(selection_data$Model[1], "Model Koksu")
  expect_equal(selection_data$Variable[10], "WH (-)")
})


