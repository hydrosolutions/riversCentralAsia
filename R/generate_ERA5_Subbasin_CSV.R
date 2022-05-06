#' Extract subbasin-level and elevation band-specific hourly time series from ERA5 raster bricks
#'
#' Function extracts precipitation (tp) or temperature (t2m) data from raster bricks and prepares a dataframe for
#' later import in RSMinerve (use write.table() function to export as csv). If tp and t2m have to be exported,
#' the function has to be called twice and the resulting tibble columns added.
#'
#' @param dir_ERA5_hourly Path to original stored DEM file (generate_ERA5_Subbasin_CSV assumes the following folder structure: <dir_ERA5_hourly>/<tp or t2m>/<catchmentName>/*.nc)
#' @param catchmentName Name of catchment for which data should be extracted (depends on proper local file storage)
#' @param dataType Currently, only 'tp' or 't2m' as valid options
#' @param elBands_shp Subbasin-level shapefile with elevation bands
#' @param startY Starting year for which data should be made available (assuming data 'is' available from the start of that year)
#' @param endY Ending year from which data should be extracted (assuming data 'is' actually available until the end of that year)
#' @return Dataframe tibble with temperature in deg. C. or precipitation in mm/h
#' @family Pre-processing
#' @export
generate_ERA5_Subbasin_CSV <- function(dir_ERA5_hourly,catchmentName,dataType,elBands_shp,startY,endY){

  # Generate file list to load
  yrs <- startY:endY
  fileList <- tibble::tibble(fName=NA)
  for (idx in 1:base::length(yrs)){
    newName <- base::paste0(dataType,'_ERA5_hourly_',catchmentName,'_bcorr_',yrs[idx],'.nc') %>%
      tibble::as_tibble() %>% dplyr::rename(fName = value)
    fileList <- fileList %>% tibble::add_row(newName)
  }
  fileList <- fileList %>% stats::na.omit()
  # Since the brick raster data is in +longlat, ensure elBands_shp is in the same crs.
  elBands_shp_latlon <- sf::st_transform(elBands_shp,crs = sf::st_crs(4326))
  # Generate date sequence (Note: Dates sequence in accordance with RSMinerve Requirements)
  dateElBands <- generateSeqDates(startY,endY,'hour') %>% dplyr::slice(-1)
  # Now, solve that obnoxious time formatting problem for compatibility with RSMinerve (see function posixct2rsminerveChar() for more details)
  datesChar <- riversCentralAsia::posixct2rsminerveChar(dateElBands$date)
  datesChar <- datesChar %>% dplyr::rename(Station=value)

  namesElBands <- elBands_shp$name
  dataElBands_df <- namesElBands %>% purrr::map_dfc(setNames, object = base::list(base::logical())) # fancy trick
  # to generate an empty dataframe with column names from a vector of characters.

  # Now, loop through the subbasins, one by one.
  for (yr in 1:length(fileList$fName)){
    base::print(base::paste0('Processing File: ', fileList$fName[yr]))
    file2Process_ERA <- fileList$fName[yr]
    era_data <- raster::brick(base::paste0(dir_ERA5_hourly,dataType,'/',catchmentName,'/',file2Process_ERA))
    #subbasin_data <- raster::extract(era_data,elBands_shp_latlon) %>% base::lapply(.,colMeans,na.rm=TRUE)
    subbasin_data <- exactextractr::exactextract(era_data,elBands_shp_latlon) %>% base::lapply(.,colMeans,na.rm=TRUE)
    subbasin_data <- subbasin_data %>% tibble::as_tibble(.,.name_repair = "unique")
    if (dataType=='tp'){subbasin_data <- subbasin_data * 1000} # this converts the precipitation to mm/h
    base::names(subbasin_data) <- base::names(dataElBands_df)
    dataElBands_df <- dataElBands_df %>% tibble::add_row(subbasin_data)
  }

  # Final data tibble
  dataElBands_df_data <- dataElBands_df %>% dplyr::mutate_all(as.character)
  dataElBands_df_data <- base::cbind(datesChar,dataElBands_df) %>% tibble::as_tibble()

  # Construct csv-file header.  See the definition of the RSMinerve .csv database file at:
  # https://www.youtube.com/watch?v=p4Zh7zBoQho
  dataElbands_df_header_Station <- tibble::tibble(Station = c('X','Y','Z','Sensor','Category','Unit','Interpolation'))
  dataElBands_df_body <- namesElBands %>% purrr::map_dfc(setNames, object = base::list(base::logical()))
  # get XY (via centroids) and Z (mean alt. band elevation)
  elBands_XY <- sf::st_transform(elBands_shp,crs = sf::st_crs(32642)) %>% sf::st_centroid() %>% sf::st_coordinates() %>% tibble::as_tibble()
  elBands_Z <- elBands_shp$Z %>% tibble::as_tibble() %>% dplyr::rename(Z = value)
  elBands_XYZ <- base::cbind(elBands_XY, elBands_Z) %>% base::as.matrix() %>% base::t() %>% tibble::as_tibble() %>% dplyr::mutate_all(as.character)
  base::names(elBands_XYZ) <- base::names(dataElBands_df_body)
  # Sensor (P or T), Category, Unit and Interpolation
  nBands <- elBands_XYZ %>% base::dim() %>% dplyr::last()
  if (dataType=='tp'){
    sensorType <- 'P' %>% base::rep(.,nBands)
    category <- 'Precipitation' %>% base::rep(.,nBands)
    unit <- 'mm/h' %>% base::rep(.,nBands)
    interpolation <- 'Linear' %>% base::rep(.,nBands)
    sensor <- base::rbind(sensorType,category,unit,interpolation) %>% tibble::as_tibble()
  } else {
    sensorType <- 'T' %>% base::rep(.,nBands)
    category <- 'Temperature' %>% base::rep(.,nBands)
    unit <- 'C' %>% base::rep(.,nBands)
    interpolation <- 'Linear' %>% base::rep(.,nBands)
    sensor <- base::rbind(sensorType,category,unit,interpolation) %>% tibble::as_tibble()
  }
  base::names(sensor) <- base::names(dataElBands_df_body)
  # Put everything together
  file2write <- elBands_XYZ %>% tibble::add_row(sensor)
  file2write <- dataElbands_df_header_Station %>% tibble::add_column(file2write)
  file2write <- file2write %>% tibble::add_row(dataElBands_df_data %>% dplyr::mutate_all(as.character))
  file2write <- base::rbind(base::names(file2write),file2write)
  base::return(file2write)
}
