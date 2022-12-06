---
title: "Preparation of climate forcing"
output: rmarkdown::html_vignette
bibliography: [references.bib, HMA_bibliography.bib]
vignette: >
  %\VignetteIndexEntry{Preparation of climate forcing}
  %\VignetteEngine{knitr::knitr}
  %\VignetteEncoding{UTF-8}
---



## Preparation of a GIS layer with hydrological response unit
Typically, a river basin is discretized into hydrological response units (HRU) that capture the hydrological properties of a zone within the river basin. Often, HRU are derived from digital elevation models (DEMs) to be able to represent the elevation-dependent timing of snow melt in a basin. This is especially suitable for mountainous basins where gravity flow determines the river runoff. However, in lower lying basins, geology or land use may dominate the hydrology and thus HRU may have to be derived from geological or land use maps.  

The function `gen_basinElevationBands` allows the generation of a shape layer with elevation bands derived from a DEM. Note that you can play with the parameters of the function to adjust the shapes of the elevation bands.   

To reproduce this vignette, please make sure you have this package as well as the example data package downloaded (see [README](https://hydrosolutions.github.io/riversCentralAsia/){target="_blank"}). 


```r
library(tidyverse)
library(lubridate)
library(timetk)
library(riversCentralAsia)

gis_path <- "../../riversCentralAsia_ExampleData/16076_DEM.tif"
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

Some minor post-processing is further required and the HRU layer is ready for import to RS Minerve for use in the automated model creation. The open-source book Modeling of Hydrological Systems in Semi-Arid Central Asia, [section on geospatial data preparation](https://hydrosolutions.github.io/caham_book/geospatial_data.html){target="_blank"} gives step-by-step instructions for this.   

## Extraction of climate data on hydrological response units
We recommend the use of daily precipitation and temperature data from the CHELSA data set (made available by WSL)[@karger_climatologies_2017; @karger_high-resolution_2020]. The data is downloaded from the CHELSA server, then extracted to each hydrological response unit and reformated to the RS MINERVE forcing input format using function ```gen_HRU_Climate_CSV_RSMinerve```. Please note that the global CHELSA data set at 1km grid resolution requires several GB of free storage space on your computer.

This process is demonstrated in detail in the book Modelling of Hydrological Systems in Semi-Arid Central Asia, [section Climate Data - Downscaling and Bias Correction](https://hydrosolutions.github.io/caham_book/climate_data.html#sec-bcds-quantile-mapping){target="_blank"}. Below we show an example useage from this book chapter. This example is reproducible with the (larger) example data set from the book but not with the example data set in this package. 


```r
# Temperature data processing
temp_or_precip <- "Temperature"
hist_obs_tas <- riversCentralAsia::gen_HRU_Climate_CSV_RSMinerve(
  climate_files = <List of CHELSA temperature files>,
  catchmentName = <river_name>,
  temp_or_precip = <'Temperature' or 'Precipitation'>,
  elBands_shp = <hru_shp>,
  startY = <start year>,
  endY = <end year>,
  obs_freqency = <'hour', 'day', or 'month'>,  # Note that CHELSA data is available at daily or monthly frequency, not hourly.
  climate_data_type = <'hist_obs', 'hist_sim', or 'fut_sim'>,
  crs_project = <a projection code, for example '+proj=longlat +datum=WGS84'>)
```

This produces a tibble with the daily average temperatures for each elevation band in the input elBands_shp layer. The same function can be used for other data types like bias-corrected GCM model results. 

## Bias correction
Also here, due to the size of the input files, we do not provide a reproducible example in this package but refer the interested reader to the book Modelling of Hydrological Systems in Semi-Arid Central Asia, [section Climate Data - Downscaling and Bias Correction](https://hydrosolutions.github.io/caham_book/climate_data.html#sec-bcds-quantile-mapping){target="_blank"} where reproducible examples of the downscaling of projected climate data are available. The bias correction is done using the [R package qmap](https://CRAN.R-project.org/package=qmap){target="_blank"} [@gudmundsson_qmap_2016] but alternative packages exist that may be used (e.g. [downscaleR](https://github.com/SantanderMetGroup/downscaleR){target="_blank"} or the R package on Multivariate Bias Correction [MBC](https://cran.r-project.org/web/packages/MBC/index.html){target="_blank"}). 

## References


