#' Assesses the quality of decadal or monthly forecasts as done in Central Asian Hydrometeorological Agencies.
#'
#' This function computes a per period (decade or month) forecast quality assessment for each forecast for the test set provided.
#' Ideally, the user provides an out-of-sample testset
#'
#' @param df tibble with date, obs, pred and per column where the per column is either the decade or the month specifier (normally given as factor).
#' @param plot TRUE/FALSE if plot should be generated
#' @return A list with a tibble of per period forecasts that are acceptable expressed as percentages of the total test set length
#' @export
assess_fc_qual <- function(df,plot){
  # errors
  df <- df %>%
    dplyr::mutate(errs = abs(obs-pred)) %>%
    dplyr::mutate(per = as.numeric(per))
  per_max <- df$per %>% max()

  # sd(Q) and sd(dQ) calculations
  if (per_max==12){

    sd_calc <- df %>%
      dplyr::select(-pred,-errs) %>%
      dplyr::mutate(date = year(date)) %>%
      tidyr::pivot_wider(names_from = per, values_from = obs, names_sort = T) %>%
      na.omit() %>%
      dplyr::summarise(across(-date,sd)) %>%
      t() %>%
      tibble::as_tibble_col(.,column_name = "sd") %>%
      tibble::add_column(per = 1:12)

  } else if (per_max==36) {

    sd_calc <- df %>%
      dplyr::mutate(obs = obs - lag(obs)) %>%
      dplyr::select(-pred,-errs) %>%
      dplyr::mutate(date = year(date)) %>%
      tidyr::pivot_wider(names_from = per,values_from = obs,names_sort = T) %>%
      na.omit() %>%
      dplyr::summarise(across(-date,sd)) %>%
      t() %>%
      tibble::as_tibble_col(.,column_name = "sd") %>%
      tibble::add_column(per=1:36)

  } else {

    stop('Neither decadal nor monthly data. Error criterion is only defined for these types of discharge data.')

  }
  # now we need to match errors at particular decades with corresponding sd_q and sd_dq values.
  res <- dplyr::inner_join(df, sd_calc,by='per') %>%
    dplyr::mutate(fc_qual = errs/sd) %>%
    dplyr::mutate(good = as.integer(fc_qual<=0.674)) # Add percentage number of predictions that are <= qual. criterion.

  numb_good <- res %>%
    dplyr::select(date,per,good) %>%
    dplyr::mutate(date = year(date)) %>%
    tidyr::pivot_wider(names_from = per,
                       values_from = good,
                       names_sort = T) %>%
    na.omit()

  numb_good_nYearObs <- numb_good %>% dim()
  numb_good_n <- numb_good %>% dplyr::summarize(across(-date,sum))
  numb_good_nperc <- (numb_good_n / numb_good_nYearObs[1] *100) %>% t() %>% tibble::as.tibble() %>%
    dplyr::rename(good_qual_perc = 'V1') %>% add_column(per = 1:per_max)

  if (plot==TRUE){

    p1 <- res %>% ggplot(aes(x=per,y=fc_qual,group=per)) +
      geom_boxplot(fill        = "aliceblue",
                   color       = "darkgrey") +
      geom_hline(yintercept    = 0.674,
                 linetype      = "dashed",
                 color         = "red") +
      ylab("forecast quality [-]") +
      xlab("period") +
      geom_text(x              = per_max,
                y              = .8,
                label          = "0.674",
                color          = "red") +
      ylim(0,2) +
      theme_minimal()

    yintercept <-  numb_good_nperc$good_qual_perc %>% mean()

    p2 <- numb_good_nperc %>% ggplot(aes(x=per,y=good_qual_perc)) +
      geom_bar(stat            = "identity",
               fill            = "cornsilk",
               color           = "grey",
               width           = 0.7) +
      geom_hline(yintercept    = yintercept,
                 linetype      = "dashed",
                 color         = "darkblue") +
      xlab("Period") +
      ylab("High-quality forecasts [% of length of test set]") +
      geom_text(x              = per_max,
                y              = yintercept+5,
                label          = paste0(yintercept %>% format(digits=4) %>% as.character()," %"),
                color         = "darkblue") +
      theme_minimal() +
      ylim(0,100)

    fin_plot <- GGally::ggmatrix(list(p1,p2),2,1,
                     xAxisLabels        = "Period",
                     yAxisLabels        = c("scaled forecast error [-]","perc. aceptable forecasts [%]"),
                     showAxisPlotLabels = TRUE)

  }

  returnObject <- list(numb_good_nperc,yintercept,fin_plot)
  return(returnObject)
}
