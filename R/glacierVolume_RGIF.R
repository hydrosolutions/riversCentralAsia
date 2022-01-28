#' Calculates glacier volume based on glacier area
#'
#' Scaling relationships derived from the RGI v6.0 region 13 data set, combined
#' with the glacier thickness derived by Farinotti et al. 2019.
#' @param area_km2 glacier area in km2
#' @return glacier volume in km3
#' @export
#' @family glacier functions
#' @seealso \code{\link{glacierArea_RGIF}}, \code{\link{glacierVolume_Erasov}}
glacierVolume_RGIF <- function(area_km2) {
  volume_km3 = ifelse(area_km2 > 0,
                      0.0606097 * area_km2^1.1424380,
                      0)
}
