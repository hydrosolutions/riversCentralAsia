#' Estimates the total glacier ablation based on glacier mass loss rates.
#'
#' Regression derived from the data set by Hugonnet et al., 2021 (dmdtda) and
#' Miles et al., 2021 (totAbl).
#' @param dmdtda Glacier mass loss rates in meters of water equivalents per year
#'   (m/a).  \cr
#'   dhdt < 0: glacier is loosing mass, \cr
#'   dhdt > 0: glacier is gaining mass. \cr
#' @return Total glacier ablation in m3/a.
#'   Negative for glacier melt and positive for glacier gain.
#' @export
#' @family glacier functions

glacierTotalAblation_HM <- function(dmdtda) {

  intercept_growth = -393286.9
  factor_growth = 246308.7
  intercept_melt = -370143.4
  factor_melt = 753626.6

  Qgl <- ifelse(dmdtda > 0,
                # growth, less total ablation for large growth rates
                ifelse(dmdtda > 0.5, intercept_growth / 2,
                       intercept_growth + factor_growth * dhdt),
                # melt, higher total ablation for larger melt rates
                ifelse(dhdt < -1,
                       intercept_melt + factor_melt * (-2),
                       intercept_melt + factor_melt * dhdt)) * 10^6

  return(Qgl)

}
