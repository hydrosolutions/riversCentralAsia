#' Generate basin elevation bands from shapefile
#'
#' This function takes a DEM and generates altitude bands according to the interval spacing chosen.
#' It also applies different clean up operations that require user specified values for the
#' smoothr::drop_crumbs() and smoothr::fill_holes() functions. These subbasins, once stored as a
#' Shapefile can then be further edited in QGIS.
#'
#' @param dem_PathN Path to original stored DEM file
#' @param dem_FileN DEM file name
#' @param demAggFact Aggregation factor to downsample DEM (greatly improves computational efficiency)
#' @param band_interval Elevation bands interval / spacing (in meters)
#' @param holeSize_km2 Minimum Size of holes that will be kept during cleaning operation (in square kilometers)
#' @param smoothFact smoothness of final elevation bands (smoothness parameter of smoothr::smooth() function)
#' @return Simple feature (sf) multipolygon
#' @export
gen_basinElevationBands <- function(dem_PathN,dem_FileN,demAggFact,band_interval,holeSize_km2,smoothFact){
  # Load DEM & define bands
  dem <- raster::raster(paste0(dem_PathN,dem_FileN))
  dem <- raster::aggregate(Gunt_DEM,fact=demAggFact) # this is in UTM 42N
  bands <- seq(raster::minValue(dem), raster::maxValue(dem), band_interval)
  # Classification
  dem_classes <- raster::cut(dem, breaks = bands)
  raster::res(dem_classes) <- dem_classes %>% raster::res() %>% dplyr::first() %>% dplyr::round(.,3)
  # Create Shapes
  dem_classes_poly <- raster::rasterToPolygons(dem_classes,dissolve = TRUE) %>% sf::st_as_sf()
  # Clean up
  dem_classes_poly_clean <-
    smoothr::drop_crumbs(dem_classes_poly,units::set_units((dem_classes %>% raster::res() %>% dplyr::first())^2 %>% base::round(), m^2))
  dem_classes_poly_clean <- smoothr::fill_holes(dem_classes_poly_clean,units::set_units(holeSize_km2,km^2))
  dem_classes_poly_clean <- smoothr::smooth(dem_classes_poly_clean, method = "ksmooth", smoothness = smoothFact)
  return(dem_classes_poly_clean)
}
