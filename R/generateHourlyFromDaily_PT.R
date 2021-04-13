#' Generate hourly precipitation and temperature time series from daily data
#'
#' The function uses different gap filling methods to a) compute hourly precipitation, and b) compute hourly temperatures for all stations/elevation bands. Daily precipitation values are uniformly distributed over the day and temerpatures are calculated to fit a typical diurnal station cycle between daily Tmin and Tmax (output of stochastic weather generator). The diurnal cycle can be calculated by the function diurnalTempCycle_stations().
#'
#' @param PT_sim Climate scenario dependent daily precipitation and temperature station values
#' @param era5_data Full ERA5 data frame
#' @param param Stochastic weather simulation parameters
#' @return List with climate scenario dependent hourly P and T data as direct input for RS MINERVE.
#' @export
generateHourlyFromDaily_PT <- function(PT_sim,era5_data,param){

  hourly_climScen <- list()
  for (idx in 1:length(PT_sim)){
    # ===========================
    # Conversion of precipitation
    dateVec <- riversCentralAsia::generateSeqDates(PT_sim[[idx]]$year_min_sim,PT_sim[[idx]]$year_max_sim,"day")
    dateVec <- dateVec$date %>% tibble::as_tibble() %>% dplyr::rename(date=value)
    P_daily <- dateVec %>% tibble::add_column((PT_sim[[idx]]$P_gen$prec_gen / 24) %>% tibble::as_tibble()) # dividing to mm/hour for later gap filling
    P_daily <- P_daily %>% dplyr::bind_rows(P_daily[base::rep(base::nrow(P_daily), 1),] %>%
                                              dplyr::mutate(date = date + lubridate::days(1))) # Trick: Add duplicated last line with + 1 day
    P_hourly <- P_daily %>% timetk::pad_by_time(.date_var = date,.by = "hour") %>%
      tidyr::fill(everything(),.direction = 'down')
    P_hourly <- P_hourly %>% dplyr::filter(dplyr::row_number() <= dplyr::n()-1) # remove that added last day row again.
    # =========================
    # Conversion of temperature
    # A. CLIMATE SCENARIOS
    Tmin <- PT_sim[[idx]]$T_gen$output$Tn_gen %>% tibble::as_tibble()
    Tmax <- PT_sim[[idx]]$T_gen$output$Tx_gen %>% tibble::as_tibble()
    Tmean <- (Tmin + Tmax) / 2
    dateVec <- riversCentralAsia::generateSeqDates(PT_sim[[idx]]$year_min_sim,
                                                   PT_sim[[idx]]$year_max_sim,'day')
    Tmin_daily <- dateVec %>% tibble::add_column(Tmin)
    Tmax_daily <- dateVec %>% tibble::add_column(Tmax)
    Tmean_daily <- dateVec %>% tibble::add_column(Tmean)
    Tmin_daily <- Tmin_daily %>%
      dplyr::bind_rows(Tmin_daily[base::rep(base::nrow(Tmin_daily), 1),] %>%
                         dplyr::mutate(date = date + lubridate::days(1))) # Trick: Add duplicated last line with + 1 day
    Tmax_daily <- Tmax_daily %>%
      dplyr::bind_rows(Tmax_daily[base::rep(base::nrow(Tmax_daily), 1),] %>%
                         dplyr::mutate(date = date + lubridate::days(1))) # Trick: Add duplicated last line with + 1 day
    Tmean_daily <- Tmean_daily %>%
      dplyr::bind_rows(Tmin_daily[base::rep(base::nrow(Tmean_daily), 1),] %>%
                         dplyr::mutate(date = date + lubridate::days(1))) # Trick: Add duplicated last line with + 1 day
    # Daily to hourly data frames
    Tmin_hourly <- Tmin_daily %>%
      timetk::pad_by_time(.date_var = date,.by = "hour") %>%
      tidyr::fill(everything(),.direction = 'down') %>%
      dplyr::filter(dplyr::row_number() <= dplyr::n()-1) # remove that added last day row again.
    Tmax_hourly <- Tmax_daily %>% timetk::pad_by_time(.date_var = date,.by = "hour") %>%
      tidyr::fill(everything(),.direction = 'down') %>%
      dplyr::filter(dplyr::row_number() <= dplyr::n()-1) # remove that added last day row again.
    Tmean_hourly <- Tmean_daily %>% timetk::pad_by_time(.date_var = date,.by = "hour") %>%
      tidyr::fill(everything(),.direction = 'down') %>%
      dplyr::filter(dplyr::row_number() <= dplyr::n()-1) # remove that added last day row again.

    Tmin_hourly_mat <- Tmin_hourly %>% dplyr::select(-date) %>% as.matrix()
    Tmax_hourly_mat <- Tmax_hourly %>% dplyr::select(-date) %>% as.matrix()
    Tmean_hourly_mat <- Tmean_hourly %>% dplyr::select(-date) %>% as.matrix()

    # B. ERA5
    diurnalCycle <- computeDiurnalTemperatureCycle(era5_data,param)
    diurnalCycle_era5_mean0 <- diurnalCycle %>% dplyr::select(-hour) %>%
      dplyr::mutate(across(.cols=everything(),~ . - mean(.))) %>%
      tibble::add_column(hour=diurnalCycle$hour,.before = 1)
    diurnalCycle_era5_max <- diurnalCycle_era5_mean0 %>% dplyr::select(-hour) %>%
      dplyr::mutate(across(.cols=everything(),~ max(.))) %>%
      tibble::add_column(hour=diurnalCycle$hour,.before = 1)
    diurnalCycle_era5_min <- diurnalCycle_era5_mean0 %>% dplyr::select(-hour) %>%
      dplyr::mutate(across(.cols=everything(),~ min(.))) %>%
      tibble::add_column(hour=diurnalCycle$hour,.before = 1)

    diurnalCycle_era5_mean0 <- diurnalCycle_era5_mean0 %>% dplyr::select(-hour)
    diurnalCycle_era5_min <- diurnalCycle_era5_min %>% dplyr::select(-hour)
    diurnalCycle_era5_max <- diurnalCycle_era5_max %>% dplyr::select(-hour)

    # Repeat cycles for the total number of days.
    dC_era5_mean0_rep_mat <- do.call("rbind", base::replicate(n=base::nrow(dateVec),
                                       diurnalCycle_era5_mean0, simplify = FALSE)) %>% as.matrix()
    dC_era5_min_rep_mat <- do.call("rbind", base::replicate(n=base::nrow(dateVec),
                                       diurnalCycle_era5_min, simplify = FALSE)) %>% as.matrix()
    dC_era5_max_rep_mat <- do.call("rbind", base::replicate(n=base::nrow(dateVec),
                                       diurnalCycle_era5_max, simplify = FALSE)) %>% as.matrix()

    # C. Adjust ERA5 diurnal cycle to daily Tmin and Tmax ranges (rescaling and shift to new mean)
    TP_hourly_scenario <- dC_era5_mean0_rep_mat
    # Scale values
    TP_hourly_scenario <- (TP_hourly_scenario - dC_era5_min_rep_mat) / (dC_era5_max_rep_mat - dC_era5_min_rep_mat) *
      (Tmax_hourly_mat - Tmin_hourly_mat) + Tmin_hourly_mat

    TP_hourly_scenario <- TP_hourly_scenario %>% tibble::as_tibble()
    base::names(TP_hourly_scenario) <- base::names(diurnalCycle_era5_mean0)
    TP_hourly_scenario <- TP_hourly_scenario %>% tibble::add_column(date=Tmean_hourly$date,.before = 1)
    # D. Resulting hourly temperature
    TP_hourly_scenario <- TP_hourly_scenario %>%
      tibble::add_column(P_hourly %>% dplyr::select(-date), .name_repair = "unique")
    # Fix dates to confirm to RS MINERVE
    fixedDates <- posixct2rsminerveChar(TP_hourly_scenario$date) %>% rename(date=value)
    TP_hourly_scenario <- TP_hourly_scenario %>% dplyr::select(-date) %>% add_column(fixedDates,.before = 1)
    hourly_climScen[[idx]] <- TP_hourly_scenario
  }
  base::names(hourly_climScen) <- base::names(PT_sim)
  return(hourly_climScen)
}

