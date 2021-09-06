test_that("posixct2rsminerveChar produces the expected output", {
  test_date_vec <- c("2018-01-01 01:00:00", "2018-01-01 02:00:00",
                     "2018-01-01 03:00:00")
  test_rsminerve_date_vec <- posixct2rsminerveChar(test_date_vec, "GMT")
  expect_equal("01.01.2018 01:00:00", test_rsminerve_date_vec[[1]][1])
})

test_that("posixct2rsminerveChar does not include time shifts because of winter/summer time", {
  test_date_vec <- c("2018-01-01 01:00:00", "2018-02-01 01:00:00",
                     "2018-03-01 01:00:00", "2018-04-01 01:00:00",
                     "2018-05-01 01:00:00", "2018-06-01 01:00:00")
  test_rsminerve_date_vec <- posixct2rsminerveChar(test_date_vec, "GMT")
  expect_equal("01.06.2018 01:00:00", test_rsminerve_date_vec[[1]][6])
})
