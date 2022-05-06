#' Calculates glacier volume based on glacier area
#'
#' Scaling relationships derived from the RGI v6.0 region 13 data set, combined
#' with the glacier thickness derived by Farinotti et al. 2019.
#' @param area_km2 glacier area in km2
#' @return glacier volume in km3
#' @export
#' @family Glacier functions
#' @seealso \code{\link{glacierArea_RGIF}}, \code{\link{glacierVolume_Erasov}}
#' @details Assuming a normal distribution of the residuals, the relative
#'   uncertainty of the volume estimate is given as 2 times the standard
#'   deviation of the relative residuals which is equal to 31%.
#' @note The derivation of the empirical relationship as well as a comparison
#'   to the Erasov function is given in the book [Modelling of Hydrological Systems in Semi-Arid Central Asia](https://hydrosolutions.github.io/caham_book/glacier_modeling.html).
glacierVolume_RGIF <- function(area_km2) {
  volume_km3 = ifelse(area_km2 > 0,
                      0.03881778 * area_km2^1.26151631,
                      0)
}
