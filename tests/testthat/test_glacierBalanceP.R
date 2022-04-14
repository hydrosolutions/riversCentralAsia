
test_that("Real-life example works as expected", {

 load("tests/testthat/test_glacierBalance_reallifedata.RData")
  #load("test_glacierBalance_reallifedata.RData")

  res <- glacierBalanceP(
    melt_a_eb = test_melt_mma,
    prcp_a_eb = test_prcp_mma,
    rgi_elbands = test_rgi)

  res1 <- res |>
    dplyr::filter(RGIId == res$RGIId[1]) |>
    tidyr::pivot_wider(names_from = Variable, values_from = Value) |>
    dplyr::left_join(test_melt_mma |>
                       tidyr::separate(ID, into = c("RGIId", "layer"),
                                       sep = "_"),
                     by = c("Hyear", "RGIId")) |>
    dplyr::mutate(melt_times_area = Melt*10^(-3)*A_km2*10^6,
                  Qimb_func = glacierImbalAbl(Melt_mma = Melt),
                  Qimb_func = ifelse(Qimb_func < -Q_m3a, -Q_m3a, Qimb_func)) |>
    dplyr::left_join(test_prcp_mma |>
                       tidyr::separate(ID, into = c("RGIId", "layer"),
                                       sep = "_"),
                     by = c("Hyear", "RGIId")) |>
    dplyr::mutate(deltaS_mma = P-Melt,
                  deltaS_m3a = deltaS_mma*10^(-3)*A_km2*10^6)

  ggplot2::ggplot(res1) +
    ggplot2::geom_line(ggplot2::aes(Hyear, Qimb_m3a)) +
    ggplot2::geom_line(ggplot2::aes(Hyear, deltaS_m3a), colour = "red") +
    ggplot2::theme_bw()

  ggplot2::ggplot(res1) +
    ggplot2::geom_line(ggplot2::aes(Hyear, V_km3)) +
    #ggplot2::geom_line(ggplot2::aes(Hyear, deltaS_m3a), colour = "red") +
    ggplot2::theme_bw()

  expect_equal(res1$Qimb_func[dim(res1)[1]], res1$Qimb_m3a[dim(res1)[1]])

})


