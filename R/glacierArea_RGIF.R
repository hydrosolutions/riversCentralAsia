#' Calculates glacier area based on glacier volume
#'
#' Scaling relationships derived from the RGI v6.0 region 13 data set, combined
#' with the glacier thickness derived by Farinotti et al. 2019.
#' @param volume_km3 glacier volume in km3
#' @return glacier area in km2
#' @export
#' @family glacier functions
#' @seealso \code{[glacierVolume_RGIF]}, \code{[glacierArea_Erasov]}
#' @details Assuming a normal distribution of the residuals, the relative
#'   uncertainty of the volume estimate is given as 2 times the standard
#'   deviation of the relative residuals which is equal to 53%. This method of
#'   error estimation likely underestimates the actual uncertainty.
#' @examples
#'   V_km3 <- c(0.1, 1, 10)
#'   A_km2 <- glacierArea_RGIF(V_km3)
#' @source RGI v6.0 <https://www.glims.org/RGI/>,
#'   Farinotti et al., 2019 <https://doi.org/10.1038/s41561-019-0300-3>
glacierArea_RGIF <- function(volume_km3) {
  # Inverse of glacierVolume_RGIF
  area_km2 <- ifelse(
    volume_km3 <=0,
    0,
    # Add the ifelse in log10 to avoid warning for when volume_km3 is 0.
    10^((log10(ifelse(volume_km3>0, volume_km3, 1)) - log10(0.03881778)) / 1.26151631)
  )
}
