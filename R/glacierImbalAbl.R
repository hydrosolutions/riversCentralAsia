#' Estimates the imbalance ablation based on the total glacier discharge
#'
#' Regression derived from the data set by Miles et al., 2021. In our modelling
#' framework the glacier discharge is a positive number while in Miles glacier
#' balance model it is a negative number. Note that imbalance ablation computed
#' here is consistent with Miles glacier balance model: negative imbalance
#' ablation indicates glacier loss and positive glacier imbalance ablation
#' indicates glacier gain.
#' @param totAbl_m3a total glacier ablation (eq. glacier melt) in m3/a. A positive
#'   number
#' @return Imbalance ablation component of total ablation in m3/a.
#'   Negative for glacier melt and positive for glacier gain.
#' @export
#' @examples
#' imbalAbl_m3a <- glacierImbalAbl(c(1,2,3,4,5)*10^6)
#' @family glacier functions
#' @details The relative error of the function is estimated to be 1.27%. See
#'   vignette glaciers 02 on a demonstration how to use that information.
glacierImbalAbl <- function(totAbl_m3a) {

  a = 1281.734
  b = 699955.430
  c = -1309221.561

  imbalAbl_m3a <- ifelse(totAbl_m3a > 0,
                         ifelse(totAbl_m3a > 1.3*10^6,
                                (((-1*1.3*10^6) - c)/a)^2 - b,
                                (((-1*totAbl_m3a) - c)/a)^2 - b),
                         0)

  return(imbalAbl_m3a)

}
