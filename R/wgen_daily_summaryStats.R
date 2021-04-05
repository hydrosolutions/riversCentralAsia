#' wgen_daily_summaryStats
#'
#' Function to generate precipitation and min./max. summary statistics tables from 1 stochastic daily climate realization. param$nscenario > 1 not yet supported.
#'
#' @param PT_sim PT_sim list (output of wgen_daily_PT())
#' @param param wgen_daily_PT (RMAWGEN) parameters
#' @param station_data Station ERA5 data prepared with riversCentralAsia::prepare_RMAWGEN_input_data() function.
#' @param station_subset Character vector with station names to provided summary statistics for. If is.null(station_subset)==TRUE, station_subset = param$station.
#' @param clim_scen Climate scenario under consideration which was also used in the generation of the simulated climate in PT_sim. If is.null(clim_scen)==TRUE, the observed (ERA5) values are compared with the simulated values.
#' @return Lists with precipitation and temperature summary statistics for each station in the station_subset variable.
#' @export
wgen_daily_summaryStats <- function(PT_sim,param,station_data,station_subset,clim_scen){

  # dateVec_calibrationPeriod <- generateSeqDates(param$year_min,param$year_max,'day')
  # dateVec_baseline <- generateSeqDates(param$year_min_Baseline,param$year_max_Baseline,'day')
  # if (base::is.null(clim_scen)){
  #   dateVec_futurePeriod <- dateVec_baseline
  # } else {
  #   dateVec_futurePeriod <- generateSeqDates(PT_sim$year_min_sim,PT_sim$year_max_sim,'day')
  # }

  if (base::is.null(station_subset)){
    station_subset = param$station
  }

  climStats <- list()

  for (idx in (1:length(station_subset))){
    # PRECIPITATION
    # baseline period
    baseline_station_P <- station_data$PRECIPITATION %>%
      dplyr::select(year,station_subset[idx]) %>%
      dplyr::filter(year>=param$year_min_Baseline & year <= param$year_max_Baseline) %>%
      dplyr::select(-year) %>%
      dplyr::rename(P_baseline_obs = station_subset[idx])
    baseline_station_P_stats <- base::as.data.frame(apply(baseline_station_P,2,summary)) # render the summary() function as dataframe
    # future period
    futurePeriod_station_P <- PT_sim$P_gen$prec_gen %>% tibble::as_tibble() %>% dplyr::select(station_subset[idx])
    if (is.null(clim_scen)){
      futurePeriod_station_P <- futurePeriod_station_P %>% dplyr::rename(P_baseline_sim = station_subset[idx])
    } else {
      futurePeriod_station_P <- futurePeriod_station_P %>% dplyr::rename(P_futurePeriod_sim = station_subset[idx])
    }
    futurePeriod_station_P_stats <- base::as.data.frame(apply(futurePeriod_station_P,2,summary))
    # TMIN
    baseline_station_Tmin <- station_data$TEMPERATURE_MIN %>%
      dplyr::select(year,station_subset[idx]) %>%
      dplyr::filter(year>=param$year_min_Baseline & year <= param$year_max_Baseline) %>%
      dplyr::select(-year) %>%
      dplyr::rename(Tmin_baseline_obs = station_subset[idx])
    baseline_station_Tmin_stats <- base::as.data.frame(apply(baseline_station_Tmin,2,summary))
    # future period
    futurePeriod_station_Tmin <- PT_sim$T_gen$output$Tn_gen %>% tibble::as_tibble() %>% dplyr::select(station_subset[idx])
    if (is.null(clim_scen)){
      futurePeriod_station_Tmin <- futurePeriod_station_Tmin %>% dplyr::rename(Tmin_baseline_sim = station_subset[idx])
    } else {
      futurePeriod_station_Tmin <- futurePeriod_station_Tmin %>% dplyr::rename(Tmin_futurePeriod_sim = station_subset[idx])
    }
    futurePeriod_station_Tmin_stats <- base::as.data.frame(apply(futurePeriod_station_Tmin,2,summary))
    # TMAX
    baseline_station_Tmax <- station_data$TEMPERATURE_MAX %>%
      dplyr::select(year,station_subset[idx]) %>%
      dplyr::filter(year>=param$year_min_Baseline & year <= param$year_max_Baseline) %>%
      dplyr::select(-year) %>%
      dplyr::rename(Tmax_baseline_obs = station_subset[idx])
    baseline_station_Tmax_stats <- base::as.data.frame(apply(baseline_station_Tmax,2,summary))
    # future period
    futurePeriod_station_Tmax <- PT_sim$T_gen$output$Tx_gen %>% tibble::as_tibble() %>% dplyr::select(station_subset[idx])
    if (is.null(clim_scen)){
      futurePeriod_station_Tmax <- futurePeriod_station_Tmax %>% dplyr::rename(Tmax_baseline_sim = station_subset[idx])
    } else {
      futurePeriod_station_Tmax <- futurePeriod_station_Tmax %>% dplyr::rename(Tmax_futurePeriod_sim = station_subset[idx])
    }
    futurePeriod_station_Tmax_stats <- base::as.data.frame(apply(futurePeriod_station_Tmax,2,summary))

    # clim_stats final join
    climStats[[idx]] <- baseline_station_P_stats %>%
      add_column(futurePeriod_station_P_stats, baseline_station_Tmin_stats, futurePeriod_station_Tmin_stats,
                 baseline_station_Tmax_stats, futurePeriod_station_Tmax_stats)
  }
  names(climStats) <- station_subset
  return(climStats)
}
