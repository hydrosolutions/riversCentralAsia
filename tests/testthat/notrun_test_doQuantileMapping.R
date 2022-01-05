# Load test data
load("hist_fut_sim.RData")

test_that("Quantile mapping of temperature data works", {
  results <- doQuantileMapping(hist_obs_ta, hist_sim_ta, fut_sim_ta)
  mapped_hist_sim <- results[[1]]
  mapped_fut_sim <- results[[2]]

  expect_equal(-3.3, round(mapped_hist_sim$Ta[1], digits = 1))
  expect_equal(4.2, round(mapped_fut_sim$Ta[2000], digits = 1))
})

test_that("Quantile mapping of precipitation data works", {
  results <- doQuantileMapping(hist_obs_pr, hist_sim_pr, fut_sim_pr)
  mapped_hist_sim <- results[[1]]
  mapped_fut_sim <- results[[2]]

  expect_equal(0, round(mapped_hist_sim$Pr[1], digits = 1))
  expect_equal(0.1, round(mapped_fut_sim$Pr[2000], digits = 1))
})

test_that("Example is working.", {
  hist_obs <- tibble::tribble(~Date, ~Basin, ~Pr,
                              "1979-01-01", "K_eb1", 0.1,
                              "1979-01-01", "K_eb2", 0.2,
                              "1979-01-01", "K_eb3", 0.3,
                              "1979-01-02", "K_eb1", 0.4,
                              "1979-01-02", "K_eb2", 0.5,
                              "1979-01-02", "K_eb3", 0.6) |>
    dplyr::mutate(Date = as.Date(Date))
  hist_sim <- hist_obs |>
    dplyr::filter(Basin == "K_eb1") |>
    dplyr::select(-Basin) |>
    dplyr::mutate(Pr = Pr + 1, Model = "A")
  hist_sim <- hist_sim |>
    dplyr::add_row(hist_sim |>
                     dplyr::mutate(Pr = Pr + 2, Model = "B"))
  fut_sim <- hist_sim |>
    dplyr::mutate(Scenario = "a") |>
    dplyr::add_row(hist_sim |>
                     dplyr::mutate(Pr = Pr + 1, Scenario = "b"))
  fut_sim <- fut_sim |>
    dplyr::add_row(fut_sim |>
                   dplyr::mutate(Date = as.Date(Date) + 2))

  results <- doQuantileMapping(hist_obs, hist_sim, fut_sim)
})





