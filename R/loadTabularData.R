#' Load Tabular Hydro-Meteorological Data
#'
#' Loads csv files with tabular hydrometeorological data where years are in rows
#' and decades or months are in columns. The function automatically detects if
#' monthly or decadal (10-day) data is provided. The function automatically computes
#' the long-term norm of the data provided and returns a time aware tibble with
#' date, data, data norm columns and code columns.
#'
#' @param fPath Path to the input file
#' @param fName File name
#' @param code Hydrometeorological station code
#' @param stationName Hydrometeorological station name/location
#' @param rName Name of river
#' @param rBasin Name of basin
#' @param dataType Type of data, either `Q`, `T` or `P`
#' @param units Data units
#' @return Time-aware tibble with relevant data
#' @export
loadTabularData <- function(fPath,fName,code,stationName,rName,rBasin,dataType,units){
  dataMat <- read_csv(strcat(fPath,fName), col_names = FALSE, col_types = cols())
  if (dim(dataMat)[2] == 13){type = 'mon'} else {type = 'dec'}
  yS <- dataMat$X1 %>% first()
  yE <- dataMat$X1 %>% last()
  dataMat <- dataMat %>% dplyr::select(-X1)
  norm <- dataMat %>% dplyr::summarise_all(mean,na.rm=TRUE) %>% as.matrix() %>%
    unname() %>% t() %>% pracma::repmat(dim(dataMat)[1],1) %>% as.vector
  data <- dataMat %>% t() %>% dplyr::as_tibble() %>% gather()
  s <- strcat(as.character(yS),"-01-01")
  e <- strcat(as.character(yE),"-12-31")
  if (type=='dec'){
    dates <- riversCentralAsia::decadeMaker(s,e,'end') %>% tk_tbl()
    dates <- dates %>% dplyr::select(-value)
    dates <- dplyr::rename(dates, date = index)
  } else {
    dates <- riversCentralAsia::monDateSeq(s,e,12) %>% tk_tbl(preserve_index = FALSE)
    dates <- dplyr::rename(dates, date = data)
  }
  dates$data <- data$value
  dates$norm <- norm
  dates$units <- units
  dates$type <- factor(dataType,levels = c("Q","P","T"))
  dates$code <- code
  dates$station <- stationName
  dates$river <- rName
  dates$basin <- rBasin
  dates$resolution <- factor(type,levels = c("dec","mon"))
  df <- dates %>% return()
}
