#' Estimates the total glacier discharge based on glacier thinning rates
#'
#' Regression derived from the data set by Hugonnet et al., 2021 and Miles et
#' al., 2021.
#' @param dhdt Glacier thinning rates in meters per year (m/a).
#'   dhdt < 0: glacier is loosing mass,
#'   dhdt > 0: glacier is gaining mass.
#' @return Total glacier melt in m3/a.
#'   Negative for glacier melt and positive for glacier gain.
#' @export
#' @family glacier functions
#' @details Based on the residuals of the fits for growing and melting glaciers
#'   the following relative errors have been derived: 1.42% and 0.63%
#'   respectively. The average error of the glacier elevation change is 0.74%.
#'   See glacier vignette 02 for a demonstration on how to use that information.
glacierDischarge_HM <- function(dhdt) {

  intercept_growth = 0.2997969
  factor_growth = -0.1065329
  intercept_melt = 0.2881477
  factor_melt = -0.5707143

  Qgl <- ifelse(dhdt > 0,
                ifelse(dhdt > 1.8, intercept_growth / 2,
                       intercept_growth + factor_growth * dhdt),
                ifelse(dhdt < -2,
                       intercept_melt + factor_melt * (-2),
                       intercept_melt + factor_melt * dhdt)) * 10^6

  return(Qgl)

}
