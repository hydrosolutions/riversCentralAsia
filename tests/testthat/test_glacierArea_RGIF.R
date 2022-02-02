

test_that("glacierArea_RGIF can handle problematic input correctly", {

  expect_equal(0, glacierArea_RGIF(0))
  expect_equal(0, glacierArea_RGIF(-1))
  expect_equal(NA, glacierArea_RGIF(NA))

})
