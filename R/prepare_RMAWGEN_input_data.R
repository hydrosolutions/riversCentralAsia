#' Prepare RMAWGEN input files from RS MINERVE data file that contains hourly observations
#'
#' Based on the basin-specific RS MINERVE database csv file, the function computes input files for the RMAWGEN precipitation and temperature weather generator.
#'
#' @param rsMinerve_data_csv_tibble RS MINERVE loaded csv file - read.table(paste0(filePath,fileName),sep=',') -
#' @return List with 4 elements, including downscaled monthly precipitation (pr), monthly mean minimum temperature (tasmean), monthly mean temperature (tasmean) and monthly mean maximum temperature (tasmax).
#' @family Pre-processing
#' @export
prepare_RMAWGEN_input_data <- function(rsMinerve_data_csv_tibble){

  # Housekeeping
  # Delete Q column
  rsMinerve_data_csv_tibble <- rsMinerve_data_csv_tibble %>% dplyr::select(-which(rsMinerve_data_csv_tibble[5,]=='Q'))
  # Delete rows with NA in them (takes care of the padded NAs that was introduced by adding the Q Column)
  rsMinerve_data_csv_tibble <- rsMinerve_data_csv_tibble %>% na.omit()
  # list to return
  station_data <- list()

  base:: names(rsMinerve_data_csv_tibble) <- rsMinerve_data_csv_tibble[1,] %>% base::as.character()
  stationSelection <- rsMinerve_data_csv_tibble %>% dplyr::select(which(rsMinerve_data_csv_tibble[5,]=='T'))
  station_data$STATION_NAMES <- stationSelection %>% base::names()
  station_data$ELEVATION <- stationSelection[4,]
  station_data$STATION_LATLON <- stationSelection[2:3,] %>% readr::type_convert() %>% t()
  station_data$LOCATION <- station_data$STATION_NAMES

  # Create date sequence
  dateSeq <- rsMinerve_data_csv_tibble %>% dplyr::select(Station)
  dateSeq <- dateSeq[-1:-8,1]
  dateSeq <- dateSeq %>% unlist(use.names = FALSE)
  dateSeq <- lubridate::parse_date_time(dateSeq,"%d.%m.%Y %H:%M:%S")
  dateSeq <- tibble::tibble(date=dateSeq,data=NA)

  # Generate PRECIPITATION dataframes
  PRECIPITATION <- rsMinerve_data_csv_tibble %>% dplyr::select(which(rsMinerve_data_csv_tibble[5,]=='P'))
  PRECIPITATION <- PRECIPITATION[-1:-8,] %>% readr::type_convert()
  PRECIPITATION <- PRECIPITATION %>% tibble::add_column(date = dateSeq$date,.before = 1)
  ## Convert to daily
  PRECIPITATION <- PRECIPITATION %>% tidyr::pivot_longer(-date) %>% dplyr::group_by(name) %>%
    timetk::summarize_by_time(.date_var = date,.by="day",dailyP = sum(value)) %>% tidyr::pivot_wider(names_from = name,values_from = dailyP)
  station_data$PRECIPITATION <- PRECIPITATION %>% tibble::add_column(month=month(PRECIPITATION$date),.before = 1) %>%
    tibble::add_column(day=day(PRECIPITATION$date),.before = 2) %>% tibble::add_column(year=year(PRECIPITATION$date),.before = 3) %>% dplyr::select(-date)

  # Generate TEMPERATURE dataframes
  TEMPERATURE <- rsMinerve_data_csv_tibble %>% dplyr::select(which(rsMinerve_data_csv_tibble[5,]=='T'))
  TEMPERATURE <- TEMPERATURE[-1:-8,] %>% readr::type_convert()
  TEMPERATURE <- TEMPERATURE %>% tibble::add_column(date = dateSeq$date,.before = 1)

  ## convert to daily
  TEMPERATURE_MIN <- TEMPERATURE %>% tidyr::pivot_longer(-date) %>% dplyr::group_by(name) %>%
    timetk::summarize_by_time(.date_var = date,.by="day",dailyMinT = min(value)) %>% tidyr::pivot_wider(names_from = name,values_from = dailyMinT)
  TEMPERATURE_MAX <- TEMPERATURE %>% tidyr::pivot_longer(-date) %>% dplyr::group_by(name) %>%
    timetk::summarize_by_time(.date_var = date,.by="day",dailyMaxT = max(value)) %>% tidyr::pivot_wider(names_from = name,values_from = dailyMaxT)

  ## final dfs
  station_data$TEMPERATURE_MIN <- TEMPERATURE_MIN %>%
    tibble::add_column(month=month(TEMPERATURE_MIN$date),.before = 1) %>%
    tibble::add_column(day=day(TEMPERATURE_MIN$date),.before = 2) %>%
    tibble::add_column(year=year(TEMPERATURE_MIN$date),.before = 3) %>% dplyr::select(-date)

  station_data$TEMPERATURE_MAX <- TEMPERATURE_MAX %>%
    tibble::add_column(month=month(TEMPERATURE_MAX$date),.before = 1) %>%
    tibble::add_column(day=day(TEMPERATURE_MAX$date),.before = 2) %>%
    tibble::add_column(year=year(TEMPERATURE_MAX$date),.before = 3) %>% dplyr::select(-date)

  #    TEMPERATURE <- TEMPERATURE %>%
  #    tibble::add_column(month=month(TEMPERATURE$date),.before = 1) %>%
  #    tibble::add_column(day=day(TEMPERATURE$date),.before = 2) %>%
  #    tibble::add_column(year=year(TEMPERATURE$date),.before = 3)
  #  TEMPERATURE <- TEMPERATURE %>% dplyr::select(-date)

  # list2Return <- list(
  #   STATION_NAMES = STATION_NAMES,
  #   ELEVATION = ELEVATION,
  #   STATION_LATLON = STATION_LATLON,
  #   LOCATION = LOCATION,
  #   PRECIPITATION = PRECIPITATION,
  #   #TEMPERATURE = TEMPERATURE,
  #   TEMPERATURE_MIN = TEMPERATURE_MIN,
  #   TEMPERATURE_MAX = TEMPERATURE_MAX
  # )



  return(station_data)

}
