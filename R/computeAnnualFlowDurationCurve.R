#' Computes the annual flow duration curve of a river discharge data set.
#'
#' @param data Tibble with date and discharge in columns.
#' @param column Name of the column with data to calculate duration curve from.
#' @param date Name of the date column
#' @return Input tibble with sorted data and duration stats in columns, namely  \cr
#'   Q: Discharge in descending order  \cr
#'   Ma: A day counter between 1 and 365/366  \cr
#'   Pa: Exceedance probability in percent
#' @note If the input data tibble is grouped, the duration stats will be computed
#'   within each group.
#' @family Post-processing
#' @examples
#' # Monthly flow duration curve
#' Qdf <- tibble::tibble(
#'   Date = seq.Date(from = lubridate::as_date("2020-01-01"),
#'                   to = lubridate::as_date("2022-12-13"),
#'                   by = "month"),
#'   Q = rep(c(1:6, 6:1), 3)
#' )
#' DurationCurve <- computeAnnualFlowDurationCurve(Qdf, "Q", "Date")
#' plot(DurationCurve$Ma, DurationCurve$Q)
#'
#' # Daily flow duration curve
#' Date = seq.Date(from = lubridate::as_date("2019-10-01"),
#'                 to = lubridate::as_date("2040-09-30"), by = "day")
#' Qdfdaily <- tibble::tibble(Date = Date,
#'   Q = sin(2*pi/365*c(1:length(Date))) * stats::runif(length(Date)) +
#'     cos(2*pi/365*c(1:length(Date))) * runif(length(Date)) +
#'     runif(length(Date))*2)
#' DurationCurve <- computeAnnualFlowDurationCurve(Qdfdaily, "Q", "Date")
#' @export

computeAnnualFlowDurationCurve <- function(data, column, date = "Date"){

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
      dplyr::mutate(Month = lubridate::month(Date))
  }
  if(!("Year" %in% colnames(data))) {
    data <- data |>
      dplyr::mutate(Year = lubridate::year(Date))
  }

  output <- data |>
    dplyr::mutate(yearday = lubridate::yday(Date)) |>
    dplyr::group_by(Year, .add = TRUE) |>
    dplyr::arrange(dplyr::desc(.data[[column]]), .by_group = TRUE) |>
    dplyr::mutate(na = dplyr::n(),
                  Ma = dplyr::row_number(),
                  Pa = 100 * (Ma / (na + 1))) |>
    dplyr::ungroup()

  return(output)

}
