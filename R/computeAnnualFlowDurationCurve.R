#' Computes the annual flow duration curve of a river discharge data set.
#'
#' @param data Tibble with date and discharge in columns.
#' @param column Name of the column with data to calculate duration curve from.
#' @param date Name of the date column
#' @return Input tibble with sorted data and duration stats in columns.
#' @examples
#' Qdf <- tibble::tibble(
#'   Date = seq.Date(from = lubridate::as_date("2020-01-01"),
#'                   to = lubridate::as_date("2022-12-13"),
#'                   by = "month"),
#'   Q = rep(c(1:6, 6:1), 3)
#' )
#' DurationCurve <- computeAnnualFlowDurationCurve(Qdf, "Q", "Date")
#' @export

computeAnnualFlowDurationCurve <- function(data, column, date = Date){

  if(!(column %in% colnames(data))) {
    cat("Error in columns of data:", column, "not found.\n")
  }
  if(!(date %in% colnames(data))) {
    cat("Error in columns of data:", date, "not found.\n")
  } else {
    data <- data |> dplyr::rename(Date = tidyselect::all_of(date))
  }
  if(!("Month" %in% colnames(data))) {
    data <- data |>
      dplyr::mutate(Month = lubridate::month(.data$Date))
  }
  if(!("Year" %in% colnames(data))) {
    data <- data |>
      dplyr::mutate(Year = lubridate::year(.data$Date))
  }

  output <- data |>
    dplyr::mutate(HYear = base::ifelse(.data$Month >= 10, .data$Year + 1, .data$Year),
                  yearday = lubridate::yday(.data$Date),
                  cutday = lubridate::yday(lubridate::as_date(base::paste0(
                    .data$Year, "-10-01"))),
                  ndaysperyear = base::as.numeric((lubridate::ceiling_date(
                    .data$Date, "year") - 1) -
                      lubridate::floor_date(.data$Date, "year")) + 1,
                  Hyearday = ifelse(.data$yearday >= .data$cutday,
                                    .data$yearday - .data$cutday + 1,
                                    .data$yearday + .data$ndaysperyear - .data$cutday)) |>
    dplyr::group_by(.data$HYear) |>
    dplyr::arrange(desc(.data[[column]]), .by_group = TRUE) |>
    dplyr::mutate(na = dplyr::n(),
                  Ma = dplyr::row_number(),
                  Pa = 100 * (.data$Ma / (.data$na + 1))) |>
    dplyr::ungroup() |>
    dplyr::select(-c(.data$cutday, .data$ndaysperyear))

  return(output)

}
