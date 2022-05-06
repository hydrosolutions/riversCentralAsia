#' Reads a chk file containing the variables selected for printing
#'
#' RSMinerve writes result files or performs plots for a selection of variables.
#' This selection can be stored in and loaded to RSMInerve from a chk file. The
#' function \code{readSelectionCHK} reads such a file to a tibble.
#'
#' @details The chk file is structured as shown in the following example:  \cr
#'   <?xml version="1.0" encoding="utf-8"?>   \cr
#'   <Selection>   \cr
#'     <Name>New selection</Name>  \cr
#'     <Path>Model Koksu\\Source QSpring\\Kichkinesay - QUp (m3/s)</Path>  \cr
#'     <Path>Model Koksu\\Comparator Comparator 1\\QReference (m3/s)</Path>  \cr
#'     <Path>Model Koksu\\Comparator Comparator 1\\QSimulation (m3/s)</Path>  \cr
#'     ...  \cr
#'   The content of the Path parts is parsed to a tibble with columns Model,
#'   Object, ID and Variable. The output tibble of the example above would be: \cr
#'      A tibble: 94 x 3  \cr
#'      Model       Object                     Variable    \cr
#'      <chr>       <chr>                      <chr>             \cr
#'      Model Koksu Source QSpring             Kichkinesay - QUp (m3/s)  \cr
#'      Model Koksu Comparator Comparator 1    QReference (m3/s)     \cr
#'      Model Koksu Comparator Comparator 1    QSimulation (m3/s)    \cr
#'      ...         ...                        ...  \cr
#' @param filepath Path to file to be read.
#' @return A list with the name of the selection and the content of the Paths
#'   in the chk file as a tibble.
#' @examples
#' \dontrun{
#' filepath <- normalizePath(file.path("test_selection.chk"))
#' selection_list <- readSelectionCHK(filepath)
#' selection_name <- selection_list[[1]]
#' selection_data <- selection_list[[2]]
#' }
#' @family RS Minerve IO
#' @export
readSelectionCHK <- function(filepath) {

  if (file.exists(filepath)) {

    # Read the file at filepath to an xml document
    raw <- xml2::read_xml(filepath, as_html = FALSE)

    # Extract name of selection
    name <- xml2::xml_text(xml2::xml_find_first(raw, "//Name"))

    # Extract selection
    selection_list <- xml2::xml_text(xml2::xml_find_all(raw, "//Path"))

    selection <- tibble::as_tibble(
      base::t(
        base::as.data.frame(
          base::lapply(selection_list, function(x) {
            temp <- base::strsplit(x, split = "\\\\")[[1]]
            return(temp)
            }),
          row.names = c("Model", "Object", "Variable"))
        ),
      .name_repair = "unique")
    selection <- selection |>
      tidyr::separate(col = "Object", into = c("Object", "ID"), sep = " ",
                      remove = TRUE, extra = "merge")

    return(list(name, selection))

  } else {

    cat("Error, cannot find", filepath)
    return(NULL)

  }

}
