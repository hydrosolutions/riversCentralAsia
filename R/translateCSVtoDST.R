#' Translate csv to dst
#'
#' !UNDER DEVELOPMENT! This function is meant to translate forcing data for
#' RSMinerve in the csv format to dst which can be loaded when scripting
#' RSMinerve. The dst output file is written to the same location as the input
#' file.
#'
#' @param csvfilepath string path to csv file to be read.
#' @param tz Time zone string to be passed to base::format. Defaults to "UTC".
#' @return NULL for success and 1 for failure.
#' @details When scripting RSMinerve, climate forcing is read from dst files and
#'   not from csv files as are used when RSMinerve is run from the user
#'   interface. The csv files can be transformed to dst files using this
#'   function.
#' @family RS Minerve IO
#' @export
translateCSVtoDST <- function(csvfilepath, tz = "UTC") {
  if (base::file.exists(csvfilepath)) {

    # Read data
    data <- readForcingCSV(csvfilepath)

    # Reformat data to dst
    data_w <- data |>
      dplyr::select(.data$Date, .data$Station, .data$Sensor, .data$Value) |>
      tidyr::pivot_wider(id_cols = .data$Date,
                         names_from = c(.data$Station, .data$Sensor),
                         names_sep = "\\", values_from = .data$Value)

    # Write data to dst file
    outfilepath <- base::gsub("csv", "dst", csvfilepath)
    conn <- base::file(outfilepath, open = "w")

    N <- base::dim(data_w)[2]
    L <- base::dim(data_w)[1]

    for (i in c(2:N)) {

      base::writeLines(base::colnames(data_w)[i], conn, sep = "\n")

      for (j in c(1:L)) {
        base::writeLines(base::paste(base::format(data_w$Date[1],
                                                  "%d.%m.%Y %H:%M:%S",
                                                  tz = tz),
                         data_w[j, i], sep = "\t"),
                   conn, sep = "\n")
      }

    }

    base::close.connection(conn)

    return(NULL)

  } else {

    cat("Error in translateCSVtoDST: File", csvfilepath, "not found. ")
    return(1)

  }
}
