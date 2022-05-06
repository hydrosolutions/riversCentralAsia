#' Reads climate and discharge data from a character string into a tibble.
#'
#' The data is in a string in the same format as the RSMinerve forcing csv
#' that can also be imported to RS Minerve to form a database. This function is
#' useful for reformatting data in character format that is to be written to
#' RS Minerve input files.
#'
#' @param string Character string with input data for RS Minerve.
#' @param tz Time zone character to be passed to lubridate::as_datetime.
#'         Defaults to "UTC"
#' @return Returns a tibble of the same format as \code{data} with data
#'         in hourly (climate) to decadal or monthly (discharge) time steps.
#'         Includes all attributes of the csv file.
#' @family RS Minerve IO
#' @export

readForcingSTR <- function(string, tz = "UTC") {

  # Read Metadata from file, write column headers and determine column types.
  header <- string[1:7, ]
  colnames(header) <- paste(header[1, ], header[2, ], header[3, ], header[4, ],
                            header[5, ], header[6, ], header[7, ], sep = "-")
  colnames(header)[1] <- "Date"
  Nsb <- dim(header)[2] - 1  # Number of sub-basins in data table
  coltypes <- paste("c", strrep("n", times = Nsb), sep = "")

  data <- string[-c(1:8), ]
  colnames(data) <- colnames(header)
  date_vec <- lubridate::as_datetime(data$Date, format = "%d.%m.%Y %H:%M:%S",
                                     tz = tz)
  if (is.na(date_vec[1])) {
    date_vec <- lubridate::as_datetime(data$Date, format = "%d.%m.%y %H:%M",
                                       tz = tz)
  }
  if (is.na(date_vec[1])) {
    date_vec <- lubridate::as_datetime(data$Date, format = "%Y-%m.%d %H:%M:%S",
                                       tz = tz)
  }
  data$Date <- date_vec

  data <- data |>
    dplyr::mutate(dplyr::across(where(base::is.character),
                                base::as.numeric))
  # Reformat data table and drop superfluous rows
  data_long <- tidyr::pivot_longer(data, -.data$Date,
                                   names_to = c("Station", "X", "Y", "Z", "Sensor",
                                                "Category", "Unit"),
                                   names_sep = "\\-", values_to = "Value",
                                   values_drop_na = TRUE)

  return(data_long)

}
