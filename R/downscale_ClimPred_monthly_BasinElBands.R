#' Load Tabular Hydro-Meteorological Data
#'
#' Loads csv files with tabular hydrometeorological data where years are in rows
#' and decades or months are in columns. The function automatically detects if
#' monthly or decadal (10-day) data is provided. The function automatically computes
#' the long-term norm of the data provided and returns a time aware tibble with
#' date, data, data norm columns and code columns.
#'
#' @param pathN Path to climate projection files.
#' @param fileListSearchpattern Search pattern in climate projection files to filter climate projection scenarios. E.g. "2006-2100" for the joined CHELSA climate projection files that include the 'ACCESS1-3','CMCC-CM' and 'MIROC5' models.
#' @param startY Starting year of the climate projections.
#' @param endY Last year of climate projections.
#' @param basinElBandsShape Basin shapefile with elevation bands and subbasins that are implemented in the the semi-distributed rainfall-runoff model.
#' @return List with 4 elements, including downscaled monthly precipitation (pr), monthly mean minimum temperature (tasmean), monthly mean temperature (tasmean) and monthly mean maximum temperature (tasmax).
#' @export
downscale_ClimPred_monthly_BasinElBands <- function(pathN,fileListSearchpattern,startY,endY,basinElBandsShape){
  # Preparatory work
  ## Fancy trick to generate an empty dataframe with column names from a vector of characters.
  namesElBands <- basinElBandsShape$name
  dataElBands_df <- namesElBands %>% purrr::map_dfc(setNames, object = base::list(base::logical()))

  # Climate scenario dependent file list
  fileList <- list.files(pathN,pattern = fileListSearchpattern)

  # Generate date sequence
  sTime <- base::paste0('01.01.',startY,' 12:00:00')
  eTime <- base::paste0('01.12.',endY,' 12:00:00')
  dateElBands <-
    base::seq.POSIXt(base::as.POSIXct(sTime,format="%d.%m.%Y %H:%M:%S"),
                     base::as.POSIXct(eTime,format="%d.%m.%Y %H:%M:%S"), by="month") %>%
    tibble::as_tibble() %>% dplyr::rename(Date=value)

  # PR: Load gridded Precipitation climate projection (precipitation_flux)
  pr_bcorr <- raster::brick(paste0(pathN,fileList[1]),varname = "precipitation_flux")
  # raster::extract
  subbasin_data <- raster::extract(pr_bcorr,elBands_shp_latlon) %>% base::lapply(.,colMeans)
  subbasin_data <- subbasin_data %>% tibble::as_tibble(.,.name_repair = "unique")
  base::names(subbasin_data) <- base::names(dataElBands_df)
  pr_bcorr_elBands <- base::cbind(dateElBands,subbasin_data) %>% tibble::as_tibble()

  # TASMAX: Mean Temperature (air_temperature)
  tasmax <- raster::brick(paste0(pathN,fileList[2]),varname = "air_temperature")
  # raster::extract
  subbasin_data <- raster::extract(tasmax,elBands_shp_latlon) %>% base::lapply(.,colMeans)
  subbasin_data <- subbasin_data %>% tibble::as_tibble(.,.name_repair = "unique")
  subbasin_data <- subbasin_data - 273.15 # Data now in deg. Celsius
  base::names(subbasin_data) <- base::names(dataElBands_df)
  tasmax_elBands <- base::cbind(dateElBands,subbasin_data) %>% tibble::as_tibble()

  # TASMEAN: Mean Temperature (air_temperature)
  tasmean <- raster::brick(paste0(pathN,fileList[3]),varname = "air_temperature")
  # raster::extract
  subbasin_data <- raster::extract(tasmean,elBands_shp_latlon) %>% base::lapply(.,colMeans)
  subbasin_data <- subbasin_data %>% tibble::as_tibble(.,.name_repair = "unique")
  subbasin_data <- subbasin_data - 273.15 # Data now in deg. Celsius
  base::names(subbasin_data) <- base::names(dataElBands_df)
  tasmean_elBands <- base::cbind(dateElBands,subbasin_data) %>% tibble::as_tibble()

  # TASMIN: Mean Temperature (air_temperature)
  tasmin <- raster::brick(paste0(pathN,fileList[4]),varname = "air_temperature")
  # raster::extract
  subbasin_data <- raster::extract(tasmin,elBands_shp_latlon) %>% base::lapply(.,colMeans)
  subbasin_data <- subbasin_data %>% tibble::as_tibble(.,.name_repair = "unique")
  subbasin_data <- subbasin_data - 273.15 # Data now in deg. Celsius
  base::names(subbasin_data) <- base::names(dataElBands_df)
  tasmin_elBands <- base::cbind(dateElBands,subbasin_data) %>% tibble::as_tibble()

  # add month, day, year columns
  ## pr_bcorr
  pr_bcorr_elBands <- pr_bcorr_elBands %>%
    add_column(month=month(pr_bcorr_elBands$Date),.before=1) %>%
    add_column(day=day(pr_bcorr_elBands$Date),.before=2) %>%
    add_column(year=year(pr_bcorr_elBands$Date),.before=3)
  pr_bcorr_elBands_date <- pr_bcorr_elBands
  pr_bcorr_elBands <- pr_bcorr_elBands %>% dplyr::select(-Date)
  ## tasmax
  tasmax_elBands <- tasmax_elBands %>%
    add_column(month=month(tasmax_elBands$Date),.before=1) %>%
    add_column(day=day(tasmax_elBands$Date),.before=2) %>%
    add_column(year=year(tasmax_elBands$Date),.before=3)
  tasmax_elBands_date <- tasmax_elBands
  tasmax_elBands <- tasmax_elBands %>% dplyr::select(-Date)
  ## tasmean
  tasmean_elBands <- tasmean_elBands %>%
    add_column(month=month(tasmean_elBands$Date),.before=1) %>%
    add_column(day=day(tasmean_elBands$Date),.before=2) %>%
    add_column(year=year(tasmean_elBands$Date),.before=3)
  tasmean_elBands_date <- tasmean_elBands
  tasmean_elBands <- tasmean_elBands %>% dplyr::select(-Date)
  ## tasmin
  tasmin_elBands <- tasmin_elBands %>%
    add_column(month=month(tasmin_elBands$Date),.before=1) %>%
    add_column(day=day(tasmin_elBands$Date),.before=2) %>%
    add_column(year=year(tasmin_elBands$Date),.before=3)
  tasmin_elBands_date <- tasmin_elBands
  tasmin_elBands <- tasmin_elBands %>% dplyr::select(-Date)

  data_ClimProj_list <- list(pr=pr_bcorr_elBands,tasmin=tasmin_elBands,tasmean=tasmean_elBands,tasmax=tasmax_elBands)
  return(data_ClimProj_list)
}
