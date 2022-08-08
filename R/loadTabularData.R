#' Load Tabular Hydro-Meteorological Data
#'
#' Loads csv files with tabular hydrometeorological data where years are in rows
#' and decades or months are in columns. The function automatically detects if
#' monthly or decadal (10-day) data is provided. The function automatically computes
#' the long-term norm of the data provided and returns a time aware tibble with
#' date, data, data norm columns and code columns.
#'
#' @param fPath Path to the input file
#' @param fName File name (.csv file as input required)
#' @param code Hydrometeorological station code
#' @param stationName Hydrometeorological station name/location
#' @param rName Name of river
#' @param rBasin Name of basin
#' @param dataType Type of data, either `Q` (discharge data), `T` (temperature data) or `P` (precipitation data)
#' @param units Data units
#' @return Time-aware tibble with relevant data
#' @details Note that the input file needs to be in coma-separated format and
#'   without header. \n
#' \n
#' The most common format for hydrological data in Central Asia is in tabular form with the years in rows and the months or decades in columns, i.e. the data has 13 columns and as many rows as years of data. An input file containing monthly data might look like follows: \n
#'   1990,0.1,0.1,0.2,0.2,0.3,0.3,0.4,0.4,0.3,0.2,0.1,0.1 \n
#'   1991,0.1,0.1,0.2,0.2,0.3,0.3,0.4,0.4,0.3,0.2,0.1,0.1 \n
#'   1992,0.1,0.1,0.2,0.2,0.3,0.3,0.4,0.4,0.3,0.2,0.1,0.1 \n
#'   ... \n
#' An input file containing decadal data (every 10 days) would have 37 columns, the first for the year and the following for each decade in a year. \n
#' @family Pre-processing
#' @examples
#' \dontrun{
#' demo_data <- loadTabularData(
#'   fPath = "./",
#'   fName = "discharge.csv",
#'   code = "ABC",
#'   stationName = "DemoStation",
#'   rName = "Demo River",
#'   rBasin = "Demo Basin",
#'   dataType = "Q",
#'   unit = "m3/s")
#' }
#' @export
loadTabularData <- function(fPath,fName,code,stationName,rName,rBasin,dataType,units){

  dataMat <- readr::read_csv(paste(fPath,fName,sep=""), col_names = FALSE,
                             col_types = readr::cols())

  if (dim(dataMat)[2] == 13){
    type = 'mon'
  } else if(dim(dataMat)[2] == 37) {
    type = 'dec'
  } else {
    cat("ERROR please verify that input file has number of columns 13 for monthly data or 37 for decadal data.")
    return(NULL)
  }

  yS <- dataMat$X1 %>% dplyr::first()
  yE <- dataMat$X1 %>% dplyr::last()
  dataMat <- dataMat %>% dplyr::select(-X1)
  norm <- dataMat %>% dplyr::summarise_all(mean,na.rm=TRUE) %>% as.numeric() %>%
    kronecker(matrix(1,1,dim(dataMat)[1])) %>% as.numeric()
  data <- dataMat %>% t() %>% dplyr::as_tibble(.name_repair = "unique") %>% tidyr::gather()
  s <- paste(as.character(yS),"-01-01",sep="")
  e <- paste(as.character(yE),"-12-31",sep="")
  if (type=='dec'){
    dates <- riversCentralAsia::decadeMaker(s,e,'end') #%>% tk_tbl()
    dates <- dates %>% dplyr::select(-dec)
  } else {
    dates <- riversCentralAsia::monDateSeq(s,e,12) %>% timetk::tk_tbl(preserve_index = FALSE)
    dates <- dplyr::rename(dates, date = data)
  }

  dates$data <- data$value
  dates$norm <- norm
  dates$units <- units
  #dates$type <- factor(dataType, levels = c("Q","P","T")) # Removed since we can have different type of temperature
  # time series, i.e. monthly abs. minimum, monthly mean minimum, etc.
  dates$type <- dataType
  dates$code <- code %>% base::toString()
  dates$station <- stationName
  dates$river <- rName
  dates$basin <- rBasin
  dates$resolution <- base::factor(type, levels = c("dec","mon"))
  df <- dates %>% return()
}
