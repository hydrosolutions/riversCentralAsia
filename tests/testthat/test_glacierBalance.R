
test_that("Real-life example works as expected", {

  # load("tests/testthat/test_glacierBalance_reallifedata.RData")
  load("test_glacierBalance_reallifedata.RData")

  res <- glacierBalance(
    melt_a_eb = test_melt_mma,
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
                  Qimb_func = ifelse(Qimb_func < -Q_m3a, -Q_m3a, Qimb_func))

  ggplot2::ggplot(res1) +
    ggplot2::geom_line(ggplot2::aes(Hyear, Qimb_m3a)) +
    ggplot2::geom_line(ggplot2::aes(Hyear, Qimb_func),
                       colour = "red", linetype = 2) +
    ggplot2::theme_bw()

  expect_equal(res1$Qimb_func[dim(res1)[1]], res1$Qimb_m3a[dim(res1)[1]])

})

test_that("glacierBalance can handle one single large glacier", {

  M <- tibble::tibble(Hyear = c(2000:2003),
                      Gl1_1 = rep.int(400, 4),
                      Gl1_2 = rep.int(200, 4))
  A <- matrix(1, nrow = 1, ncol = 2, dimnames = list(NULL, c("Gl1_1", "Gl1_2")))
  Atot <- sum(A)
  Vtot <- glacierVolume_RGIF(Atot)
  V <- A/Atot*Vtot
  res <- stepWiseGlacierBalancePerElBand(M, A, V)
  Qn <- res$Q_m3a
  Vn <- res$V_km3
  An <- res$A_km2
  Qimbn <- res$Qimb_m3a

  shp <- tibble::tibble(
    RGIId = c("Gl1", "Gl1"),
    ID = c("Gl1_1", "Gl1_2"),
    Area_tot_glacier_km2 = c(2, 2),
    A_km2 = c(1, 1))

  Melt <- M |>
    tidyr::pivot_longer(-Hyear, names_to = "ID", values_to = "Melt")

  resWB <- glacierBalance(melt_a_eb = Melt,
                          rgi_elbands = shp)

  expect_equal(as.numeric((resWB |>
                             dplyr::filter(Hyear == 2003,
                                           Variable == "A_km2"))$Value),
               res$A_km2[4])

})

test_that("stepWiseGlacierBalance works as expected, 1 single small glacier", {

  M <- tibble::tibble(Hyear = c(2000:2020),
              Gl1_1 = rep.int(800, 21))
  A <- matrix(1, nrow = 1, ncol = 1, dimnames = list(NULL, "Gl1_1"))
  res <- stepWiseGlacierBalance(M, A)
  Qn <- res$Q_m3a
  Vn <- res$V_km3
  An <- res$A_km2
  Qimbn <- res$Qimb_m3a

  Qimbtest <- glacierImbalAbl(M$Gl1_1)
  Qimbtest <- ifelse(Qn < -Qimbtest, -Qn, Qimbtest)

  expect_equal(Qimbn, Qimbtest)

  # Calculate WB separately
  Aexp <- matrix(A, nrow=dim(M)[1], ncol=1, byrow = TRUE)
  Qexp <- M$Gl1_1*10^(-3)*Aexp*10^6
  Vexp <- glacierVolume_RGIF(Aexp)
  Qimbexp <- as.matrix(glacierImbalAbl(M$Gl1_1))
  for (time in c(2:dim(M)[1])) {
    Aexp[time, ] <- glacierArea_RGIF(Vexp[time-1, ])
    # If the remaining glacier volume is smaller than the theoretical glacier
    # melt rate, apply the volume to the actual melt rate.
    Qexp[time, ] <- apply(rbind(as.matrix(M$Gl1_1)[time, ] * 10^(-3) *
                                  Aexp[time, ] * 10^6,
                                Vexp[time-1, ] * 10^9), 2, min)
    # Qexp[time, ] <- apply(
    #   rbind(-glacierTotalAblation_HM(-as.matrix(M$Gl1_1)[time, ]*10^(-3)),
    #         Vexp[time-1, ] * 10^9), 2, min)

    # Imbalance ablation cannot be larger than total glacier discharge per year.
    Qimbexp[time, ] <- glacierImbalAbl(as.matrix(M$Gl1_1)[time, ])
    Qimbexp[time, ] <- ifelse(Qimbexp[time, ] < -Qexp[time, ],
                                   -Qexp[time, ], Qimbexp[time, ])
    Vexp[time, ] <- apply(rbind(Vexp[time-1,] + Qimbexp[time, ]*10^(-9),
                                     Vexp[time-1,]*0), 2, max)
  }
  expect_lte(sum(Qn[,1] - Qexp[,1]), 10^(-4))
  expect_lte(sum(Qimbn[,1] - Qimbexp[,1]), 10^(-4))
  expect_gte(Qexp[1,1], -Qimbn[1,1])
  expect_gte(Qexp[dim(Qexp)[1],1], -Qimbn[dim(Qimbn)[1],1])

  # V(t) should be V(t-1) + Qimb(t). Does this pan out?
  Vexp2 <- Vn
  for (time in c(2:4)) {
    Vexp2[time] <- Vexp2[time -1] + Qimbn[time]*10^(-9)
  }

  expect_lte(sum(Vn[,1] - Vexp[,1]), 10^(-4))
  expect_lte(sum(Vn[,1] - Vexp2[,1]), 10^(-4))
})



test_that("glacierBalance produces the same output as stepWiseGlacierBalance", {

  M <- tibble::tibble(Hyear = c(2000:2003),
                      Gl1_1 = rep.int(400, 4),
                      Gl2_1 = rep.int(200, 4))
  A <- matrix(1, nrow = 1, ncol = 2, dimnames = list(NULL, c("Gl1_1", "Gl2_1")))
  res <- stepWiseGlacierBalance(M, A)
  Qn <- res$Q_m3a
  Vn <- res$V_km3
  An <- res$A_km2
  Qimbn <- res$Qimb_m3a

  shp <- tibble::tibble(
    RGIId = c("Gl1", "Gl2"),
    ID = c("Gl1_1", "Gl2_1"),
    Area_tot_glacier_km2 = c(1, 1),
    A_km2 = c(1, 1),
    thickness_m = glacierVolume_RGIF(Area_tot_glacier_km2) /
      Area_tot_glacier_km2*10^3)

  Melt <- M |>
    tidyr::pivot_longer(-Hyear, names_to = "ID", values_to = "Melt")

  resWB <- glacierBalance(melt_a_eb = Melt,
                          rgi_elbands = shp)

  expect_equal(as.numeric(An[4,1]),
               as.numeric((resWB |>
                  dplyr::filter(Hyear == 2003,
                                Variable == "A_km2",
                                RGIId == "Gl1"))$Value))
  expect_equal(as.numeric(An[4,2]),
               as.numeric((resWB |>
                  dplyr::filter(Hyear == 2003,
                                Variable == "A_km2",
                                RGIId == "Gl2"))$Value))

  expect_equal(as.numeric(Qn[4,1]),
               as.numeric((resWB |>
                  dplyr::filter(Hyear == 2003,
                                Variable == "Q_m3a",
                                RGIId == "Gl1"))$Value))
  expect_equal(as.numeric(Qn[4,2]),
               as.numeric((resWB |>
                  dplyr::filter(Hyear == 2003,
                                Variable == "Q_m3a",
                                RGIId == "Gl2"))$Value))

  expect_equal(as.numeric(Qimbn[4,1]),
               as.numeric((resWB |>
                  dplyr::filter(Hyear == 2003,
                                Variable == "Qimb_m3a",
                                RGIId == "Gl1"))$Value))
  expect_equal(as.numeric(Qimbn[4,2]),
               as.numeric((resWB |>
                  dplyr::filter(Hyear == 2003,
                                Variable == "Qimb_m3a",
                                RGIId == "Gl2"))$Value))

  expect_equal(as.numeric(Vn[4,1]),
               as.numeric((resWB |>
                  dplyr::filter(Hyear == 2003,
                                Variable == "V_km3",
                                RGIId == "Gl1"))$Value))
  expect_equal(as.numeric(Vn[4,2]),
               as.numeric((resWB |>
                  dplyr::filter(Hyear == 2003,
                                Variable == "V_km3",
                                RGIId == "Gl2"))$Value))
})


test_that("stepWiseGlacierBalancePerElBand produces the same result as glacierBalance", {

  M <- tibble::tibble(Hyear = c(2000:2003),
                      Gl1_1 = rep.int(400, 4),
                      Gl1_2 = rep.int(400, 4),
                      Gl2_1 = rep.int(200, 4),
                      Gl2_2 = rep.int(200, 4))
  A <- matrix(1, nrow = 1, ncol = 4,
              dimnames = list(NULL, c("Gl1_1", "Gl1_2", "Gl2_1", "Gl2_2")))
  V <- glacierVolume_RGIF(A*2)*A/(A*2)
  res <- stepWiseGlacierBalancePerElBand(M, A, V)
  Qn <- res$Q_m3a
  Vn <- res$V_km3
  An <- res$A_km2
  Qimbn <- res$Qimb_m3a

  shp <- tibble::tibble(
    RGIId = c("Gl1", "Gl1", "Gl2", "Gl2"),
    ID = c("Gl1_1", "Gl1_2", "Gl2_1", "Gl2_2"),
    Area_tot_glacier_km2 = c(2, 2, 2, 2),
    A_km2 = c(1, 1, 1, 1),
    thickness_m = glacierVolume_RGIF(Area_tot_glacier_km2) /
      Area_tot_glacier_km2*10^3)

  Melt <- M |>
    tidyr::pivot_longer(-Hyear, names_to = "ID", values_to = "Melt")

  resWB <- glacierBalance(melt_a_eb = Melt,
                          rgi_elbands = shp)

  Ab <- resWB |>
    dplyr::filter(Variable == "A_km2") |>
    dplyr::select(-Variable) |>
    tidyr::pivot_wider(names_from = RGIId, values_from = Value)

  expect_equal(as.numeric(An[4,1]),
               as.numeric((resWB |>
                             dplyr::filter(Hyear == 2003,
                                           Variable == "A_km2",
                                           RGIId == "Gl1"))$Value))
  expect_equal(as.numeric(An[4,2]),
               as.numeric((resWB |>
                             dplyr::filter(Hyear == 2003,
                                           Variable == "A_km2",
                                           RGIId == "Gl2"))$Value))

  expect_equal(as.numeric(Qn[4,1]),
               as.numeric((resWB |>
                             dplyr::filter(Hyear == 2003,
                                           Variable == "Q_m3a",
                                           RGIId == "Gl1"))$Value))
  expect_equal(as.numeric(Qn[4,2]),
               as.numeric((resWB |>
                             dplyr::filter(Hyear == 2003,
                                           Variable == "Q_m3a",
                                           RGIId == "Gl2"))$Value))

  expect_equal(as.numeric(Qimbn[4,1]),
               as.numeric((resWB |>
                             dplyr::filter(Hyear == 2003,
                                           Variable == "Qimb_m3a",
                                           RGIId == "Gl1"))$Value))
  expect_equal(as.numeric(Qimbn[4,2]),
               as.numeric((resWB |>
                             dplyr::filter(Hyear == 2003,
                                           Variable == "Qimb_m3a",
                                           RGIId == "Gl2"))$Value))

  expect_equal(as.numeric(Vn[4,1]),
               as.numeric((resWB |>
                             dplyr::filter(Hyear == 2003,
                                           Variable == "V_km3",
                                           RGIId == "Gl1"))$Value))
  expect_equal(as.numeric(Vn[4,2]),
               as.numeric((resWB |>
                             dplyr::filter(Hyear == 2003,
                                           Variable == "V_km3",
                                           RGIId == "Gl2"))$Value))
})


# test_that("glacierBalance does not produce rubbish", {
#
#   # melt_a_eb_small = tibble::tibble(
#   #   Hyear = seq(1900, 2100),
#   #   ID = "RGI60-13.00123_1",
#   #   Melt = ((Hyear-Hyear[1]+1)*0.5)+200
#   # )
#   #
#   # melt_a_eb_large = tibble::tibble(
#   #   Hyear = seq(1900, 2100),
#   #   ID = "RGI60-13.00123_1",
#   #   Melt = 2000
#   # ) |> tibble::add_row(tibble::tibble(
#   #   Hyear = seq(1900, 2100),
#   #   ID = "RGI60-13.00123_2",
#   #   Melt = 2000
#   # )) |> tibble::add_row(tibble::tibble(
#   #   Hyear = seq(1900, 2100),
#   #   ID = "RGI60-13.00123_3",
#   #   Melt = 2000
#   # ))
#   #
#   # rgi_elbands_small <- tibble::tibble(
#   #   RGIId = "RGI60-13.00123",
#   #   Area_tot_glacier_km2 = 30,
#   #   thickness_m = 100,
#   #   ID = "RGI60-13.00123_1",
#   #   A_km2 = 30,
#   # )
#   # rgi_elbands_large <- tibble::tibble(
#   #   RGIId = c("RGI60-13.00123", "RGI60-13.00123", "RGI60-13.00123"),
#   #   Area_tot_glacier_km2 = c(30, 30, 30),
#   #   thickness_m = 100,
#   #   ID = c("RGI60-13.00123_1", "RGI60-13.00123_2", "RGI60-13.00123_3"),
#   #   A_km2 = c(10, 10, 10)
#   # )
#   #
#   # As_km2 <- rgi_elbands_small |>
#   #   dplyr::select(ID, A_km2) |>
#   #   tidyr::pivot_wider(names_from = ID, values_from = A_km2)
#   #
#   # wbsa <- glacierBalance(melt_a_eb = melt_a_eb_small,
#   #                       rgi_elbands = rgi_elbands_small,
#   #                       area_threshold = 40)
#   # wbsb <- glacierBalance(melt_a_eb = melt_a_eb_small |>
#   #                          dplyr::mutate(Melt = Melt*2),
#   #                        rgi_elbands = rgi_elbands_small,
#   #                        area_threshold = 40)
#   #
#   # ggplot2::ggplot(wbsa) +
#   #   ggplot2::geom_line(ggplot2::aes(Hyear, Value, colour = RGIId)) +
#   #   ggplot2::facet_wrap("Variable", scales = "free_y") +
#   #   ggplot2::theme_bw()
#   #
#   # ggplot2::ggplot(wbsb) +
#   #   ggplot2::geom_line(ggplot2::aes(Hyear, Value, colour = RGIId)) +
#   #   ggplot2::facet_wrap("Variable", scales = "free_y") +
#   #   ggplot2::theme_bw()
#   #
#   #
#   # wbl <- glacierBalance(melt_a_eb = melt_a_eb_large,
#   #                       rgi_elbands = rgi_elbands_large,
#   #                       area_threshold = 1)
#
# })
