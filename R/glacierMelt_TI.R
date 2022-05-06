#' Glacier melt computed with a temperature index model
#'
#' @description Glacier melt (\code{M}) is produced by multiplying the melt factor
#'   (\code{MF}) with the amount of energy available for melting which is
#'   approximated with the difference between the measured temperature (\code{T})
#'   and a threshold temperature above which melt occurs (\code{Tth}). \cr
#'   The formula is given as: \cr
#'   \code{M = MF * (T - Tth) if T is above Tth}. \cr
#'   No melt occurs at temperatures below the threshold temperature.
#' @source Hock R. (2003): Temperature index melt modelling in mountain areas.
#'   Journal of Hydrology 282, pp 104--115, DOI: 10.1016/S0022-1694(03)00257-9.
#' @param temperature A matrix with daily temperatures over time (rows) for each
#'   glacier and/or elevation band (columns).
#' @param MF is a scalar or a named vector with temperature index factors which
#'   contains one melt factor for each glacier/elevation band in the
#'   temperature matrix.
#' @param threshold_temperature is a scalar or a named vector with the
#'   temperature above which glacier melt is produced.
#' @return A matrix with melt rates in mm per glacier/elevation band.
#' @examples
#' # Generate random temperature forcing
#' number_of_glaciers <- 10
#' number_of_days <- 50*365
#' temperature <- matrix(
#'   runif(number_of_glaciers * number_of_days, min = -10, max = 10),
#'   nrow = number_of_days, ncol = number_of_glaciers)
#' colnames(temperature) <- paste0("Gl", 1:number_of_glaciers)
#' # Generate sample melt factors
#' MF <- temperature[1, ] * 0 + 1:number_of_glaciers
#' # Calculate glacier melt assuming a threshold temperature for glacier melt of
#' # 1 degree Celcius.
#' melt <- glacierMelt_TI(temperature, MF, threshold_temperature = 1)
#' @export
#' @references Hock R., 2003. DOI: 10.1016/S0022-1694(03)00257-9.
#' @family Glacier functions

glacierMelt_TI <- function(temperature, MF = 4, threshold_temperature = 0) {

  # If MF is a scalar, attribute MF to all glaciers/elevation bands in
  # temperature.
  if (length(MF) == 1) {
    MF <- temperature[1, ]*0 + MF
  }

  # Check for consistency of the input
  if (sum(names(MF) %in% colnames(temperature)) !=
      length(colnames(temperature))) {
    if (sum(colnames(MF) %in% colnames(temperature)) !=
        length(colnames(temperature))) {
      cat("Error: names(MF) not consistent with IDs in temperature. \n")
      return(NULL)
    }
  }
  MFmat <- matrix(as.matrix(MF), nrow = dim(temperature)[1],
                   ncol = length(MF), byrow = TRUE)
  colnames(MFmat) <- colnames(temperature)

  # Do the same for the temperature threshold
  if (length(threshold_temperature) == 1) {
    threshold_temperature <- temperature[1, ] * 0 + threshold_temperature
  }
  if (sum(names(threshold_temperature) %in% colnames(temperature)) != length(colnames(temperature))) {
    if (sum(colnames(threshold_temperature) %in% colnames(temperature)) != length(colnames(temperature))) {
      cat("Error: names(threshold_temperature) not consistent with IDs in temperature. \n")
      return(NULL)
    }
  }
  Tmat <- matrix(as.matrix(threshold_temperature), nrow = dim(temperature)[1],
                 ncol = length(threshold_temperature), byrow = TRUE)
  colnames(Tmat) <- colnames(temperature)

  # Calculate glacier melt
  temperature_plus <- temperature - Tmat
  temperature_plus[temperature_plus < 0] <- 0
  melt <- temperature_plus * MFmat

  return(melt)
}
