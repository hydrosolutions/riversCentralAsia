---
title: "Preparation of climate forcing"
output: rmarkdown::html_vignette
bibliography: [references.bib, HMA_bibliography.bib]
vignette: >
  %\VignetteIndexEntry{Preparation of climate forcing}
  %\VignetteEngine{knitr::knitr}
  %\VignetteEncoding{UTF-8}
---



Typically, a river basin is discretized into hydrological response units (HRU) that capture the hydrological properties of a zone within the river basin. Often, HRU are derived from digital elevation models (DEMs) to be able to represent the elevation-dependent timing of snow melt in a basin. This is especially suitable for mountainous basins where gravity flow determines the river runoff. However, in lower lying basins, geology or land use may dominate the hydrology and thus HRU may have to be derived from geological or land use maps.  

The function `gen_basinElevationBands` allows the generation of a shape layer with elevation bands derived from a DEM. Note that you can play with the parameters of the function to adjust the shapes of the elevation bands.   

To reproduce this vignette, please download the DEM [here](https://www.dropbox.com/s/g4cudydy3stcxih/16076_DEM.tif?dl=0). 


```r
library(tidyverse)
library(lubridate)
library(timetk)
library(riversCentralAsia)

gis_path <- "../../atbashy_glacier_demo_data/GIS/16076_DEM.tif"
crs_project <- "+proj=longlat +datum=WGS84"  # EPSG:4326, latlon WGS84

# Parameter definition for the generation of the elevation bands
band_interval <- 500 # in meters. Note that normally you want to work with band intervals of 100 m to 200 m. To make the model less computationally demanding, we work with a coarser resolution of 500 m for this demo. 
holeSize_km2 <- .1 # cleaning holes smaller than that size
smoothFact <- 2 # level of band smoothing
demAggFact <- 2 # dem aggregation factor (carefully fine-tune this)
## Delineation
hru_shp <- gen_basinElevationBands(
  dem_PathN = gis_path, demAggFact = demAggFact, band_interval = band_interval, 
  holeSize_km2 = holeSize_km2, smoothFact = smoothFact)

# Control output
hru_shp %>% plot()
```

![Broad elevation bands generated for the Atbashy basin.](figure/unnamed-chunk-2-1.png)

Some minor post-processing is further required and the HRU layer is ready for import to RS Minerve for use in the automated model creation. The open-source book [Modeling of Hydrological Systems in Semi-Arid Central Asia](https://hydrosolutions.github.io/caham_book/){target="_blank"} gives step-by-step instructions for this.   

We recommend the use of daily precipitation and temperature data from the CHELSA data set (made available by WSL)[@karger_climatologies_2017; @karger_high-resolution_2020].  

## References


