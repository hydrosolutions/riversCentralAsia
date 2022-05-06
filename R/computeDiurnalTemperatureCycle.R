#' Using ERA5 hourly data, the function computes the diurnal temperature cycle for each station.
#'
#' The function takes the tabular ERA5 input data and computes the diurnal cycle for a period of interest between param$year_min and param$yearmax
#'
#' @param era5_data ERA5 csv-file (RS MINERVE Database input) with details on stations and hourly P,T and Q data.
#' @param param Parameter list with year_min and year_max fields that denote the period of interest for which the mean diurnal per-sttion cycles should be computed.
#' @return Tibble with average diurnal temperature cycles stored in each column for each station.
#' @family Pre-processing
#' @export
computeDiurnalTemperatureCycle <- function(era5_data,param){

  # Deleting discharge Q column (we have no observations of the future discharge but rather want to simulate them)
  era5_data <- era5_data %>% dplyr::select(-which(era5_gunt_yashikul[5,]=='Q'))
  # Delete rows with NA in them (takes care of the padded NAs that was introduced by adding the Q Column)
  era5_data <- era5_data %>% stats::na.omit()


  era5_data_T <- era5_data %>% dplyr::select(which(era5_gunt_yashikul[5,]=='T'))
  # Ensure proper tibble column names
  names(era5_data_T) <- era5_data_T[1,] %>% base::as.character()

  # Generate date sequence
  era5_data_dates <-  riversCentralAsia::generateSeqDates(param$year_min,param$year_max,"hour")
  era5_data_dates <- era5_data_dates[-1,] # ERA5 only starts at 1981-01-01 01:00:00, generateSeqDates generates a sequence started at 00:00:00

  # Glue dates
  era5_data_T <- era5_data_T[-1:-8,] %>% readr::type_convert()
  era5_data_T <- era5_data_dates %>% tibble::add_column(era5_data_T)
  era5_data_T <- era5_data_T %>% dplyr::mutate(year = year(date),.before=2)

  # Select baseline period
  era5_data_T_baseline <- era5_data_T %>% dplyr::filter(year>=param$year_min_Baseline & year<=param$year_max_Baseline)

  # add hour identifier
  era5_data_T_baseline <- era5_data_T_baseline %>% dplyr::mutate(hour  = hour(date),.before = 2)

  # summarize by the hour
  diurnalStationCycles <- era5_data_T_baseline %>%
    dplyr::select(-date,-year) %>%
    tidyr::pivot_longer(-hour) %>%
    dplyr::group_by(name,hour) %>%
    dplyr::summarize(hourlyMean = mean(value)) %>%
    tidyr::pivot_wider(names_from = name,values_from = hourlyMean)

  diurnalStationCycles <- diurnalStationCycles[,c("hour",param$station)] # this is very important as the summarize function in compute DiurnalCycle() rearranges the columns alphabetically!

  return(diurnalStationCycles)

}
