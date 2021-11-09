#' Estimates glacier surface area and glacier volume.
#'
#' ErazovsGlacierFunction implements the empirical relationship between glacier
#' area and volume. It can be used to estimate regional glacier volumes in
#' Central Asia.
#'
#' @param glaciers A data.frame, tibble, or sf object. Must contain an attribute
#'   "Area" in kilometers squared (as in the Randolph Glacier Inventory (RGI 6.0)).
#' @return Returns the input object with Volume_Erazov_km3 added. Will return
#'   NULL if the length column in the input object is not found.
#' @references Erazov, N. V. (1968). Method for determining of volume of mountain glaciers. MGI 14, pp 307-308.
#' @examples
#' glacier <- dplyr::tibble(Year = c(2000:2010),
#'                          Area = c(0.57, 0.56, 0.55, 0.55, 0.54, 0.53, 0.53,
#'                                   0.52, 0.051, 0.05, 0.048))
#' ErazovsGlacierFunction(glacier)
#' @export
ErazovsGlacierFunction <- function(glaciers) {

  if (!("Area" %in% names(glaciers))) {
    cat("Error. Did not find Area in input. Need to provide the area of each glaciers in [km2] in a column called Area (as provided in RGIv6.0).")
    return(NULL)
  }

  output <- glaciers |>
    dplyr::mutate(Volume_Erazov_km3 = 0.027 * .data$Area^1.5)

  return(output)
}

