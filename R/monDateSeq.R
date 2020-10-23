#' Create a monthly sequence date vector with end of month day dates
#'
#' This function creates a sequence of monthly dates between a start and an end
#' date. It requires the specification of the start and end dates and the frequency.
#' If a continuous sequence is requested, then freq should be 12.
#'
#' @param st start date
#' @param en end date
#' @param freq frequence of dates (12 for continuous monthly dates)
#' @return A sequence of dates
#' @export
monDateSeq <- function(st, en, freq) {
  st <- as.Date(as.yearmon(st))
  en <- as.Date(as.yearmon(en))
  as.Date(as.yearmon(seq(st, en, by = paste(as.character(12/freq), "months"))), frac = 1)
}
