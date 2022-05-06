#' Converts monthly hydro-meteorological time-series data to hydrological year values.
#'
#' Conversion to hydrological year values from Oct. to the following year end of Sept.. Cold season and warm season
#' components are calculated.
#'
#' @param data2convert tibble with the format as packaged in the accompagning dataset ChirchikRiverData
#' @param stationCode String with 5-digit station code
#' @param typeSel Either 'Q' for discharge, 'mean(T)' for mean temperatures or 'P' for total precipitation
#' @return tibble dataframe date column and hydrological year, cold season and warm season values columns.
#' @family Helper functions
#' @export
convert2HYY <- function(data2convert,stationCode,typeSel){

  # helper function to search for first entry in tibble that is equal to value
  first_equal_to = function(x, value){(x == value) & (base::cumsum(x == value) == 1)}

  # 1. Select data
  if ("type" %in% base::colnames(data2convert)) {
    dataSel_mon <- data2convert %>%
      dplyr::filter(type == typeSel & code == stationCode & resolution == 'mon') %>%
      dplyr::mutate(month = lubridate::month(date)) %>%
      dplyr::select(date,data,month) %>%
      dplyr::arrange(date)
  } else { # this converts multiple timeseries
    dataSel_mon <- data2convert %>%
      dplyr::mutate(month = lubridate::month(date)) %>%
      dplyr::arrange(date)
  }

  # 2. Check if data is complete for the computation of hydrological years
  ## this is taking care of the start of the time series
  dataSel_mon <- dataSel_mon %>% dplyr::mutate(firstOct = first_equal_to(month,10))
  n2del <- base::which(dataSel_mon$firstOct)
  dataSel_mon <- dataSel_mon %>% dplyr::slice(n2del:n())
  ## end of time series
  dataSel_mon_rev <- dataSel_mon %>% purrr::map_df(rev)
  dataSel_mon_rev <- dataSel_mon_rev %>% dplyr::mutate(lastSept = first_equal_to(month,9))
  n2del <- base::which(dataSel_mon_rev$lastSept)
  dataSel_mon <- dataSel_mon_rev %>% dplyr::slice(n2del:n()) %>% purrr::map_df(rev) %>%
    dplyr::select(-month,-firstOct,-lastSept)

  # 3. Augment dataframe
  dataSel_mon_aug <- dataSel_mon %>%
    dplyr::mutate(monHY = (((lubridate::month(date)-1)+3)%%12) + 1) %>%  # now we have added a monHY column.
    dplyr::mutate(monHYdate = date %m+% base::months(3)) %>%
    dplyr::mutate(daysMonth = lubridate::days_in_month(date)) %>%
    dplyr::mutate(qtr = lubridate::quarter(monHYdate))

  if (typeSel=='Q'){
    # compute the monthly discharge volume
    dataSel_mon_aug <- dataSel_mon_aug %>%
      dplyr::mutate(dataMon = (data * daysMonth * 3600 * 24))
    # Summarize using the 'fake' month dates and convert back to mean per second discharge
    ## full year
    dataHYY <- dataSel_mon_aug %>%
      dplyr::select(monHYdate,dataMon,daysMonth) %>%
      timetk::summarise_by_time(.date_var = monHYdate,.by = "year",
                                Q_mean_ann = base::sum(dataMon),
                                n_days = base::sum(daysMonth)) %>%
      dplyr::mutate(Q_mean_ann = Q_mean_ann / n_days / 24 / 3600) %>%
      dplyr::select(-n_days)
    ## cold season
    dataHYY_cs <- dataSel_mon_aug %>%
      dplyr::filter(qtr==1 | qtr==2) %>%
      dplyr::select(monHYdate,dataMon,daysMonth) %>%
      timetk::summarise_by_time(.date_var = monHYdate,.by = "year",
                                Q_mean_cs = base::sum(dataMon),
                                n_days = base::sum(daysMonth)) %>%
      dplyr::mutate(Q_mean_cs = Q_mean_cs / n_days / 24 / 3600) %>%
      dplyr::select(-n_days)
    ## warm season
    dataHYY_ws <- dataSel_mon_aug %>%
      dplyr::filter(qtr==3 | qtr==4) %>%
      dplyr::select(monHYdate,dataMon,daysMonth) %>%
      timetk::summarise_by_time(.date_var = monHYdate,.by = "year",
                                Q_mean_ws = base::sum(dataMon),
                                n_days = base::sum(daysMonth)) %>%
      dplyr::mutate(Q_mean_ws = Q_mean_ws / n_days / 24 / 3600) %>%
      dplyr::select(-n_days)
  } else if (typeSel=='mean(T)'){
    # Summarize using the 'fake' month dates and take the mean
    ## full year
    dataHYY <- dataSel_mon_aug %>% dplyr::select(-date,-monHY,-daysMonth,-qtr) %>%
      tidyr::pivot_longer(-monHYdate) %>% dplyr::group_by(name) %>%
      timetk::summarize_by_time(.date_var = monHYdate,.by = "year", value = base::mean(value)) %>%
      tidyr::pivot_wider(names_from = name,values_from = value)
    ## cold season
    dataHYY_cs <- dataSel_mon_aug %>%
      dplyr::filter(qtr==1|qtr==2) %>%
      dplyr::select(-date,-monHY,-daysMonth,-qtr) %>% tidyr::pivot_longer(-monHYdate) %>%
      dplyr::group_by(name) %>%
      timetk::summarise_by_time(.date_var = monHYdate,.by = "year", value = base::mean(value)) %>%
      tidyr::pivot_wider(names_from = name,values_from = value) %>%
      rename_with(~paste0(., "_cs"), -"monHYdate")
    ## warm season
    dataHYY_ws <- dataSel_mon_aug %>%
      dplyr::filter(qtr==3|qtr==4) %>%
      dplyr::select(-date,-monHY,-daysMonth,-qtr) %>% tidyr::pivot_longer(-monHYdate) %>%
      dplyr::group_by(name) %>%
      timetk::summarise_by_time(.date_var = monHYdate,.by = "year", value = base::mean(value)) %>%
      tidyr::pivot_wider(names_from = name,values_from = value) %>%
      dplyr::rename_with(~paste0(., "_ws"), -"monHYdate")
  } else if (typeSel=='P'){
    # Summarize using the 'fake' month dates and sum
    ## full year
    dataHYY <- dataSel_mon_aug %>% dplyr::select(-date,-monHY,-daysMonth,-qtr) %>%
      tidyr::pivot_longer(-monHYdate) %>% dplyr::group_by(name) %>%
      timetk::summarize_by_time(.date_var = monHYdate,.by = "year", value = base::sum(value)) %>%
      tidyr::pivot_wider(names_from = name,values_from = value)
    ## cold season
    dataHYY_cs <- dataSel_mon_aug %>%
      dplyr::filter(qtr==1|qtr==2) %>%
      dplyr::select(-date,-monHY,-daysMonth,-qtr) %>% tidyr::pivot_longer(-monHYdate) %>%
      dplyr::group_by(name) %>%
      timetk::summarise_by_time(.date_var = monHYdate,.by = "year", value = base::sum(value)) %>%
      tidyr::pivot_wider(names_from = name,values_from = value) %>%
      dplyr::rename_with(~paste0(., "_cs"), -"monHYdate")
    ## warm season
    dataHYY_ws <- dataSel_mon_aug %>%
      dplyr::filter(qtr==3|qtr==4) %>%
      dplyr::select(-date,-monHY,-daysMonth,-qtr) %>% tidyr::pivot_longer(-monHYdate) %>%
      dplyr::group_by(name) %>%
      timetk::summarise_by_time(.date_var = monHYdate,.by = "year", value = base::sum(value)) %>%
      tidyr::pivot_wider(names_from = name,values_from = value) %>%
      dplyr:: rename_with(~paste0(., "_ws"), -"monHYdate")
  }

  # everything together
  dataHYY <- dplyr::full_join(dataHYY, dataHYY_cs, by="monHYdate")
  dataHYY <- dplyr::full_join(dataHYY, dataHYY_ws, by='monHYdate') %>%
    dplyr::rename(hyYear = monHYdate)

  # 6. Return Object
  return(dataHYY)
}
