test_that("The assess_fc_equal works as expected", {

  filepath <- normalizePath(file.path("test_readResultCSV2.csv"))
  result <- readResultCSV(filepath) |>
    dplyr::filter(model == "Comparator 1")

  set.seed(1)

  temp <- result |>
    dplyr::transmute(date = as.Date(date),
              obs = value + value * stats::rnorm(dim(result)[1], 0, 0.1),
              pred = value,
              per = lubridate::month(date),
              year = lubridate::year(date)) |>
    dplyr::group_by(year, per) |>
    dplyr::summarise(date = dplyr::first(date),
                     obs = mean(obs),
                     pred = mean(pred)) |>
    dplyr::ungroup() |>
    dplyr::select(-year)

  test <- assess_fc_qual(temp, FALSE)

  expect_equal(79, round(test[[2]]))

})
