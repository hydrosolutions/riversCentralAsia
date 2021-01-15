#' Discharge, precipitation and temperature in the Chirchiq river basin,
#' Uzbekistan.
#'
#' A data set containing the 10-day (decadal) or monthly data for discharge,
#' precipitation and temperature in the Chirchiq river basin, Uzbekistan.
#'
#' @format A data frame with 29892 rows and 14 variables:
#' \describe{
#'   \item{date}{\code{Date} Date in decadal or monthly time steps.}
#'   \item{data}{\code{num} Value of variable.}
#'   \item{norm}{\code{num} Multi-year average of values.}
#'   \item{units}{\code{chr} Unit of values. Can be cubic meters per second
#'                (m3s) for discharge, milli meters (mm) for precipitation or
#'                degrees Celsius (degC) for temperature.}
#'  \item{type}{\code{chr} A character identifying the variable type. Possible
#'              values are "Q" for discharge, "P" for precipitation and "T" for
#'              Temperature.}
#'  \item{code}{\code{chr} Unique station identifier issued by Uzbek HydroMet.}
#'  \item{station}{\code{chr} Station name.}
#'  \item{river}{\code{chr} Name of river the station is related to.}
#'  \item{basin}{\code{chr} The name of the basin the station is part of.}
#'  \item{resolution}{\code{chr} Temporal resolution of the data. Can be `dec`
#'                    for data in 10-day (decadal) intervals or `mon` for
#'                    data in monthly intervals.}
#'   \item{lon_UTM42}{num: Longitude of station in UTM42.}
#'   \item{lat_UTM42}{num: Latitude of station in UTM42.}
#'   \item{altitude_masl}{num: Altitude of station in meter above mean sea level.}
#'   \item{basinSize_sqkm}{num: Size of the basin in square kilometers (km2).}
#' }
#' @source Uzbek HydroMet 20xx, contact.
"ChirchikRiverBasin"
