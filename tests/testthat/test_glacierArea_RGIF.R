

test_that("glacierArea_RGIF can handle problematic input correctly", {

  expect_equal(0, glacierArea_RGIF(0))
  expect_equal(0, glacierArea_RGIF(-1))
  expect_equal(NA, glacierArea_RGIF(NA))

})

test_that("glacierArea_RGIF produces sensible results", {

  A_km2 <- glacierArea_RGIF(1)
  V_km3 <- glacierVolume_RGIF(A_km2)
  expect_equal(1, V_km3)

})
