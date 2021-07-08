test_that("Elevation bands are correctly generated", {

  dem_PathN <- normalizePath(file.path("DEM.tif"))
  dem_FileN <- "DEM.tif"
  band_interval <- 500 # in meters
  holeSize_km2 <- 10 # cleaning holes smaller than that size
  smoothFact <- 2 # level of band smoothing
  demAggFact <- 10 # dem aggregation factor
  test_data <- gen_basinElevationBands(dem_PathN, dem_FileN, demAggFact,
                                       band_interval, holeSize_km2, smoothFact)

})
