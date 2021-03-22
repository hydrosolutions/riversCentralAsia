#' Extracts ERA5 basin domain from ERA5 raster bricks and scales fields with PBCORR CHELSA data so that monthly totals match.
#' Writes resulting bias corrected (scaled) data bricks to a (newly) created subdirectory where the raw ERA5 data files are stored.
#'
#'
#' @param dir_ERA5_hourly Directory where hourly ERA5 data annual NetCDF files are stored.
#' @param dataType_ERA5 Data type, currently only 'tp' or 't2m' available.
#' @param dir_CHELSA Directory where CHELSA data are stored.
#' @param startY Starting year of extraction and bias correction (>= 1981)
#' @param endY Ending year of extraction and bias correction (<= 2013)
#' @param basinName Name of basin to extract, process and store data
#' @param basin_shape_LatLon Basin Shapefile in latlon coordinates
#' @return Dateframe with dates in dd.mm.yyyy hh:mm:ss representation
#' @export
biasCorrect_ERA5_CHELSA <- function(dir_ERA5_hourly,dataType_ERA5,dir_CHELSA,startY,endY,basinName,basin_shape_LatLon){

  # Derive area of interest shape
  aoi_Basin_LatLon <- raster::extent(basin_shape_LatLon)
  # Function body from above
  # generate the dates sequence
  sTime <- base::paste0(startY,'-01-01 01:00:00')
  eTime <- base::paste0(endY,'-12-31 23:00:00')
  dateSeq_ERA <- base::seq(base::as.POSIXct(sTime), base::as.POSIXct(eTime), by="hour")
  dateSeq_ERA <- tibble::tibble(date=dateSeq_ERA, data_bcorr=NA, data_orig=NA)
  dateSeq_ERA <- dateSeq_ERA %>% dplyr::mutate(month = lubridate::month(date)) %>%
    dplyr::mutate(year = lubridate::year(date))
  # Create basin subdirectory (if not already existing) to store dedicated annual files there
  mainDir <- base::paste0(dir_ERA5_hourly,dataType_ERA5,'/')
  subDir <- basinName
  base::ifelse(!base::dir.exists(base::file.path(mainDir, subDir)),
               base::dir.create(base::file.path(mainDir, subDir)), FALSE)

  # Now starting the time loops
  for (yr in startY:endY){
    # progress indicator
    base::print(base::paste0('PROCESSING YEAR ',yr))
    # file handling
    file2Process_ERA <- base::paste0(dataType_ERA5,'/',dataType_ERA5,'_ERA5_hourly_CA_',yr,'.nc')
    era_data_orig <- raster::brick(paste0(dir_ERA5_hourly,file2Process_ERA))
    # create date-time tibble with all hours in the corresponding year
    dateSeq_ERA_year <- dateSeq_ERA %>% dplyr::filter(year == yr)

    # start the month-by-month scaling
    for (mon in 1:12){

      # sort out files paths as a function of dataType_ERA5
      if (dataType_ERA5=='t2m'){chlFName='/CHELSA_tmean_'} else {chlFName='/CHELSA_tp_bcorr_'}
      # Load corresponding tmean CHELSA Central Asia File
      if (mon<10){
        chelsa_monthly_data <-
          raster::raster(base::paste0(dir_CHELSA,dataType_ERA5,chlFName,yr,'_0',mon,'_CA_V1.2.1.tif'))
      } else {
        chelsa_monthly_data <-
          raster::raster(base::paste0(dir_CHELSA,dataType_ERA5,chlFName,yr,'_',mon,'_CA_V1.2.1.tif'))
      }
      # Cut to basin
      ## CHELSA
      chelsa_monthly_data_aoi <- raster::crop(chelsa_monthly_data,aoi_Basin_LatLon)
      if (dataType_ERA5=='t2m'){ # this is all 2m temperature specific stuff
        # aggregate the CHELSA 't2m' data to a lower resolution, i.e. decrease of resolution
        # by a factor of 25 (in X- x Y-direction)
        chelsa_monthly_data_aoi <- raster::aggregate(chelsa_monthly_data_aoi,fact = 5) # This is actually bad practice as we have hardwired fact=5.
        # Note: We do not need to do this with the bias corrected CHELSA 'tp' data which already
        # has a lower resolutions of 0.05 x 0.05
        # Convert CHELSA tmean from 10*K to K. We wait with the conversion to deg. C so as to avoid issues with T=0 in certain cells at certain times.
        chelsa_monthly_data_aoi <- chelsa_monthly_data_aoi / 10
      } else { # precipitation
        chelsa_monthly_data_aoi <- chelsa_monthly_data_aoi / 1000 # now, CHELSA P is in m, as is by default ERA5.
      }

      ## ERA5
      aoi_Basin_LatLon_buffer <- aoi_Basin_LatLon + 1
      era_data_orig_aoi <- raster::crop(era_data_orig,aoi_Basin_LatLon_buffer)

      # Subset ERA5 to selected month
      monthID_ERA <- (dateSeq_ERA_year$month == mon) %>%  base::which()
      era_data_orig_aoi_subset <- raster::subset(era_data_orig_aoi,monthID_ERA)

      # Resample era_data_orig_aoi_subset to chelsa_monthly_data_aoi specs
      era_data_orig_aoi_subset_resamp <- raster::resample(era_data_orig_aoi_subset,chelsa_monthly_data_aoi)

      # Compute monthly correction factor per cell
      if (dataType_ERA5=='t2m'){
        era_monthly_data <- raster::calc(era_data_orig_aoi_subset_resamp,mean,na.rm=TRUE)
      } else { # precipitation
        era_monthly_data <- raster::calc(era_data_orig_aoi_subset_resamp,sum,na.rm=TRUE)
        # Here, we deal with the possibility of P==0 in certain cells at the monthly levels
        era_monthly_data[era_monthly_data==0] <- NA
      }
      corrFact_ERA <- chelsa_monthly_data_aoi / era_monthly_data
      # Again, for P, we back-convert to 0 where there is NA in the cells.
      corrFact_ERA[base::is.na(corrFact_ERA[])] <- 0

      # Scaling / Bias correction
      era_data_bcorr_aoi_subset_resamp <-
        raster::overlay(era_data_orig_aoi_subset_resamp,corrFact_ERA,fun=function(x,y){return(x*y)},unstack=TRUE)

      # For temperature, we need to go from K to deg. C. Also, note again that 'tp' is in meters.
      if (dataType_ERA5=='t2m'){
        era_data_bcorr_aoi_subset_resamp <-  era_data_bcorr_aoi_subset_resamp - 273.15
      }

      # Add resulting layer to final rasterstack
      if (mon==1){
        era_data_bcorr_aoi <- era_data_bcorr_aoi_subset_resamp
      } else {
        era_data_bcorr_aoi <- raster::addLayer(era_data_bcorr_aoi,era_data_bcorr_aoi_subset_resamp)
      }
    }

    # Wrap up year and store file
    base::names(era_data_bcorr_aoi) <- base::paste0('X',base::as.character(dateSeq_ERA_year$date))
    raster::writeRaster(era_data_bcorr_aoi,
                        base::paste0(mainDir,subDir,'/',dataType_ERA5,'_ERA5_hourly_',basinName,'_bcorr_',yr,'.nc'),
                        'CDF',
                        varname   = dataType_ERA5,
                        overwrite = TRUE,
                        zname = 'time')
  }
  base::print('Monthly level scaling of hourly ERA5 data using PBCORR CHELSA v1.2.1 data correctly terminated.')
}
