#' Calculates the hydrological year for a given date
#'
#' In Central Asia the hydrological year starts in October of the previous year.
#' @param date as_date or as.POSIXct
#' @return Hyear as numeric
#' @examples
#'
#' Hyear <- hyear(lubridate::as_date(c("2015-09-30", "2015-10-01", "2016-01-27")))
#'
#' @export
hyear <- function(date) {
  hyear <- ifelse(lubridate::month(date) >= 10,
                  lubridate::year(date) + 1,
                  lubridate::year(date))
  return(hyear)
}
