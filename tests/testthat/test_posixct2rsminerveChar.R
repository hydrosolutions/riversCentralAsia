test_that("posixct2rsminerveChar produces the expected output", {
  test_date_vec <- c("2018-01-01 01:00:00", "2018-01-01 02:00:00",
                     "2018-01-01 03:00:00")
  test_rsminerve_date_vec <- posixct2rsminerveChar(test_date_vec)
  expect_equal("01.01.2018 01:00:00", test_rsminerve_date_vec[[1]][1])
})
