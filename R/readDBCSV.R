#' Reads a RSMinerve data base csv into a tibble.
#'
#' The data is in a csv file that exported from the RS Minerve data base tab.
#'
#' @param filename Path to file with the db data from RS Minerve.
#' @param tz Optional time zone string, passed to lubridate::as_datetime (for
#'         details refer to POSIXt documentation). Defauls to "UTC"
#' @return Returns a tibble of the same format as \code{data} with data
#'         in hourly (climate) to decadal or monthly (discharge) time steps.
#'         Includes all attributes of the csv file
#' @note An example forcing csv file is given under \url{http://raw.githubusercontent.com/hydrosolutions/RSMinerveR/main/tests/testthat/test_translateCSVtoDST.csv}.
#'   A related, older function is \code{load_minerve_input_csv} is being
#'   discontinued.
#' @family RS Minerve IO
#' @seealso \code{[load_minerve_input_csv]}
#' @export

readDBCSV <- function(filename, tz = "UTC") {

  # Read Metadata from file, write column headers and determine column types.
  header <- readr::read_delim(filename, col_names = FALSE, skip = 0, n_max = 7,
                              delim = ";", show_col_types = FALSE)
  if (dim(header)[2] == 1) {
    header <- readr::read_delim(filename, col_names = FALSE, skip = 0, n_max = 7,
                                delim = ",", show_col_types = FALSE)
  }
  colnames(header) <- paste(header[1, ], header[2, ], header[3, ], header[4, ],
                            header[5, ], header[6, ], header[7, ], sep = "#")
  colnames(header)[1] <- "Date"
  Nsb <- dim(header)[2] - 1  # Number of sub-basins in data table
  coltypes <- paste("c", strrep("n", times = Nsb), sep = "")

  data <- readr::read_delim(filename, col_names = colnames(header), skip = 8,
                          col_types = coltypes, delim = ";",
                          show_col_types = FALSE)
  if (dim(data)[2] == 1) {
    data <- readr::read_delim(filename, col_names = colnames(header), skip = 8,
                              col_types = coltypes, delim = ",",
                              show_col_types = FALSE)
  }

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

  # Reformat data table and drop superfluous rows
  data_long <- tidyr::pivot_longer(data, -Date,
                                   names_to = c("Station", "X", "Y", "Z", "Sensor",
                                                "Category", "Unit"),
                                   names_sep = "\\#", values_to = "Value",
                                   values_drop_na = TRUE)

  if (stringr::str_detect(data_long$Station[1], "\\|")) {
    data_long <- data_long |>
      tidyr::separate(Station, into = c("Name", "Type"), sep = "\\|",
                      remove = FALSE)
  }

  return(data_long)

}
