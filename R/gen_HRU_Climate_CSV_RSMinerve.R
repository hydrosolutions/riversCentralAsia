#' Extract hydrological response unit HRU specific climate time series from nc-files.
#'
#' Function extracts precipitation (tp) or temperature (tas_) data from climate raster bricks (observed history obs_hist,
#' GCM-simulated history hist_sim and GCM-simulated future fut_sim) and prepares a dataframe for
#' later import in RSMinerve (use readr::write_csv(.,col_names=FALSE)). tp and tas_ have to be exported,
#' the function has to be called twice and the resulting tibble columns added.
#'
#' @param climate_files List of either temperature or precipitation climate .nc files to process (do not mix!). Make sure the file list time interval is consistent with startY and endY.
#' @param catchmentName Name of catchment for which data should be extracted
#' @param dataType Either 'Temperature' or 'Precipitation'
#' @param elBands_shp Shapefile with hydrological response units. The column containing the names of the hydrological response
#'   units must be \code{name} and the column containing the average elevation of the elevation band must be \code{Z}.
#' @param startY Starting year for which data should be made available (assuming data 'is' available from the start of that year)
#' @param endY Ending year from which data should be extracted (assuming data 'is' actually available until the end of that year)
#' @param obs_frequency Climate observation frequency ('hour', 'day', 'month')
#' @param climate_data_type String of denoting observation type. Either 'hist_obs' (historical observations, i.e. CHELSA V21 high resolution climate data), 'hist_sim' (GCM model output data over the historical period) and 'fut_sim' (fture GCM simulations)
#' @param crs_in_use 4 digit crs code to ensure projection consistency between raster and shapefile.
#' @param output_file_dir Path to output file dir (if empty, file will not be written)
#' @param tz Time zone information. Default "UTC" which can be overridden.
#' @return Dataframe tibble with temperature in deg. C. or precipitation in mm/h
#' @family Pre-processing
#' @export
gen_HRU_Climate_CSV_RSMinerve <- function(climate_files,
                                          catchmentName,
                                          temp_or_precip,
                                          elBands_shp,
                                          startY,
                                          endY,
                                          obs_frequency,
                                          climate_data_type,
                                          crs_in_use,
                                          output_file_dir=0,
                                          gcm_model=0,
                                          gcm_scenario=0,
                                          tz = "UTC"){

  # Ensure conforming crs
  elBands_shp_latlon <- sf::st_transform(elBands_shp,crs = sf::st_crs(crs_in_use))

  # Generate date sequence in accordance with RSMinerve Requirements
  dateElBands <- riversCentralAsia::generateSeqDates(startY,endY,obs_frequency,tz)
  datesChar <- riversCentralAsia::posixct2rsminerveChar(dateElBands$date,tz) %>% dplyr::rename(Station=value)

  # Get names of elevation bands
  namesElBands <- elBands_shp$name
  dataElBands_df <- namesElBands %>% purrr::map_dfc(setNames, object = base::list(base::logical())) # fancy trick to generate an empty dataframe with column names from a vector of characters.

  # .nc-file extraction
  for (yrIDX in 1:base::length(climate_files)){
    base::print(base::paste0('Processing File: ', climate_files[yrIDX]))
    histobs_data <- raster::brick(base::paste0(climate_files[yrIDX]))
    #raster::crs(histobs_data) <- base::paste0("EPSG:",crs_in_use)
    subbasin_data <- exactextractr::exact_extract(histobs_data,elBands_shp_latlon,'mean') %>% t() %>% tibble::as_tibble(.,.name_repair = "unique") %>% dplyr::slice(1:base::nrow(dateElBands))
    # if endY is not corresponding to end date of .nc-file, we need to slice it!
    base::names(subbasin_data) <- base::names(dataElBands_df)
    dataElBands_df <- dataElBands_df %>% tibble::add_row(subbasin_data)
  }
  dataElBands_df_data <- base::cbind(datesChar,dataElBands_df) %>% tibble::as_tibble()

  # Construct csv-file header.  See the definition of the RSMinerve .csv database file at:
  # https://www.youtube.com/watch?v=p4Zh7zBoQho
  dataElbands_df_header_Station <- tibble::tibble(Station = c('X','Y','Z','Sensor','Category','Unit','Interpolation'))
  dataElBands_df_body <- namesElBands %>% purrr::map_dfc(setNames, object = base::list(base::logical()))

  # Get XY (via centroids) and Z (mean alt. band elevation)
  elBands_XY <- sf::st_transform(elBands_shp,crs = sf::st_crs(32642)) %>% sf::st_centroid() %>% sf::st_coordinates() %>% tibble::as_tibble()
  elBands_Z <- elBands_shp$Z %>% tibble::as_tibble() %>% dplyr::rename(Z = value)
  elBands_XYZ <- base::cbind(elBands_XY, elBands_Z) %>% base::as.matrix() %>% base::t() %>% tibble::as_tibble() %>% dplyr::mutate_all(as.character)
  base::names(elBands_XYZ) <- base::names(dataElBands_df_body)

  # Sensor (P or T), Category, Unit and Interpolation
  nBands <- elBands_XYZ %>% base::dim() %>% dplyr::last()
  if (temp_or_precip=='Temperature'){
    sensorType <- 'T' %>% base::rep(.,nBands)
    unit <- 'C' %>% base::rep(.,nBands)
  } else {
    sensorType <- 'P' %>% base::rep(.,nBands)
    unit <- 'mm/d' %>% base::rep(.,nBands)
  }
  category <- temp_or_precip %>% base::rep(.,nBands)
  interpolation <- 'Linear' %>% base::rep(.,nBands)
  sensor <- base::rbind(sensorType,category,unit,interpolation) %>% tibble::as_tibble()
  base::names(sensor) <- base::names(dataElBands_df_body)

  # Put everything together
  file2write <- elBands_XYZ %>% tibble::add_row(sensor)
  file2write <- dataElbands_df_header_Station %>% tibble::add_column(file2write)
  file2write <- file2write %>% tibble::add_row(dataElBands_df_data %>% dplyr::mutate_all(as.character))
  file2write <- base::rbind(base::names(file2write),file2write)

  # Write file to disk
  if (output_file_dir != 0){
    if (gcm_model==0 & gcm_scenario==0){
      readr::write_csv(file2write,base::paste0(output_file_dir,climate_data_type,"_",temp_or_precip,"_",startY,"_",endY,"_",catchmentName,".csv"),col_names = FALSE)
    } else if (gcm_model!=0 & gcm_scenario==0) {
      readr::write_csv(file2write,base::paste0(output_file_dir,climate_data_type,"_",gcm_model,"_",temp_or_precip,"_",startY,"_",endY,"_",catchmentName,".csv"),col_names = FALSE)
    } else if (gcm_model!=0 & gcm_scenario!=0) {
      readr::write_csv(file2write,base::paste0(output_file_dir,climate_data_type,"_",gcm_model,"_",gcm_scenario,"_",temp_or_precip,"_",startY,"_",endY,"_",catchmentName,".csv"),col_names = FALSE)
    }
  }

  # Return file
  base::return(file2write)
}
