

test_that("glacierImbalAbl works as expected.", {

  expect_equal(c(NA, 0, -8648), glacierImbalAbl(c(-1, 0, 10)))

})


