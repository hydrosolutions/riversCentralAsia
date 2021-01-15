#' Aggregates the sub-monthly data in a riversCentralAsia data set to monthly
#' data.
#'
#' A riversCentralAsia data set can be of type discharge, precipitation, and
#' temperature whereby temerature may be mean, minimum or maximum. The function
#' aggregate_data aggregates all sub-monthly data in the data tibble to monthly
#' data, according to the type-function pair given in the second argument.
#' The user specifies which aggregation function to use for each data type using
#' timetk's summarise_by_time.
#' To do this, aggregate_to_monthly
#'
#' @param data A tibble of the format \code{ChirchikRiverBasin}. Must contain at
#'             least the columns date, data, type and code.
#' @param funcTypeLib is a list of functions with associated data types that
#'             will be applied to the data. Currently, the aggregation functions
#'             \code{mean} and \code{sum} are supported. The user specifies the
#'             data types which are to be aggregated with either \code{mean} or
#'             \code{sum}. Both functions are implemented with the na.rm option
#'             set to TRUE.
#'
#' @return Returns a tibble of the same format as \code{data} with data
#'             aggregated to monthly time steps and "mon" in the resolution
#'             column.
#'             Returns 1 if aggregation fails.
#'
#' @examples
#' data <- ChirchikRiverBasin
#' funcTypeLib <- list(mean = c("Q", "T"), sum= "P")
#' data_mon <- aggregate_to_monthly(data, funcTypeLib)
#'
#' @author Beatrice Marti, hydrosolutions
#' @export

aggregate_to_monthly <- function(data, funcTypeLib) {

  # Make sure data contains the required columns in the required format.
  required_columns <- c("date", "data", "type", "code")
  required_classes <- c("date", "dbl", "fct", "chr")
  temp_error_code <- 0
  for (column in required_columns) {
    if (!(column %in% colnames(data))) {
      cat(paste0("Error: Did not find column ", column, "in data. \n",
                 "       See the documentation of the ChirchikRiverBasin \n",
                 "       data set for a more detailed description of data."))
      temp_error_code = 1
    } else {
      # If the column is available, test that the class is appropriate.
      if (!(data[1,column] %>% purrr::map_chr(pillar::type_sum) %in% required_classes)) {
        cat(paste0("Error: ", column, "in data does not have the required class. \n",
                   "       See the documentation of the ChirchikRiverBasin \n",
                   "       data set for a more detailed description of data."))
        temp_error_code = 1
      }
    }
  }
  if (temp_error_code == 1) return(temp_error_code)

  # Test if all data types are included in funcTypeLib and print a warning if
  # not.
  if (FALSE %in% (unique(data$type) %in% unlist(funcTypeLib))) {
    cat("Warning: Not all data types are declared in funcTypeLib.\nOnly part of your data will be aggregated.\n")
  }

  # Aggregation
  data_mon <- data %>%
    dplyr::group_by(.data$type, .data$code) %>%
    dplyr::filter(.data$type %in% unlist(funcTypeLib[1])) %>%
    timetk::summarise_by_time(.date_var = .data$date,
                              .by = "month",
                              data = mean(.data$data, na.rm = TRUE),
                              norm = mean(.data$norm, na.rm = TRUE)) %>%
    ungroup() %>%
    dplyr::add_row(data %>%
                     dplyr::group_by(.data$type, .data$code) %>%
                     dplyr::filter(.data$type %in% unlist(funcTypeLib[2])) %>%
                     timetk::summarise_by_time(.date_var = .data$date,
                                               .by = "month",
                                               data = sum(.data$data, na.rm = TRUE),
                                               norm = sum(.data$norm, na.rm = TRUE)) %>%
                     ungroup()) %>%
    dplyr::mutate(resolution = "mon") %>%
    tidyr::drop_na(data)

  # Add remaining columns from data.
  temp <- timetk::summarise_by_time(.data = (data %>%
                                               dplyr::select(-.data$data,
                                                             -.data$norm,
                                                             -.data$resolution) %>%
                                               dplyr::group_by(.data$type,
                                                               .data$code)),
                                    .date_var = date,
                                    .by = "month",
                                    across(everything(), first))
  data_mon <- dplyr::left_join(data_mon, temp, by = c("date", "type", "code"))

  return(data_mon)
}
