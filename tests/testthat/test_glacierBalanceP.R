test_that("Toy example for small glacier works as expected", {

  melt_a_eb <- tibble::tibble(
    Hyear = c(2000:2100),
    ID = "RGI60-13.00001_1",
    Melt = seq(0, 5000, length.out = length(c(2000:2100)))
  )

  prcp_a_eb <- melt_a_eb |>
    dplyr::rename(P = Melt) |>
    dplyr::mutate(P = 2000)

  rgi_elbands = tibble::tibble(
    RGIId = "RGI60-13.00001",
    A_km2 = 1,
    thickness_m = 50,
    Area_tot_glacier_km2 = A_km2,
    ID = "RGI60-13.00001_1"
  )

  res <- glacierBalanceP(melt_a_eb, prcp_a_eb, rgi_elbands) |>
    tibble::add_row(melt_a_eb |>
                      dplyr::transmute(Hyear = Hyear,
                                       RGIId = gsub("_1", "", ID),
                                       Variable = "Melt",
                                       Value = Melt)) |>
    tibble::add_row(prcp_a_eb |>
                      dplyr::transmute(Hyear = Hyear,
                                       RGIId = gsub("_1", "", ID),
                                       Variable = "P",
                                       Value = P))

  ggplot2::ggplot(res) +
    ggplot2::geom_line(ggplot2::aes(Hyear, Value)) +
    ggplot2::facet_wrap("Variable", scales = "free_y") +
    ggplot2::theme_bw()

})


test_that("Toy example for large glacier works as expected", {

  melt_a_eb <- tibble::tibble(
    Hyear = c(c(2000:2100), c(2000:2100)),
    ID = c(rep("RGI60-13.00001_1", length.out = length(c(2000:2100))),
           rep("RGI60-13.00001_2", length.out = length(c(2000:2100)))),
    Melt = c(seq(0, 5000, length.out = length(c(2000:2100))),
             seq(0, 5000, length.out = length(c(2000:2100))))
  )

  prcp_a_eb <- melt_a_eb |>
    dplyr::rename(P = Melt) |>
    dplyr::mutate(P = 2000)

  rgi_elbands = tibble::tibble(
    RGIId = c("RGI60-13.00001", "RGI60-13.00001"),
    A_km2 = c(1, 1),
    thickness_m = c(50, 50),
    Area_tot_glacier_km2 = c(2, 2),
    ID = c("RGI60-13.00001_1", "RGI60-13.00001_2")
  )

  res <- glacierBalanceP(melt_a_eb, prcp_a_eb, rgi_elbands) |>
    tibble::add_row(melt_a_eb |>
                      dplyr::transmute(Hyear = Hyear,
                                       RGIId = gsub("_1", "", ID),
                                       Variable = "Melt",
                                       Value = Melt)) |>
    tibble::add_row(prcp_a_eb |>
                      dplyr::transmute(Hyear = Hyear,
                                       RGIId = gsub("_1", "", ID),
                                       Variable = "P",
                                       Value = P))

  ggplot2::ggplot(res) +
    ggplot2::geom_line(ggplot2::aes(Hyear, Value)) +
    ggplot2::facet_wrap("Variable", scales = "free_y") +
    ggplot2::theme_bw()

})

test_that("Compare small and large toy glacier", {

  melt_a_eb <- tibble::tibble(
    Hyear = c(c(2000:2100), c(2000:2100), c(2000:2100)),
    ID = c(rep("RGI60-13.00000_1", length.out = length(c(2000:2100))),
           rep("RGI60-13.00001_1", length.out = length(c(2000:2100))),
           rep("RGI60-13.00001_2", length.out = length(c(2000:2100)))),
    Melt = c(seq(0, 5000, length.out = length(c(2000:2100))),
             seq(0, 5000, length.out = length(c(2000:2100))),
             seq(0, 5000, length.out = length(c(2000:2100))))
  )

  prcp_a_eb <- melt_a_eb |>
    dplyr::rename(P = Melt) |>
    dplyr::mutate(P = 2000)

  rgi_elbands = tibble::tibble(
    RGIId = c("RGI60-13.00000", "RGI60-13.00001", "RGI60-13.00001"),
    A_km2 = c(2, 1, 1),
    thickness_m = c(50, 50, 50),
    Area_tot_glacier_km2 = c(2, 2, 2),
    ID = c("RGI60-13.00000_1", "RGI60-13.00001_1", "RGI60-13.00001_2")
  )

  res <- glacierBalanceP(melt_a_eb, prcp_a_eb, rgi_elbands) |>
    tibble::add_row(melt_a_eb |>
                      dplyr::transmute(Hyear = Hyear,
                                       RGIId = gsub("_1", "", ID),
                                       Variable = "Melt",
                                       Value = Melt)) |>
    tibble::add_row(prcp_a_eb |>
                      dplyr::transmute(Hyear = Hyear,
                                       RGIId = gsub("_1", "", ID),
                                       Variable = "P",
                                       Value = P))

  ggplot2::ggplot(res) +
    ggplot2::geom_line(ggplot2::aes(Hyear, Value, colour = RGIId)) +
    ggplot2::facet_wrap("Variable", scales = "free_y") +
    ggplot2::theme_bw()

})



test_that("Real-life example works as expected", {

 load("tests/testthat/test_glacierBalance_reallifedata.RData")
  #load("test_glacierBalance_reallifedata.RData")

  res_fac1 <- glacierBalanceP(
    melt_a_eb = test_melt_mma |>
      dplyr::mutate(Melt = Melt * 1),
    prcp_a_eb = test_prcp_mma,
    rgi_elbands = test_rgi)
  res_fac2 <- glacierBalanceP(
    melt_a_eb = test_melt_mma |>
      dplyr::mutate(Melt = Melt * 2),
    prcp_a_eb = test_prcp_mma,
    rgi_elbands = test_rgi)

  res0 <- glacierBalance(
    melt_a_eb = test_melt_mma,
    rgi_elbands = test_rgi
  )

  res_fac1 <- res_fac1 |>
    dplyr::filter(RGIId == res_fac1$RGIId[1]) |>
    tidyr::pivot_wider(names_from = Variable, values_from = Value) |>
    dplyr::left_join(test_melt_mma |>
                       tidyr::separate(ID, into = c("RGIId", "layer"),
                                       sep = "_"),
                     by = c("Hyear", "RGIId")) |>
    dplyr::mutate(melt_times_area = Melt*10^(-3)*A_km2*10^6,
                  Q_func = glacierDischarge_HM(dhdt = Melt*10^(-3)),
                  Qimb_func = glacierImbalAbl(Melt_mma = Melt),
                  Qimb_func = ifelse(Qimb_func < -Q_m3a, -Q_m3a, Qimb_func)) |>
    dplyr::left_join(test_prcp_mma |>
                       tidyr::separate(ID, into = c("RGIId", "layer"),
                                       sep = "_"),
                     by = c("Hyear", "RGIId")) |>
    dplyr::mutate(deltaS_mma = P-Melt,
                  deltaS_m3a = deltaS_mma*10^(-3)*A_km2*10^6)

  res_fac2 <- res_fac2 |>
    dplyr::filter(RGIId == res_fac2$RGIId[1]) |>
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

  res2 <- res0 |>
    dplyr::filter(RGIId == res0$RGIId[1]) |>
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

  ggplot2::ggplot() +
    ggplot2::geom_line(data = res_fac1, ggplot2::aes(Hyear, Qimb_m3a)) +
    ggplot2::geom_line(data = res_fac2, ggplot2::aes(Hyear, Qimb_m3a), colour = "red") +
    ggplot2::theme_bw()

  ggplot2::ggplot() +
    ggplot2::geom_line(data = res_fac1, ggplot2::aes(Hyear, V_km3)) +
    ggplot2::geom_line(data = res_fac2, ggplot2::aes(Hyear, V_km3), colour = "red") +
    ggplot2::theme_bw()


  ggplot2::ggplot(res_fac1) +
    ggplot2::geom_line(ggplot2::aes(Hyear, Qimb_m3a)) +
    ggplot2::geom_line(ggplot2::aes(Hyear, Qimb_func), colour = "red") +
    ggplot2::theme_bw()

  ggplot2::ggplot(res_fac1) +
    ggplot2::geom_line(ggplot2::aes(Hyear, Q_m3a)) +
    ggplot2::geom_line(ggplot2::aes(Hyear, -Qimb_func), colour = "red") +
    ggplot2::theme_bw()

  ggplot2::ggplot(res_fac1) +
    ggplot2::geom_line(ggplot2::aes(Hyear, Q_m3a)) +
    ggplot2::geom_line(ggplot2::aes(Hyear, Q_func), colour = "red") +
    ggplot2::theme_bw()

  ggplot2::ggplot(res_fac1) +
    ggplot2::geom_line(ggplot2::aes(Hyear, Qimb_m3a)) +
    ggplot2::geom_line(ggplot2::aes(Hyear, deltaS_m3a), colour = "red") +
    ggplot2::theme_bw()

  ggplot2::ggplot(res_fac1) +
    ggplot2::geom_line(ggplot2::aes(Hyear, V_km3)) +
    #ggplot2::geom_line(ggplot2::aes(Hyear, deltaS_m3a), colour = "red") +
    ggplot2::theme_bw()

  expect_equal(res_fac1$Qimb_func[dim(res_fac1)[1]], res_fac1$Qimb_m3a[dim(res_fac1)[1]])

})


