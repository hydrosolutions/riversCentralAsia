#' Assesses the quality of decadal or monthly forecasts as done in Central Asian
#' Hydrometeorological Agencies.
#'
#' This function computes a per period (decade or month) forecast quality
#' assessment for each forecast for the test set provided.
#' Ideally, the user provides an out-of-sample test set.
#'
#' @param df tibble with `date`, `obs`, `pred` and `per` column where the `per`
#'   column is either the decade or the month specifier (normally given as
#'   factor).
#' @param plot TRUE/FALSE if plot should be generated
#' @return A list with a tibble of per period forecasts that are acceptable
#'   expressed as percentages of the total test set length and the average of
#'   these plus, optionally, the handle to the figure.
#' @family Post-processing
#' @details `per` goes from 1 to 12 for monthly data and from 1 to 36 in
#'   decadal data.
#' @export
assess_fc_qual <- function(df, plot){

  . <- NULL

  # Calculate absolute errors
  df <- df |>
    dplyr::mutate(errs = abs(.data$obs-.data$pred)) |>
    dplyr::mutate(per = as.numeric(.data$per))

  per_max <- df$per |> max()

  # sd(Q) and sd(dQ) calculations
  if (per_max == 12){

    sd_calc <- df |>
      dplyr::select(-.data$pred, -.data$errs) |>
      dplyr::mutate(date = lubridate::year(.data$date)) |>
      tidyr::pivot_wider(names_from = .data$per, values_from = .data$obs,
                         names_sort = T) |>
      stats::na.omit() |>
      dplyr::summarise(dplyr::across(-.data$date, stats::sd)) |>
      t() |>
      tibble::as_tibble_col(column_name = "sd") |>
      tibble::add_column(per = 1:12)

  } else if (per_max==36) {

    sd_calc <- df |>
      dplyr::mutate(obs = .data$obs - dplyr::lag(.data$obs)) |>
      dplyr::select(-.data$pred, -.data$errs) |>
      dplyr::mutate(date = lubridate::year(.data$date)) |>
      tidyr::pivot_wider(names_from = .data$per, values_from = .data$obs,
                         names_sort = T) |>
      stats::na.omit() |>
      dplyr::summarise(dplyr::across(-.data$date, stats::sd)) |>
      t() |>
      tibble::as_tibble_col(column_name = "sd") |>
      tibble::add_column(per = 1:36)

  } else {
    stop('Neither decadal nor monthly data. Error criterion is only defined for these types of discharge data.')
  }

  # now we need to match errors at particular decades with corresponding sd_q and sd_dq values.
  res <- dplyr::inner_join(df, sd_calc, by = 'per') |>
    dplyr::mutate(fc_qual = .data$errs / .data$sd) |>
    dplyr::mutate(good = as.integer(.data$fc_qual <= 0.674)) # Add percentage number of predictions that are <= qual. criterion.

  numb_good <- res |>
    dplyr::select(.data$date, .data$per, .data$good) |>
    dplyr::mutate(date = lubridate::year(.data$date)) |>
    tidyr::pivot_wider(names_from = .data$per,
                       values_from = .data$good,
                       names_sort = T) |>
    stats::na.omit()

  numb_good_nYearObs <- numb_good |> dim()
  numb_good_n <- numb_good |> dplyr::summarize(dplyr::across(-.data$date, sum))
  numb_good_nperc <- (numb_good_n / numb_good_nYearObs[1] *100) |>
    t() |>
    tibble::as_tibble(.name_repair = "unique") |>
    dplyr::rename(good_qual_perc = .data$`...1`) |>
    tibble::add_column(per = 1:per_max)

  yintercept <-  numb_good_nperc$good_qual_perc |> mean()

  if (plot == TRUE){
    p1 <- res |>
      ggplot2::ggplot(ggplot2::aes(x = .data$per, y = .data$fc_qual,
                                   group = .data$per)) +
      ggplot2::geom_boxplot(fill        = "aliceblue",
                            color       = "darkgrey") +
      ggplot2::geom_hline(yintercept    = 0.674,
                          linetype      = "dashed",
                          color         = "red") +
      ggplot2::ylab("forecast quality [-]") +
      ggplot2::xlab("period") +
      ggplot2::geom_text(x              = per_max,
                         y              = .8,
                         label          = "0.674",
                         color          = "red") +
      ggplot2::ylim(0,2) +
      ggplot2::theme_minimal()

    p2 <- numb_good_nperc |>
      ggplot2::ggplot(ggplot2::aes(x = .data$per, y = .data$good_qual_perc)) +
      ggplot2::geom_bar(stat            = "identity",
                        fill            = "cornsilk",
                        color           = "grey",
                        width           = 0.7) +
      ggplot2::geom_hline(yintercept    = yintercept,
                          linetype      = "dashed",
                          color         = "darkblue") +
      ggplot2::xlab("Period") +
      ggplot2::ylab("High-quality forecasts [% of length of test set]") +
      ggplot2::geom_text(x              = per_max,
                         y              = yintercept+5,
                         label          = paste0(yintercept |> format(digits=4) |> as.character()," %"),
                         color          = "darkblue") +
      ggplot2::theme_minimal() +
      ggplot2::ylim(0,100)

    fin_plot <- GGally::ggmatrix(list(p1,p2),2,1,
                     xAxisLabels        = "Period",
                     yAxisLabels        = c("scaled forecast error [-]","perc. aceptable forecasts [%]"),
                     showAxisPlotLabels = TRUE)
    returnObject <- list(numb_good_nperc, yintercept, fin_plot)

  } else {

    returnObject <- list(numb_good_nperc, yintercept)

  }
  return(returnObject)
}
