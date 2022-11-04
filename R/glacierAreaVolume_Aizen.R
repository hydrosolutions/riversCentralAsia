#' Estimates glacier surface area and glacier volume.
#'
#' length, surface area and volume found by Aizen et al. in the Tien Shan
#' mountains. They can be used to estimate regional glacier volumes.
#'
#' @param glaciers A data.frame, tibble, or sf object. Must contain an attribute
#'   ```Lmax``` in meters (as in the Randolph Glacier Inventory (RGI 6.0)) or
#'   ```Length [km]``` in kilometers or ```L(t) [km]``` (as in the output from
#'   Oerlemans glacier length function).
#' @return Returns the input object with Area_Aizen_km2 and Volume_Aizen_km3
#'   added. Will return NULL if the length column in the input object is not
#'   found.
#' @references Aizen, Aizen & Kuzmichonok (2007) Glaciers and hydrological
#'   changes in the Tien Shan: simulation and prediction. Environmental Research
#'   Letters. DOI: 10.1088/1748-9326/2/4/045019.
#' @examples
#' glacier <- tibble::tibble(Year = c(2000:2010),
#'                           "Length [km]" = c(5.7, 5.6, 5.5, 5.5, 5.4, 5.3,
#'                                             5.3, 5.2, 5.1, 5, 4.8))
#' glacierAreaVolume_Aizen(glacier)
#' @family Glacier functions
#' @export
glacierAreaVolume_Aizen <- function(glaciers) {

  if ("Lmax" %in% names(glaciers)) {
    # Note that Lmax is assumed to be in meters and is converted to km
    glaciers <- glaciers %>%
      dplyr::mutate(Area_Aizen_km2 = ((Lmax/1000) / 1.6724)^(1/0.561),
                    Volume_Aizen_km3 = base::ifelse(Area_Aizen_km2 < 0.1,
                                                    0.03782 * Area_Aizen_km2^(1.23),
                                                    base::ifelse(Area_Aizen_km2 < 25,
                                                                 (0.03332 * Area_Aizen_km2^(1.08) * base::exp(0.1219 * (Lmax/1000))) / ((Lmax/1000)^(0.08846)),
                                                                 0.018484 * Area_Aizen_km2 + 0.021875 * Area_Aizen_km2^(1.3521))))
  } else if ("Length [km]" %in% names(glaciers)) {
    glaciers <- glaciers %>%
      dplyr::mutate(Area_Aizen_km2 = (`Length [km]` / 1.6724)^(1/0.561),
                    Volume_Aizen_km3 = base::ifelse(Area_Aizen_km2 < 0.1,
                                                    0.03782 * Area_Aizen_km2^(1.23),
                                                    base::ifelse(Area_Aizen_km2 < 25,
                                                                 (0.03332 * Area_Aizen_km2^(1.08) * base::exp(0.1219 * (`Length [km]`))) / (`Length [km]`^(0.08846)),
                                                                 0.018484 * Area_Aizen_km2 + 0.021875 * Area_Aizen_km2^(1.3521))))
  } else if ("L(t) [km]" %in% names(glaciers)) {
    glaciers <- glaciers %>%
      dplyr::mutate(Area_Aizen_km2 = (`L(t) [km]` / 1.6724)^(1/0.561),
                    Volume_Aizen_km3 = base::ifelse(Area_Aizen_km2 < 0.1,
                                                    0.03782 * Area_Aizen_km2^(1.23),
                                                    base::ifelse(Area_Aizen_km2 < 25,
                                                                 (0.03332 * Area_Aizen_km2^(1.08) * base::exp(0.1219 * (`L(t) [km]`))) / (`L(t) [km]`^(0.08846)),
                                                                 0.018484 * Area_Aizen_km2 + 0.021875 * Area_Aizen_km2^(1.3521))))
  } else {
    return(NULL)
  }

  return(glaciers)
}

