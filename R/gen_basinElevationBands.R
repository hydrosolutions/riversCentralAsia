#' Generate basin elevation bands from DEM
#'
#' This function takes a DEM and generates altitude bands according to the interval spacing chosen.
#' It also applies different clean up operations that require user specified values for the
#' smoothr::drop_crumbs() and smoothr::fill_holes() functions. These sub-basins, once stored as a
#' shape file can then be further edited in QGIS.
#'
#' @param dem_PathN Path to original stored DEM file. Can be path to directory
#'   containing the DEM file or the path to the DEM file directly. Can also be
#'   a raster object.
#' @param dem_FileN DEM file name (optional, defaults to DEM.tif)
#' @param demAggFact Aggregation factor to down-sample DEM (greatly improves computational efficiency)
#' @param band_interval Elevation bands interval / spacing (in meters)
#' @param holeSize_km2 Minimum Size of holes that will be kept during cleaning operation (in square kilometers)
#' @param smoothFact smoothness of final elevation bands (smoothness parameter of smoothr::smooth() function)
#' @return Simple feature (sf) multi-polygon. Returns NULL if not successfull.
#' @family Pre-processing
#' @export
gen_basinElevationBands <- function(dem_PathN, dem_FileN = "DEM.tif", demAggFact, band_interval, holeSize_km2, smoothFact){

  # Load DEM & define bands
  if (class(dem_PathN) == "RasterLayer") {
    dem <- dem_PathN
  } else if (file_test("-f", dem_PathN)) {
    filepath <- dem_PathN
    dem <- raster::raster(filepath)
  } else {
    filepath <- normalizePath(file.path(dem_PathN, dem_FileN))
    if (!file_test("-f", filepath)) {
      cat("Error: Cannot find file", dem_PathN, "nor", filepath,
          "and dem_PathN is not of class RasterLayer.")
      return(NULL)
    } else {
      dem <- raster::raster(filepath)
    }
  }
  # Set minmax values of raster
  dem <- dem %>% raster::setMinMax()
  dem <- raster::aggregate(dem, fact = demAggFact) # this is in UTM 42N
  bands <- seq(raster::minValue(dem), raster::maxValue(dem), band_interval)

  # Classification
  dem_classes <- raster::cut(dem, breaks = bands)
  raster::res(dem_classes) <- dem_classes |>
    raster::res() |>
    dplyr::first() |>
    base::round(3)

  # Create Shapes
  dem_classes_poly <- raster::rasterToPolygons(dem_classes, dissolve = TRUE) |>
    sf::st_as_sf()

  # Clean up
  dem_classes_poly_clean <-
    smoothr::drop_crumbs(dem_classes_poly,
                         units::set_units((dem_classes |>
                                             raster::res() |>
                                             dplyr::first())^2 |>
                                            base::round(), m^2))
  dem_classes_poly_clean <- smoothr::fill_holes(dem_classes_poly_clean,
                                                units::set_units(holeSize_km2,
                                                                 km^2))
  dem_classes_poly_clean <- smoothr::smooth(dem_classes_poly_clean,
                                            method = "ksmooth",
                                            smoothness = smoothFact)
  return(dem_classes_poly_clean)

}
