#' POSIXct date sequence generator
#'
#' Simple helper function that generates a simple sequence of POSIXct dates between a specified starting year and an ending year. The frequency can be specified. The date sequence starts at 00:00:00.
#'
#' @param startY Starting year for sequence of dates
#' @param endY Ending year for sequence of dates
#' @param freq "hour", "day", "week", "month", "quarter" or "year"
#' @return Tibble with date sequence with date frequency as specified. The date sequence starts at 00:00:00
#' @export
generateSeqDates <- function(startY,endY,freq,tz="UTC"){
  sTime <- base::paste0(startY,'-01-01 00:00:00')
  eTime <- base::paste0(endY,'-12-31 00:00:00')
  dateSeq <- base::seq(base::as.POSIXct(sTime,tz=tz), base::as.POSIXct(eTime,tz=tz), by=freq)
  dateSeq <- tibble::tibble(date=dateSeq)
  return(dateSeq)
}
