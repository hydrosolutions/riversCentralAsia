#' Calculates glacier area from glacier volume
#'
#' Inverse of Erasov glacier scaling function. Only works for positive glacier
#' volume.
#' @param volume_km3 Glacier volume in km3
#' @return Glacier area in km2
#' @export
#' @family Glacier functions
#' @seealso \code{\link{glacierVolume_Erasov}}, \code{\link{glacierArea_RGIF}}
glacierArea_Erasov <- function(volume_km3) {
  area_km2 <- ifelse(
    volume_km3 <=0,
    0,
    # Add the ifelse in log10 to avoid warning for when volume_km3 is 0.
    10^((log10(ifelse(volume_km3>0, volume_km3, 1)) - log10(0.027)) / 1.5)
  )
}
