
test_that("glacierBalance does not produce rubbish", {

  # melt_a_eb_small = tibble::tibble(
  #   Hyear = seq(1900, 2100),
  #   ID = "RGI60-13.00123_1",
  #   Melt = ((Hyear-Hyear[1]+1)*0.5)+200
  # )
  #
  # ggplot2::ggplot(melt_a_eb_small) +
  #   ggplot2::geom_line(ggplot2::aes(Hyear, Melt)) +
  #   ggplot2::theme_bw()
  #
  # melt_a_eb_large = tibble::tibble(
  #   Hyear = seq(1900, 2100),
  #   ID = "RGI60-13.00123_1",
  #   Melt = 2000
  # ) |> tibble::add_row(tibble::tibble(
  #   Hyear = seq(1900, 2100),
  #   ID = "RGI60-13.00123_2",
  #   Melt = 2000
  # )) |> tibble::add_row(tibble::tibble(
  #   Hyear = seq(1900, 2100),
  #   ID = "RGI60-13.00123_3",
  #   Melt = 2000
  # ))
  #
  # rgi_elbands_small <- tibble::tibble(
  #   RGIId = "RGI60-13.00123",
  #   Area_tot_glacier_km2 = 30,
  #   thickness_m = 100,
  #   ID = "RGI60-13.00123_1",
  #   A_km2 = 30,
  # )
  # rgi_elbands_large <- tibble::tibble(
  #   RGIId = c("RGI60-13.00123", "RGI60-13.00123", "RGI60-13.00123"),
  #   Area_tot_glacier_km2 = c(30, 30, 30),
  #   thickness_m = 100,
  #   ID = c("RGI60-13.00123_1", "RGI60-13.00123_2", "RGI60-13.00123_3"),
  #   A_km2 = c(10, 10, 10)
  # )
  #
  # As_km2 <- rgi_elbands_small |>
  #   dplyr::select(ID, A_km2) |>
  #   tidyr::pivot_wider(names_from = ID, values_from = A_km2)
  #
  # test <- stepWiseGlacierBalance(M_mma = melt_a_eb_small |>
  #                                  tidyr::pivot_wider(-Hyear,
  #                                                     names_from = ID,
  #                                                     values_from = Melt),
  #                                A_km2 = As_km2)
  #
  # wbsa <- glacierBalance(melt_a_eb = melt_a_eb_small,
  #                       rgi_elbands = rgi_elbands_small,
  #                       area_threshold = 40)
  # wbsb <- glacierBalance(melt_a_eb = melt_a_eb_small |>
  #                          dplyr::mutate(Melt = Melt*2),
  #                        rgi_elbands = rgi_elbands_small,
  #                        area_threshold = 40)
  #
  # ggplot2::ggplot(wbsa) +
  #   ggplot2::geom_line(ggplot2::aes(Hyear, Value, colour = RGIId)) +
  #   ggplot2::facet_wrap("Variable", scales = "free_y") +
  #   ggplot2::theme_bw()
  #
  # ggplot2::ggplot(wbsb) +
  #   ggplot2::geom_line(ggplot2::aes(Hyear, Value, colour = RGIId)) +
  #   ggplot2::facet_wrap("Variable", scales = "free_y") +
  #   ggplot2::theme_bw()
  #
  #
  # wbl <- glacierBalance(melt_a_eb = melt_a_eb_large,
  #                       rgi_elbands = rgi_elbands_large,
  #                       area_threshold = 1)

})
