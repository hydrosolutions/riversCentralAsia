#' Import iEasyHydro Data
#'
#' Loads csv files that were exported from iEasyHydro. The function automatically computes
#' the long-term norm of the data provided and returns a time aware tibble with
#' date, data, data norm columns and code columns, etc. This function is an adapted version
#' of the riversCentralAsis::loadTabularData() function.
#'
#' @param fPath Path to the input file
#' @param fName File name
#' @param code Hydrometeorological station code
#' @param stationName Hydrometeorological station name/location
#' @param rName Name of river
#' @param rBasin Name of basin
#' @param dataType Type of data, either `Q` (discharge data), `T` (temperature data) or `P` (precipitation data)
#' @param units Data units
#' @param x_UTM42N x coordinates in UTM42N
#' @param y_UTM42N y coordinates in UTM42N
#' @param masl station elevation
#' @param basin_size basin size in km^2
#' @return Time-aware tibble with relevant data
#' @family Pre-processing
#' @export
import_iEasyHydro_data <- function(fPath,fName,code,stationName,rName,rBasin,dataType,units,x_UTM42N,y_UTM42N,masl,basin_size){

  q <- readr::read_delim(paste0(fPath,fName), col_names = FALSE, col_types = readr::cols(),delim='\t')
  q <- q %>% dplyr::rename(date=X1,Q=X2)
  q_dates <- q %>% dplyr::select(date) %>% tidyr::separate(date,c("dmy","hms"),". ")
  q_dates$dmy <- q_dates$dmy %>% lubridate::dmy()
  q <- q_dates %>% dplyr::select(dmy) %>% tibble::add_column(data=q$Q) %>% dplyr::filter(dmy<=base::as.Date('2012-12-31'))
  q <- q %>% dplyr::rename(date=dmy)
  q$date <- q$date - lubridate::days(4) # set dates to beginning of decade
  decVec <- riversCentralAsia::decadeMaker('1936-01-01','2012-12-31','start') # full set of decades
  q <- dplyr::left_join(decVec,q,by='date') # gaps filles, no need to pad_by_time
  q_norm <- q %>% dplyr::group_by(dec) %>% dplyr::summarize(norm=mean(data,na.rm=TRUE)) # norms computed
  q <- dplyr::left_join(q,q_norm,by='dec') # now with norms
  q$units <- units
  q$type <- dataType
  q$code <- code %>% base::toString()
  q$station <- stationName
  q$river <- rName
  q$basin <- rBasin
  q$resolution <- base::factor(timeRes, levels = c("dec","mon"))
  q$lon_UTM42 <- x_UTM42N
  q$lat_UTM42 <- y_UTM42N
  q$altitude_masl <- masl
  q$basinSize_sqkm <- basin_size
  q <- q %>% dplyr::select(-dec)

  return(q)

}
