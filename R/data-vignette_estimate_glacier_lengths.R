#' Example data for vignette Estimateing glacier lengths in Central Asia
#'
#' @format A list of objects
#' \describe{
#'   \item{rgi6}{sf: A subset of the Randolph Glacier Inventory 6.0 in the Sokh river catchment.}
#'   \item{annual_precipitation_glaciers_sokh}{tibble: Annual precipitation sum averaged over the glaciers areas in the rgi6 dataset.}
#'   \item{average_temperature_glaciers_sokh}{tibble: Average annual temperature over the glaciers areas in the rgi6 dataset.}
#' }
#' @usage
#' data(vignette_estimate_glacier_lengths)
#' rgi6 <- vignette_estimate_glacier_lengths[[1]]
#' prec <- vignette_estimate_glacier_lengths[[2]]
#' temp <- vignette_estimate_glacier_lengths[[3]]
#' @source RGI6 data set, Karger et al., 2020, Beck et al., 2020
"vignette_estimate_glacier_lengths"



