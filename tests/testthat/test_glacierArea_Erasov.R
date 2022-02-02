

test_that("glacierArea_Erasov can handle problematic input correctly", {

  expect_equal(0, glacierArea_Erasov(0))
  expect_equal(0, glacierArea_Erasov(-1))
  expect_equal(NA, glacierArea_Erasov(NA))

})
