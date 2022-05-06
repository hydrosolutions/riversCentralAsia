#' Reading RSMinerve result file
#'
#' @param filepath String with path to file to be read.
#' @param tz Time zone to be passed to as_datetime. Defaults to "UTC".
#' @param chunk_size Numeric telling how many lines to read for each model component.
#' @return A tibble with time series of simulation results for all model components.
#' @details Use \code{\link{getChunkSize}} to retrieve the chunk size for the simulation resutls to read.
#' @examples
#' \dontrun{
#' filepath <- normalizePath(file.path("Tutorial01-results.dst"))
#' chunk_size <- getChunkSize(
#'   lubridate::as_datetime("02.09.2013 00:00:00",format = "%d.%m.%Y %H:%M:%S"),
#'   lubridate::as_datetime("09.09.2013 00:00:00", format = "%d.%m.%Y %H:%M:%S"),
#'   3600
#' )
#' result <- readResultDXT(filepath, chunk_size)
#' }
#' @family RS Minerve IO
#' @seealso \code{\link{getChunkSize}}
#' @export
readResultDST <- function(filepath, chunk_size, tz = "UTC") {

  if (base::file.exists(filepath)) {

    # Replace fileending
    filepath <- gsub("dsx", "dst", filepath)

    # Read the number of lines in the file
    nlines_tot <- R.utils::countLines(filepath)[1]
    no_chunks <- nlines_tot / chunk_size

    if (no_chunks != base::round(no_chunks)) {
      base::cat("Error reading lines from file.")
      return(NULL)
    }

    conn <- base::file(filepath, open = "r")
    output <- NULL

    for (i in c(1:no_chunks)) {
      cat("Reading chunk", i, "of", no_chunks, "\n")
      next_chunk <- base::readLines(conn, n = chunk_size)
      output <- base::rbind(output, parse_block(next_chunk))
    }

    base::close.connection(conn)

    return(output)

  } else {

    base::cat("Error: File", filepath, "not found.")
    return(NULL)

  }
}



#' Parse individual blocks of data from lines
#'
#' Internal function called by readResultDXT to read individual data chunks from
#' file.
#'
#' @param block_lines A bunch of lines read from an RSMinerve .dst simulation
#'   output file.
#' @param tz Time zone string to be passed to lubridate::as_datetime. Defaults
#'   to "UTC".
#' @return A tibble with the data from the block.
#' @importFrom rlang .data
#' @keywords internal
parse_block <- function(block_lines, tz = "UTC") {

  # Block name is just first line
  chars <- block_lines[1]
  name <- base::strsplit(chars, "\\|")[[1]][1]
  variable <- base::strsplit(chars, "\\|")[[1]][2]
  variable <- base::gsub("\\\\", ":", variable)

  # Split the array lines by spacing, then use them for a matrix
  mat_strings <- base::strsplit(block_lines[2:base::length(block_lines)], "\\t")

  output <- mat_strings |>
    purrr::transpose() |>
    tibble::as_tibble(.name_repair = "unique")
  base::colnames(output) <- base::c("Datetime", "Value")
  output_plus <- output |>
    tidyr::unnest(c(.data$Datetime, .data$Value)) |>
    dplyr::mutate(Datetime = lubridate::as_datetime(.data$Datetime,
                                                    format = "%d.%m.%Y %H:%M:%S",
                                                    tz = tz),
                  Value = base::as.numeric(.data$Value),
                  Object = name,
                  Variable = variable)

  return(output_plus)
}

