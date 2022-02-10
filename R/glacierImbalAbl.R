#' Estimates the imbalance ablation based on the total glacier discharge
#'
#' The regression is derived from the data set by Miles et al., 2021 (glacier
#' imbalance ablation imbalAbl) and Hugonnet et al, 2021 (specific glacier melt
#' dmdtda). In our modelling framework the glacier discharge is a positive
#' number while in Miles glacier balance model it is a negative number. Note
#' that imbalance ablation computed here is consistent with Miles glacier
#' balance model: negative imbalance ablation indicates glacier loss and
#' positive glacier imbalance ablation indicates glacier gain.
#' Contrary to the literature, where glacier growth can be observed, this
#' model does not allow for glacier growth.
#' @param Melt_mma Specific glacier melt in mm/a. A positive number
#' @return Imbalance ablation component of total ablation in m3/a.
#'   Negative for glacier melt and positive for glacier gain.
#' @export
#' @examples
#'   imbalAbl_m3a <- glacierImbalAbl(c(1,2,3,4,5)*10^3)
#' @family glacier functions
#' @details The relative error of the function is estimated to be 0.73%. See
#'   [vignette glaciers 02]{glaciers-o2-DDMWB.html} on a demonstration how
#'   to use that information.
#' @source Miles et al., 2021, DOI: <https://doi.org/10.1038/s41467-021-23073-4>
#'   and Hugonnet et al., 2021, DOI: <https://doi.org/10.1038/s41586-021-03436-z>
glacierImbalAbl <- function(Melt_mma) {

  imbalAbl = -864.8 * ifelse(Melt_mma >= 0, Melt_mma, NA)

}
