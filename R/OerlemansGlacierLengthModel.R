#' Calculates glacier length following Oerleman 2005.
#'
#' The function is used to calculate the length of glaciers over time given an initial length and climate forcing (mean annual temperature and annual precipitation). This is an annual model.
#'
#' @param annual_temperature_annomaly A tibble with dimensions [Number of years x number of glaciers in rgi_data_set] with "years" (int) in the first column and the annual temperature annomaly per glacier in the other columns. The model assumes that the glacier columns start with "V".
#' @param annual_precipitation A tibble analogue to annual_temperature_annomaly but for absolute annual precipitation sums in meters.
#' @param years_baseline_period The number of years at the beginning of the dataset which were used to calculate the average temperature baseline. They are substracted from the glacier length analysis. If the tibbles do not include the baseline years, set years_baseline_period to 0.
#' @param rgi_data_set An sf object, a data frame or a tibble, for example a subset of the Randolph Glacier Inventory 6.0 in the area of interest. Must contain a glacier length attribute (Lmax) and a glacier slope attribute (Slope).
#' @return A list with dLt and Lt. dLt is a tibble with dimensions [Number of years - years baseline period x number of glaciers in the rgi data set]. It contains the change of glacier length in km. Lt is a tibble of the same dimensions as dLt containing absolute glacier lengths over time in km.
#' @note This function is suitable if you have the climate data in a wide table format with the forcing per glacier in columns. If you have the climate data in a long table format use \code{\link{OerlemansGlacierLengthModel_FormatLong}} instead.
#' @references Oerlemans (2005) Extracting a Climate Signal from 169 Glacier Records. Science. DOI: 10.1126/science.1107046.
#' @examples
#'   glaciers <- dplyr::tibble(ID = c(1, 2, 3),
#'                             Lmax = c(500, 5000, 13000),
#'                            Slope = c(30, 16, 20))
#'   temperature_annomaly <- dplyr::tibble(Year = c(2000:2010),
#'                                         V1 = seq(0, 5,  0.5),
#'                                         V2 = seq(0, 2,  0.2),
#'                                         V3 = seq(0, 2,  0.2))
#'   precipitation <- dplyr::tibble(Year = c(2000:2010),
#'                                  V1 = seq(0.7, 0.705,  0.0005),
#'                                  V2 = seq(0.7, 0.5,  -0.02),
#'                                  V3 = seq(1.500, 1.505,  0.0005))
#'   test_data <- OerlemansGlacierLengthModel(temperature_annomaly, precipitation, 0, glaciers)
#'   dL <- test_data[[1]]
#'   L <- test_data[[2]]
#' @export
OerlemansGlacierLengthModel <- function(annual_temperature_annomaly,
                                     annual_precipitation,
                                     years_baseline_period,
                                     rgi_data_set) {

  Lt <- (annual_precipitation |> dplyr::select(-Year)) * NA
  Lt <- Lt[(years_baseline_period+1):base::dim(Lt)[1],]
  L0 <- rgi_data_set$Lmax / 1000  # [km]
  Pt <- (annual_precipitation |> dplyr::select(-Year))
  Pt <- Pt[(years_baseline_period+1):base::dim(Pt)[1],]
  mTp <- annual_temperature_annomaly |> dplyr::select(-Year)
  mTp <- mTp[(years_baseline_period+1):base::dim(mTp)[1],]
  dt <- 1
  s <- rgi_data_set$Slope
  dLt <- L0 * 0
  year <- annual_precipitation$Year[(years_baseline_period+1):base::dim(annual_precipitation)[1]]

  Lt[1,] <- L0
  dLt <- Pt * 0

  c = 2.3 * Pt^(0.6)/s
  for (i in c(1:(base::dim(Lt)[1]-1))) {
    tau = 2266.67/(s * sqrt(L0 * (1+20*s) * Pt[i,]))
    dLt[i+1,] = dLt[i,] - 1/tau * (c[i,] * mTp[i,] + dLt[i,]) * dt
    Lt[i+1,] = L0 + dLt[i+1,]
  }
  dLt$Year <- year
  Lt$Year <- year
  return(base::list(dLt, Lt))
}
