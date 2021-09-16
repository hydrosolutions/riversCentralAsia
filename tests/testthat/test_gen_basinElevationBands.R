test_that("Elevation bands are correctly generated", {

  dem_PathN <- normalizePath(file.path("DEM.tif"))
  dem_FileN <- "DEM.tif"
  band_interval <- 500 # in meters
  holeSize_km2 <- 10 # cleaning holes smaller than that size
  smoothFact <- 2 # level of band smoothing
  demAggFact <- 2 # dem aggregation factor
  test_data <- gen_basinElevationBands(dem_PathN, dem_FileN, demAggFact,
                                       band_interval, holeSize_km2, smoothFact)
  expect_equal(1, test_data$layer[1])
})

test_that("Can read dem from raster object", {

  dem <- raster::raster(normalizePath(file.path("DEM.tif")))
  band_interval <- 500 # in meters
  holeSize_km2 <- 10 # cleaning holes smaller than that size
  smoothFact <- 2 # level of band smoothing
  demAggFact <- 2 # dem aggregation factor
  test_data <- gen_basinElevationBands(dem_PathN = dem, demAggFact = demAggFact,
                                       band_interval = band_interval,
                                       holeSize_km2 = holeSize_km2,
                                       smoothFact = smoothFact)
  expect_equal(1, test_data$layer[1])
})
