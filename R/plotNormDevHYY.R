#' Helper function to plot value deviations from norms for entire hydrological years and
#' cold and warm seasons.
#'
#' The function expects a tibble columns 'hyYear' (date), data (dbl), data_cs (dbl) and data_ws (dbl)
#' where hyYear is a date column and data, data_cs and data_ws columns are the values for the entire year,
#' the cold season (Oct. to Mar. in Central Asia) and warm season (Apr. to Sept. in Central Asia). The following
#' dataType(s) are accepted: 'Q' for discharge, 'T' temperature in deg. C. and 'P' for precipitation in mm/year.
#' The data2Plot tibble can easily be produced with the function convert2HYY() that is part of the package.
#'
#' @param data2Plot tibble
#' @param dataType String, either 'Q' for mean discharge in m3/s, 'T' for temperature in degrees Celsius or 'P' for precipitation in mm/yr.
#' @param stationID String of station name, e.g. 'Khorog-Gunt 17050'
#' @return ggplot object
#' @export
plotNormDevHYY <- function(data2Plot,dataType,stationID){
  # rename columns just to ensure proper functioning of the function after changes in the naming convention of convert2HYY()
  data2Plot <- data2Plot %>% dplyr::rename(data = 2, data_cs = 3, data_ws = 4)
  # augment data where data is hydrological year time series object
  data_norms <- data2Plot %>%
    dplyr::mutate(norm_data = base::mean(data,na.rm = TRUE)) %>%
    dplyr::mutate(norm_data_cs = base::mean(data_cs, na.rm = TRUE)) %>%
    dplyr::mutate(norm_data_ws = base::mean(data_ws, na.rm = TRUE)) %>%
    dplyr::mutate(delta_data = data - norm_data) %>%
    dplyr::mutate(delta_data_cs = data_cs - norm_data_cs) %>%
    dplyr::mutate(delta_data_ws = data_ws - norm_data_ws)
  # generate titles
  if (dataType == 'Q') {
    ylabText = 'Q [m3/s]'
    titleText_HYY = base::paste0(stationID,': Deviation from Norm (',data_norms$norm_data[1] %>%
                                   base::round(1),' m3/s)')
    titleText_cs = base::paste0(stationID,': Cold Season Deviation from Cold Season Norm (',
                          data_norms$norm_data_cs[1] %>% base::round(1),' m3/s)')
    titleText_ws = base::paste0(stationID,': Warm Season Deviation from Warm Season Norm (',
                          data_norms$norm_data_ws[1] %>% base::round(1),' m3/s)')
  } else if (dataType == 'mean(T)') {
    ylabText = 'mean T [deg. C]'
    titleText_HYY = base::paste0(stationID,': Deviation from Norm (',data_norms$norm_data[1] %>%
                                   base::round(1),' deg. C)')
    titleText_cs = base::paste0(stationID,': Cold Season Deviation from Cold Season Norm (',
                          data_norms$norm_data_cs[1] %>% base::round(1),' deg. C)')
    titleText_ws = base::paste0(stationID,': Warm Season Deviation from Warm Season Norm (',
                          data_norms$norm_data_ws[1] %>% base::round(1),' deg. C)')
  } else if (dataType == 'P') {
    ylabText = 'P [mm]'
    titleText_HYY = base::paste0(stationID,': Deviation from Norm (',data_norms$norm_data[1] %>%
                                   base::round(1),' mm)')
    titleText_cs = base::paste0(stationID,': Cold Season Deviation from Cold Season Norm (',
                          data_norms$norm_data_cs[1] %>% base::round(1),' mm)')
    titleText_ws = base::paste0(stationID,': Warm Season Deviation from Warm Season Norm (',
                          data_norms$norm_data_ws[1] %>% base::round(1),' mm)')
  }
  # plot deviation from norm for hydrological year data using the geom_step function
  completeHYY <- data_norms %>%
    ggplot2::ggplot(ggplot2::aes(x = hyYear, y = delta_data)) +
    ggplot2::geom_bar(ggplot2::aes(fill = delta_data < 0), stat = "identity") +
    ggplot2::scale_fill_manual(guide = FALSE, breaks = c(TRUE, FALSE), values = c("red", "blue")) +
    ggplot2::xlab('Hydrological year') + ggplot2::ylab(ylabText) +
    ggplot2::ggtitle(titleText_HYY)
  csHYY <- data_norms %>%
    ggplot2::ggplot(aes(x = hyYear, y = delta_data_cs)) +
    ggplot2::geom_bar(aes(fill = delta_data_cs < 0), stat = "identity") +
    ggplot2::scale_fill_manual(guide = FALSE, breaks = c(TRUE, FALSE), values = c("red", "blue")) +
    ggplot2::xlab('Hydrological year') + ggplot2::ylab(ylabText) +
    ggplot2::ggtitle(titleText_cs)
  wsHYY <- data_norms %>%
    ggplot2::ggplot(ggplot2::aes(x = hyYear, y = delta_data_ws)) +
    ggplot2::geom_bar(ggplot2::aes(fill = delta_data_ws < 0), stat = "identity") +
    ggplot2::scale_fill_manual(guide = FALSE, breaks = c(TRUE, FALSE), values = c("red", "blue")) +
    ggplot2::xlab('Hydrological year') + ggplot2::ylab(ylabText) +
    ggplot2::ggtitle(titleText_ws)

  ggpubr::ggarrange(completeHYY, csHYY, wsHYY, ncol = 1) %>% return()
}
