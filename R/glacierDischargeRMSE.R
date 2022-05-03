#' Calculates glacier melt and the root mean squared error between observed
#' glacier melt and simulated glacier melt.
#'
#' @description This function calls ```glacierMelt_TI``` with ```parameters```
#'   and ```temperature``` and calculates the root mean squared error RMSE
#'   between the simulated and observed ```hugonnet``` glacier melt. The
#'   optional ```index``` serves to limit the results to one single glacier. \
#'   This function can be used to calibrate the parameters of the temperature
#'   index model. TODO write vignette demonstrating use.
#' @param parameters The two parameters of the function ```glacierMelt_TI```.
#'   The first parameter is the melt factor ```MF```, the second parameter is
#'   the threshold temperature ```threshold_temperature``` above which melt sets
#'   on. Example: c(4, 0).
#' @param temperature A tibble with the time steps in rows and temperature
#'   values for individual hydrological response units in columns. The names of
#'   the hydrological response units is typically of the form RGIId_layer,
#'   e.g. RGI60-13.10007_1. The RGIId and the underbar are required as the
#'   algorithm splits the name at the underbar and mergest the observed glacier
#'   melt by RGIId.
#' @param miles A tibble with the yearly glacier melt data by Miles et al.
#'   ```miles``` must contain the columns RGIID, totAbl and Area_m2. Further
#'   columns are ignored.
#' @param index (optional) number to indicate for which individual HRU the RMSE
#'   should be returned. Defaults to all.
#' @return RMSE between observed glacier melt and glacier melt simulated with
#'   the temperature index model of indexed hydrological response units.
#' @seealso \code{\link{glacierMelt_TI}}
# @export
#' @family glacier functions

glacierDischargeRMSE <- function(parameters, temperature, miles,
                                 index = 1:(dim(temperature)[2]-1)) {

  # Test validity of input
  if (length(parameters) != 2) {
    cat("Error: Function requires 2 parameters c(MF, threshold temperature).\n")
    return(NULL)
  }

  if (!("year" %in% colnames(temperature))) {
    cat("Error: Did not find column year in temperature.\n")
    return(NULL)
  }
  if (sum(stringr::str_detect(colnames(temperature), "_")) != dim(temperature)[2]-1) {
    cat("Error: Did not find _ in colnames of temperature.\n")
    cat("       The names of temperature should be of the form RGI60-13.14501_1.\n")
    return(NULL)
  }
  if (sum(stringr::str_detect(colnames(temperature), "RGI")) != dim(temperature)[2]-1) {
    cat("Error: Did not find RGI in colnames of temperature.\n")
    cat("       The names of temperature should be of the form RGI60-13.14501_1.\n")
    return(NULL)
  }

  if (!("RGIID" %in% colnames(miles))) {
    cat("Error: Did not find column RGIID in miles.\n")
    return(NULL)
  }
  if (!("totAbl" %in% colnames(miles))) {
    cat("Error: Did not find column totAbl in miles.\n")
    return(NULL)
  }

  if (length(index) == 1) {
    if (index > (dim(temperature)[2]-1)) {
      cat("Error: Index larger than temperature dimension.\n")
      return(NULL)
    }
  }


  # Calculate melt
  melt <- glacierMelt_TI(temperature = temperature |>
                           dplyr::select(-.data$year),
                         MF = as.numeric(parameters[1]),
                         threshold_temperature = as.numeric(parameters[2]))

  # reformat and compare to observed melt
  cal <- melt |>
    tibble::as_tibble() |>
    dplyr::mutate(year = temperature$year) |>
    tidyr::pivot_longer(-.data$year, names_to = "ID", values_to = "melt_mma") |>
    tidyr::separate(.data$ID, into = c("RGIId", "layer"), sep = "_") |>
    dplyr::group_by(RGIId, layer) |>
    dplyr::summarise(melt_mma = mean(melt_mma)) |>
    dplyr::ungroup() |>
    dplyr::left_join(miles |> dplyr::select(RGIID, totAbl, Area_m2),
                     by = c("RGIId" = "RGIID")) |>
    dplyr::mutate(totAbl = totAbl / Area_m2 * 10^3) |>  # to mm/a
    tidyr::drop_na() |>
    dplyr::group_by(RGIId) |>
    dplyr::summarise(rsme =sqrt(sum((.data$melt_mma - .data$totAbl)^2)))

  return(cal$rsme[index])
}
