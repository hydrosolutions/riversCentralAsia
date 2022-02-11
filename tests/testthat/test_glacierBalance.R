test_that("stepWiseGlacierBalance works as expected", {

  M <- tibble::tibble(Hyear = c(2000:2003),
              Gl1_1 = rep.int(400, 4))
  A <- matrix(1, nrow = 1, ncol = 1, dimnames = list(NULL, "Gl1_1"))
  res <- stepWiseGlacierBalance(M, A)
  Qn <- res$Q_m3a
  Vn <- res$V_km3
  An <- res$A_km2
  Qimbn <- res$Qimb_m3a

  # Calculate WB separately
  Aexp <- matrix(A, nrow=4, ncol=1, byrow = TRUE)
  Qexp <- M$Gl1_1*10^(-3)*Aexp*10^6
  Vexp <- glacierVolume_RGIF(Aexp)
  Qimbexp <- glacierImbalAbl(M$Gl1_1)
  for (time in c(2:4)) {
    Aexp[time, ] <- glacierArea_RGIF(Vexp[time-1, ])
    Qexp[time, ] <- apply(rbind(M$Gl1_1[time]*10^(-3)*Aexp[time, ]*10^6,
                                Vexp[time-1, ]*10^9), 2, min)
    Qimbexp[time] <- glacierImbalAbl(M$Gl1_1[time])
    Vexp[time, ] <- Vexp[time-1, ] + Qimbexp[time]*10^(-9)
  }
  expect_equal(Qn[1], Qexp[1])
  expect_equal(Qn[4], Qexp[4])
  expect_equal(Qimbn[1], Qimbexp[1])
  expect_equal(Qimbn[4], Qimbexp[4])

  # V(t) should be V(t-1) + Qimb(t). Does this pan out?
  Vexp2 <- Vn
  for (time in c(2:4)) {
    Vexp2[time] <- Vexp2[time -1] + Qimbn[time]*10^(-9)
  }

  expect_equal(Vn[1], Vexp[1])
  expect_equal(Vn[4], Vexp[4])
  expect_equal(Vn[1], Vexp2[1])
  expect_equal(Vn[4], Vexp2[4])
})

test_that("stepWiseGlacierBalancePerElBand works as expected", {

  M <- tibble::tibble(Hyear = c(2000:2003),
                      Gl1_1 = rep.int(400, 4),
                      Gl1_2 = rep.int(400, 4),
                      Gl2_1 = rep.int(200, 4),
                      Gl2_2 = rep.int(200, 4))
  A <- matrix(1, nrow = 1, ncol = 4,
              dimnames = list(NULL, c("Gl1_1", "Gl1_2", "Gl2_1", "Gl2_2")))
  V <- glacierVolume_RGIF(A)
  res <- stepWiseGlacierBalancePerElBand(M_mma = M,
                                         A_km2 = A,
                                         V_km3 = V)
  Qn <- res$Q_m3a
  Vn <- res$V_km3
  An <- res$A_km2
  Qimbn <- res$Qimb_m3a

  # Calculate WB separately by treating it as a single glacier
  Aexp <- matrix(2, nrow=4, ncol=2, dimnames = list(NULL, c("Gl1", "Gl2")))
  Mexp <- tibble::tibble(Gl1 = rep.int(400, 4),
                         Gl2 = rep.int(200, 4))
  Qexp <- cbind(Mexp$Gl1*10^(-3), Mexp$Gl2*10^(-3))*Aexp*10^6
  Vexp <- glacierVolume_RGIF(Aexp)
  Qimbexp <- glacierImbalAbl(as.matrix(Mexp))
  for (time in c(2:4)) {
    Aexp[time, ] <- glacierArea_RGIF(Vexp[time-1, ])
    Qexp[time, ] <- apply(rbind(Mexp[time, ]*10^(-3)*Aexp[time, ]*10^6,
                                Vexp[time-1, ]*10^9), 2, min)
    Qimbexp[time, ] <- glacierImbalAbl(as.matrix(Mexp[time, ]))
    Vexp[time, ] <- Vexp[time-1, ] + Qimbexp[time, ]*10^(-9)
  }
  expect_equal(Qn[1, 1], Qexp[1, 1])
  expect_gt(Qexp[4, 2], Qn[4, 2])
  expect_equal(Qimbexp[1, 1], Qimbn[1, 1])
  expect_equal(Qimbexp[4, 2], Qimbn[4, 2])

  # V(t) should be V(t-1) + Qimb(t). Does this pan out?
  Vexp2 <- Vn
  for (time in c(2:4)) {
    Vexp2[time] <- Vexp2[time -1] + Qimbn[time]*10^(-9)
  }

  expect_gt(Vexp[1, 1], Vn[1, 1])
  expect_gt(Vexp[4, 2], Vn[4, 2])
  expect_equal(Vn[1, 1], Vexp2[1, 1])
  expect_equal(Vn[4, 2], Vexp2[4, 2])
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
                          rgi_elbands = shp,
                          area_threshold = 2)

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
                          rgi_elbands = shp,
                          area_threshold = 0.5)

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
