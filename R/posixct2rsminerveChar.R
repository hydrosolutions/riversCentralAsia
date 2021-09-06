#' Function to convert POSIXCT-dates to a character representation as required
#' by RSminerve
#'
#' Reformats a POSIXct date formats to a string (vec) with the format
#' dd.mm.yyyy hh:mm:ss.
#' This is the format that RSMinerve accepts for time series.
#'
#' @param dateVec Date vector
#' @param tz Optional character indicating time zone for as.POSIXct. Default is
#'           system internal time zone (""). "GTM" or known local time zone of
#'           data recommended.
#' @return Dateframe with dates in dd.mm.yyyy hh:mm:ss representation
#' @export
posixct2rsminerveChar <- function(dateVec, tz = ""){
  da <- dateVec |> base::as.POSIXct(tz = tz)
  datesChar <- tibble::tibble(day = da |> lubridate::day(),
                              mon = da |> lubridate::month(),
                              year = da |> lubridate::year(),
                              hour = da |> lubridate::hour(),
                              min = da |> lubridate::minute(),
                              sec = da |> lubridate::second())
  # add trailing zeros
  datesChar$day <- datesChar$day |> numform::f_pad_zero(width = 2)
  datesChar$mon <- datesChar$mon |> numform::f_pad_zero(width = 2)
  datesChar$hour <- datesChar$hour |> numform::f_pad_zero(width = 2)
  datesChar$min <- datesChar$min |> numform::f_pad_zero(width = 2)
  datesChar$sec <- datesChar$sec |> numform::f_pad_zero(width = 2)
  # collate
  dmyCol <- base::do.call(sprintf, c(datesChar[1:3], '%s.%s.%s'))
  hmsCol <- base::do.call(sprintf, c(datesChar[4:6], '%s:%s:%s'))
  datesChar <- base::cbind(dmyCol,hmsCol) |> tibble::as_tibble()
  datesChar <- base::do.call(sprintf, c(datesChar[1:2], '%s %s')) |> tibble::as_tibble()
  base::return(datesChar)
}
