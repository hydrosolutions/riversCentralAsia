#' Creates a vector of decadal (10 days) dates
#'
#' This function creates a decadal 10-days dates vector that allows date tagging
#' for decadal (10-days) time series. This type of timeseries is usually used for
#' hydro-meteorological data in the former Soviet Republics. The intra-months decades
#' can be configured as dates at the beginning or end of the decade.
#'
#' @param s starting date in YYYY-mm-dd format
#' @param e end date in YYYY-mm-dd format
#' @param type 'start' creates starting decade dates, 'end' creates ending decade dates.
#' @return A sequence of decadal dates
#' @export
decadeMaker <- function(s,e,type){
  s_year <- s %>% zoo::as.Date() %>% lubridate::year() %>% zoo::yearmon() %>% zoo::as.Date()
  decade <- 1 : 36 # Preparation of decade indicators
  ydiff <- as.Date(e) %>% lubridate::year() - as.Date(s) %>% lubridate::year() + 1
  decade <- rep(decade, times = ydiff) # this replicates decades for exactly the number of years
  temp <- zoo::zooreg(decade, frequency = 36, start=zoo::as.yearmon(s_year))
  eom <- seq.Date(zoo::as.Date(s_year),by='month',length.out = ydiff * 12) %>%
    zoo::as.yearmon() %>% zoo::as.Date(,frac=1) %>% format('%d') %>% as.numeric
  if (all(type=='end')){
    daysV <- cbind(10,20,eom) %>% t %>% as.vector()
  } else if (all(type=='start')){
    daysV <- cbind(1,11,21) %>% t %>% as.vector()
  }
  temp.Date <- zoo::as.Date(stats::time(temp)) + daysV - 1
  decade <- zoo::zoo(decade, temp.Date) %>%
    timetk::tk_tbl() %>%
    dplyr::rename(date=index,dec=value) %>%
    dplyr::filter(date<=e & date>=s)
}
