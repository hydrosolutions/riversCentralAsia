#' Writes a chk file containing the variables selected for printing
#'
#' RSMinerve writes result files or performs plots for a selection of variables.
#' This selection can be stored in and loaded to RSMInerve from a chk file. The
#' function \code{writeSelectionCHK} writes such a file from a tibble.
#'
#' @details The chk file is structured as shown in the following example:  \cr
#'   <?xml version="1.0" encoding="utf-8"?>   \cr
#'   <Selection>   \cr
#'     <Name>New selection</Name>  \cr
#'     <Path>Model Koksu\\Source QSpring\\Kichkinesay - QUp (m3/s)</Path>  \cr
#'     <Path>Model Koksu\\Comparator Comparator 1\\QReference (m3/s)</Path>  \cr
#'     <Path>Model Koksu\\Comparator Comparator 1\\QSimulation (m3/s)</Path>  \cr
#'     ...  \cr
#'   The content of the Path parts is parsed from a tibble with columns Model,
#'   Object, ID and Variable. The input tibble of the example above would be: \cr
#'      A tibble: 94 x 3  \cr
#'      Model       Object                     Variable    \cr
#'      <chr>       <chr>                      <chr>             \cr
#'      Model Koksu Source QSpring             Kichkinesay - QUp (m3/s)  \cr
#'      Model Koksu Comparator Comparator 1    QReference (m3/s)     \cr
#'      Model Koksu Comparator Comparator 1    QSimulation (m3/s)    \cr
#'      ...         ...                        ...  \cr
#' @param filepath Path to file to be written.
#' @param data Tibble or data frame with description of variables to be written.
#' @param name A character string for the name of the selection.
#' @return NULL if successful.
#' @examples
#' \dontrun{
#' filepath <- normalizePath(file.path("test_writeSelectionCHK.chk"))
#' Object_IDs <- c("SOCONT 1", "SOCONT 2", "SOCONT 3")
#' data <- tibble::tibble(
#'   Model = rep("Tutorial_Model", length(Object_IDs)),
#'   Object = rep("SOCONT", length(Object_IDs)),
#'   ID = Object_IDs,
#'   Variable = rep("Qtot (m3/s)")
#' )
#' name <- "SOCONT Qtot"
#' writeSelectionCHK(filepath, data, name)
#' }
#' @family RS Minerve IO
#' @export
writeSelectionCHK <- function(filepath, data, name) {

  d <- xml2::xml_new_root(.version = "1.0", .encoding = "utf-8",
                          .value = "Selection")

  xml2::xml_add_child(d, .value = "Name", name)

  for (i in c(1:dim(data)[1])) {
    path <- paste0(data$Model[i], "\\", data$Object[i], " ", data$ID[i], "\\",
                   data$Variable[i])
    xml2::xml_add_child(d, .value = "Path", path)
  }

  xml2::write_xml(d, filepath)

}
