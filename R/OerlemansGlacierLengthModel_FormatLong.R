#' Calculates glacier length following Oerleman 2005.
#'
#' The function is used to calculate the length of glaciers over time given an initial length and climate forcing (mean annual temperature and annual precipitation). This is an annual model.
#'
#' @param annual_temperature_annomaly A tibble of temperature annomalies per Model type, RCP and Year. Column names must be Year, Model, RCP, Glacier and "Ta [deg K]" for the temperature annomaly.
#' @param annual_precipitation A tibble of precipitation sums per Model type, RCP and Year. Column names must be Year, Model, RCP, Glacier and "P [m/a]" for precipitation.
#' @param years_baseline_period The number of years at the beginning of the dataset which were used to calculate the average temperature baseline. They are substracted from the glacier length analysis. If the tibbles do not include the baseline years, set years_baseline_period to 0.
#' @param rgi_data_set An sf object, a data frame or a tibble, for example a subset of the Randolph Glacier Inventory 6.0 in the area of interest. Must contain a glacier length attribute (Lmax) and a glacier slope attribute (Slope).
#' @return A list with dLt and Lt. dLt is a tibble with the changes of glacier length in km ("dL(t) [km]") over time (Year) for each Glacier, Model, and RCP scenario. Lt is a tibble of glacier length in km ("L(t) [km]") over time (Year) for each Glacier, Model and RCP scenario.
#' @note This function is suitable if you have the climate data in a long table format. If you have the climate data in a wide table format with the forcing per glacier in columns use \code{\link{OerlemansGlacierLengthModel}} instead.
#' @references Oerlemans (2005) Extracting a Climate Signal from 169 Glacier Records. Science. DOI: 10.1126/science.1107046.
#' @family Glacier functions
#' @examples
#'   glaciers <- dplyr::tibble(ID = c(1, 2, 3),
#'                             Lmax = c(500, 5000, 13000),
#'                             Slope = c(30, 16, 20))
#'   temperature_annomaly <-
#'     rbind(tidyr::tibble(Year = c(2000:2010),
#'                         RCP = "RCP1",
#'                         Model = "ModelA",
#'                         V1 = seq(0, 5,  0.5),
#'                         V2 = seq(0, 2,  0.2),
#'                         V3 = seq(0, 2,  0.2)) %>%
#'             tidyr::pivot_longer(dplyr::starts_with("V"),
#'                                 values_to = "Ta [deg K]", names_to = "Glacier"),
#'           tidyr::tibble(Year = c(2000:2010),
#'                         RCP = "RCP1",
#'                         Model = "ModelB",
#'                         V1 = seq(0.1, 5.1,  0.5),
#'                         V2 = seq(0.2, 2.2,  0.2),
#'                         V3 = seq(0.1, 2.1,  0.2)) %>%
#'             tidyr::pivot_longer(dplyr::starts_with("V"),
#'                                 values_to = "Ta [deg K]", names_to = "Glacier"),
#'           tidyr::tibble(Year = c(2000:2010),
#'                         RCP = "RCP2",
#'                         Model = "ModelA",
#'                         V1 = seq(0.8, 5.8,  0.5),
#'                         V2 = seq(0.9, 2.9,  0.2),
#'                         V3 = seq(0.8, 2.9,  0.2)) %>%
#'             tidyr::pivot_longer(dplyr::starts_with("V"),
#'                                 values_to = "Ta [deg K]", names_to = "Glacier"),
#'           tidyr::tibble(Year = c(2000:2010),
#'                         RCP = "RCP2",
#'                         Model = "ModelB",
#'                         V1 = seq(0.4, 5.4,  0.5),
#'                         V2 = seq(0.5, 2.5,  0.2),
#'                         V3 = seq(0.4, 2.4,  0.2)) %>%
#'             tidyr::pivot_longer(dplyr::starts_with("V"),
#'                                 values_to = "Ta [deg K]", names_to = "Glacier")
#'     )
#'   precipitation <-
#'     rbind(dplyr::tibble(Year = c(2000:2010),
#'                         RCP = "RCP1",
#'                         Model = "ModelA",
#'                         V1 = seq(0.7, 0.705,  0.0005),
#'                         V2 = seq(0.7, 0.5,  -0.02),
#'                         V3 = seq(1.500, 1.505,  0.0005)) %>%
#'             tidyr::pivot_longer(dplyr::starts_with("V"),
#'                                 values_to = "P [m/a]", names_to = "Glacier"),
#'           dplyr::tibble(Year = c(2000:2010),
#'                         RCP = "RCP1",
#'                         Model = "ModelB",
#'                         V1 = seq(0.7, 0.705,  0.0005),
#'                         V2 = seq(0.7, 0.5,  -0.02),
#'                         V3 = seq(1.500, 1.505,  0.0005)) %>%
#'             tidyr::pivot_longer(dplyr::starts_with("V"),
#'                                 values_to = "P [m/a]", names_to = "Glacier"),
#'           dplyr::tibble(Year = c(2000:2010),
#'                         RCP = "RCP2",
#'                         Model = "ModelA",
#'                         V1 = seq(0.7, 0.705,  0.0005),
#'                         V2 = seq(0.7, 0.5,  -0.02),
#'                         V3 = seq(1.500, 1.505,  0.0005)) %>%
#'             tidyr::pivot_longer(dplyr::starts_with("V"),
#'                                 values_to = "P [m/a]", names_to = "Glacier"),
#'           dplyr::tibble(Year = c(2000:2010),
#'                         RCP = "RCP2",
#'                         Model = "ModelB",
#'                         V1 = seq(0.7, 0.705,  0.0005),
#'                         V2 = seq(0.7, 0.5,  -0.02),
#'                         V3 = seq(1.500, 1.505,  0.0005)) %>%
#'             tidyr::pivot_longer(dplyr::starts_with("V"),
#'                                 values_to = "P [m/a]", names_to = "Glacier"))
#'   test_data <- OerlemansGlacierLengthModel_FormatLong(temperature_annomaly, precipitation, 0,
#'                                                       glaciers)
#'   dL <- test_data[[1]]
#'   L <- test_data[[2]]
#' @export
OerlemansGlacierLengthModel_FormatLong <- function(annual_temperature_annomaly,
                                         annual_precipitation,
                                         years_baseline_period,
                                         rgi_data_set) {

  no_models <- base::length(base::unique(annual_temperature_annomaly$Model))
  no_rcps <- base::length(base::unique(annual_temperature_annomaly$RCP))
  baseyear <- base::min(annual_temperature_annomaly$Year) + years_baseline_period

  dLt <- NULL
  Lt <- NULL

  for (m in c(1:no_models)) {
    for (r in c(1:no_rcps)) {
      temp <- annual_temperature_annomaly |>
        dplyr::ungroup() |>
        dplyr::filter(.data$Model == base::unique(annual_temperature_annomaly$Model)[m],
                      .data$RCP == base::unique(annual_temperature_annomaly$RCP)[r],
                      .data$Year > baseyear) |>
        dplyr::select(-.data$Model, -.data$RCP) |>
        tidyr::pivot_wider(id_cols = .data$Year, names_from = .data$Glacier,
                           values_from = .data$`Ta [deg K]`) |>
        dplyr::ungroup()
      prcp <- annual_precipitation |>
        dplyr::ungroup() |>
        dplyr::filter(.data$Model == base::unique(annual_temperature_annomaly$Model)[m],
                      .data$RCP == base::unique(annual_temperature_annomaly$RCP)[r],
                      .data$Year > baseyear) |>
        dplyr::select(-.data$Model, -.data$RCP) |>
        tidyr::pivot_wider(id_cols = .data$Year, names_from = .data$Glacier,
                           values_from = .data$`P [m/a]`) |>
        dplyr::ungroup()

      tmp <- riversCentralAsia::OerlemansGlacierLengthModel(temp, prcp, 0, rgi_data_set)
      dLttmp <- tmp[[1]] |>
        tidyr::pivot_longer(-.data$Year, names_to = "Glacier",
                            values_to = "dL(t) [km]") |>
        dplyr::mutate(Model = base::unique(annual_temperature_annomaly$Model)[m],
                      RCP = base::unique(annual_temperature_annomaly$RCP)[r])
      Lttmp <- tmp[[2]]  |>
        tidyr::pivot_longer(-.data$Year, names_to = "Glacier",
                            values_to = "L(t) [km]") |>
        dplyr::mutate(Model = base::unique(annual_temperature_annomaly$Model)[m],
                      RCP = base::unique(annual_temperature_annomaly$RCP)[r])

      dLt <- base::rbind(dLt, dLttmp)
      Lt <- base::rbind(Lt, Lttmp)
    }
  }

  return(base::list(dLt, Lt))

}
