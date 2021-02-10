#' Cutting raster file to basin shape with reprojection
#'
#' This function cuts a raster dataset to a specific basin shapefiles and project the raster
#' according to the specified projection.
#'
#' @param rasterIn Raster file (e.g. DEM)
#' @param aoiRegion_latlon Extent object of the larger region (i.e. for Central Asia, a good choice is extent(c(65,80.05,35.95,44.05))).
#' @param aoiBasin_UTM Extent object of the basin shapefile
#' @param proj_UTM CRS of UTM projection (i.e. for 42N in Central Asia, use "+init=epsg:32642")
#' @return Projected raster cut to basin
#' @export
cutRaster2Basin = function(rasterIn,aoiRegion_latlon,aoiBasin_UTM,proj_UTM){
  rasterRegion <- raster::crop(rasterIn,aoiRegion_latlon)
  rasterRegion_proj <- rasterRegion %>% raster::projectRaster(., crs = proj_UTM)
  rasterBasin_proj <- raster::crop(rasterRegion_proj,aoiBasin_UTM)
  return(rasterBasin_proj)
}
