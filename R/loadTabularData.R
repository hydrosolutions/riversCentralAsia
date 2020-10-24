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
#' @param rName Name of river
#' @return A matrix of the infile
#' @export
loadTabularData <- function(fPath,fName,code,rName){
  Q_mat <- read_csv(strcat(fPath,fName), col_names = FALSE, col_types = cols())
  if (dim(Q_mat)[2] == 13){type = 'mon'} else {type = 'dec'}
  yS <- Q_mat$X1 %>% first()
  yE <- Q_mat$X1 %>% last()
  Q_mat <- Q_mat %>% dplyr::select(-X1)
  Q_norm <- Q_mat %>% dplyr::summarise_all(mean,na.rm=TRUE) %>% as.matrix() %>%
    unname() %>% t() %>% pracma::repmat(dim(Q_mat)[1],1) %>% as.vector
  Q <- Q_mat %>% t() %>% dplyr::as_tibble() %>% gather()
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
  dates$Q <- Q$value
  dates$Qnorm <- Q_norm
  dates$code <- code
  date$name <- rName
  Q <- dates
}
