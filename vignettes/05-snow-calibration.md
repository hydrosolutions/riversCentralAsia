---
title: "Manual calibration of snow water equivalent"
bibliography: references.bib
output: rmarkdown::html_vignette
fig_caption: yes
vignette: >
  %\VignetteIndexEntry{Manual calibration of snow water equivalent}
  %\VignetteEngine{knitr::knitr}
  %\VignetteEncoding{UTF-8}
---




```r
library(tidyverse)
library(lubridate)
library(sf)

devtools::install_github("hydrosolutions/riversCentralAsia")
#> jsonlite (1.8.3  -> 1.8.4 ) [CRAN]
#> terra    (1.6-41 -> 1.6-47) [CRAN]
#> ncdf4    (1.19   -> 1.20  ) [CRAN]
#> 
#>   There is a binary version available but the source version is later:
#>          binary source needs_compilation
#> jsonlite  1.8.3  1.8.4              TRUE
#> 
#> package 'terra' successfully unpacked and MD5 sums checked
#> package 'ncdf4' successfully unpacked and MD5 sums checked
#> 
#> The downloaded binary packages are in
#> 	C:\Users\marti\AppData\Local\Temp\RtmpwzwJWu\downloaded_packages
#> * checking for file 'C:\Users\marti\AppData\Local\Temp\RtmpwzwJWu\remotes5a64e0668e4\hydrosolutions-riversCentralAsia-b68ba36/DESCRIPTION' ... OK
#> * preparing 'riversCentralAsia':
#> * checking DESCRIPTION meta-information ... OK
#> * checking for LF line-endings in source and make files and shell scripts
#> * checking for empty or unneeded directories
#> * building 'riversCentralAsia_1.1.0.tar.gz'
#> 
library(riversCentralAsia)

# The Atbashy glacier demo data is available from 
# https://www.dropbox.com/sh/r0lqggc77ka0uxd/AAChuIyLHHFIfAdgxNKiU2dpa?dl=0
# Download the data and adapt the path below.  
data_path <- "../../atbashy_glacier_demo_data/"
```

This chapter of the vignette shows how to compare simulated snow water equivalent (SWE) to third party data. These code snipets can be used to iteratively adapt the parameters of the snow modules in the HBV models to better represent the SWE of the data product.

In places where SWE observations are not available, a binary variable of SWE larger than a threshold per hydrological response unit (HRU) can be compared to snow covered area (a MODIS product) in each HRU (see for example @parajka_value_2008).

## Calibrating snow water equivalent (SWE)

At the time of writing, RS Minerve does not support the automatic calibration of SWE. However, snow melt is a major contribution to discharge in Central Asia. Measurements of SWE are only very rarely available. Thus, re-analysis products like the High Mountain Asia Snow Reanalysis product are valuable resources to validate hydrolgoical modelling efforts.

As automated calibration of SWE is not yet supported in RS Minerve, we propose a work around in R to iteratively adapt the parameters of the HBV snow modules.

### Extract observed SWE

Actually observed SWE is not typically available for hydrological modeling in many catchments in Central Asia, we therefore propose to use existing model products like the High Mountain Snow Reanalysis Product [@liu_spatiotemporal_2021] which is available through [NSIDC](https://nsidc.org/data/HMA_SR_D/). Login to USGS Earth Data, select the files for download for your model area and download the data (for example using the python download script). We will refer to the SWE data set from HMASR as observed data.

The downloaded data is subsequently pre-processed to extract the daily average SWE per HRU on the valid pixels of the data set (note that HMASR is not available on areas with permanent snow or ice cover). The following code sniped shows how this can be done.

If you wish to reproduce the code below, please make sure that the [demo data set](https://www.dropbox.com/sh/r0lqggc77ka0uxd/AAChuIyLHHFIfAdgxNKiU2dpa?dl=0){target="_blank"} is downloaded to your computer. 

```r
library(tmap)
library(sf)
library(raster)
library(tidyverse)
library(lubridate)

devtools::install_github("hydrosolutions/riversCentralAsia")
library(riversCentralAsia)

# Download the demo data set from dropbox
# https://www.dropbox.com/sh/r0lqggc77ka0uxd/AAChuIyLHHFIfAdgxNKiU2dpa?dl=0

# Path to the data directory downloaded from the download link provided above. 
# Here the data is extracted to a folder called atbashy_glacier_demo_data
data_path <- "../../atbashy_glacier_demo_data/"

# Function to concatenate and mask the HMASR product and extract SWE for each 
# HRU in the model. 
extract_HMASR_Atbashy <- function(filespath, year, shape_latlon, varname) {
  index = sprintf("%02d", (year - 1999))
  
  # Load non-seasonal snow mask
  filepart <- "_MASK.nc"
  
  # The Atbashy basin is covered by two raster stacks
  mask_w <- raster::brick(paste0(filespath, 
                                 "HMA_SR_D_v01_N41_0E76_0_agg_16_WY", 
                                 year, "_", index, filepart), 
                          varname = "Non_seasonal_snow_mask")
  raster::crs(mask_w) = raster::crs("+proj=longlat +datum=WGS84 +no_defs")
  mask_e <- raster::brick(paste0(filespath,
                                 "HMA_SR_D_v01_N41_0E77_0_agg_16_WY", 
                                 year, "_", index, filepart), 
                          varname = "Non_seasonal_snow_mask")
  raster::crs(mask_e) = raster::crs("+proj=longlat +datum=WGS84 +no_defs")
  
  # The rasters need to be rotated
  template <- raster::projectRaster(from = mask_e, to= mask_w, alignOnly = TRUE)
  
  # template is an empty raster that has the projected extent of r2 but is 
  # aligned with r1 (i.e. same resolution, origin, and crs of r1)
  mask_e_aligned <- raster::projectRaster(from = mask_e, to = template)
  mask_w <- flip(t(mask_w), direction = 'x')
  mask_e_aligned <- flip(t(mask_e_aligned), direction = 'x')
  mask <- merge(mask_w, mask_e_aligned, tolerance = 0.1) 
  mask = raster::projectRaster(from = mask, 
                               crs = crs("+proj=utm +zone=42 +datum=WGS84 +units=m +no_defs"))
  
  # Load snow data
  varname = "SWE_Post"
  filepart <- "_SWE_SCA_POST.nc"
  sca_w <- raster::brick(paste0(filespath, 
                                "HMA_SR_D_v01_N41_0E76_0_agg_16_WY", 
                                year, "_", index, filepart), 
                         varname = varname, level = 1)
  
  raster::crs(sca_w) = raster::crs("+proj=longlat +datum=WGS84 +no_defs")
  sca_e <- raster::brick(paste0(filespath,
                                "HMA_SR_D_v01_N41_0E77_0_agg_16_WY", 
                                year, "_", index, filepart), 
                         varname = varname, level = 1)
  
  raster::crs(sca_e) = raster::crs("+proj=longlat +datum=WGS84 +no_defs")
  template <- raster::projectRaster(from = sca_e, to = sca_w, alignOnly = TRUE)
  # template is an empty raster that has the projected extent of r2 but is 
  # aligned with r1 (i.e. same resolution, origin, and crs of r1)
  sca_e_aligned<- raster::projectRaster(from = sca_e, to = template)
  sca_w <- flip(t(sca_w), direction = 'x')
  sca_e_aligned <- flip(t(sca_e_aligned), direction = 'x')
  sca <- raster::merge(sca_w, sca_e_aligned, tolerance = 0.1)
  sca <- projectRaster(from = sca, 
                       crs = crs("+proj=utm +zone=42 +datum=WGS84 +units=m +no_defs"))
  
  sca_masked <- mask(sca, mask, maskvalue = 1)
  sca_masked <- mask(sca_masked, basin)
  
  subbasin_data_a <- raster::extract(sca, shape_latlon, fun = mean, 
                                     na.rm = TRUE, method = "bilinear") 
  subbasin_data <- subbasin_data_a %>% t() %>% as_tibble() 
  names(subbasin_data) <- shape_latlon$name
  subbasin_data <- subbasin_data %>%
    mutate(HyDOY = c(1:dim(subbasin_data_a)[2]), 
           HyYear = year)
  
  return(subbasin_data)
}

# Load additional necessary data
dem <- raster(paste0(data_path, "GIS/16076_DEM.tif"))
basin <- st_read(paste0(data_path, "GIS/16076_Basin_outline.shp"), 
                 quiet = TRUE)
shape_latlon <- st_read(paste0(data_path, "GIS/16076_HRU.shp")) |> 
  st_transform(crs = crs("+proj=longlat +datum=WGS84 +no_defs"))

# Load one example file and display SWE for a random date in the cold season. 
filespath <- paste0(data_path, "SNOW/")

# Actual data extraction
varname = "SWE_Post"
year = 1999
swe <- extract_HMASR_Atbashy(filespath, year, shape_latlon, varname)

# The subsequent years of data you can extract in a loop. 
# Not run in this example as we provide you only with the first year of data
# Later years you can download from NSIDC
# for (year in 2000:2012) { 
#   temp <- extract_HMASR_Atbashy(filespath, year, shape_latlon, varname)
#   swe <- rbind(swe, temp)
# }

# Reformatting 
swe$NoDaysPerYear <- as.numeric(
  format(as.Date(paste(swe$HyYear, "12", "31", sep="-")), "%j"))
swe <- swe %>%
  mutate(DOY = ifelse(
    HyDOY > (NoDaysPerYear - yday(as_date(paste0(HyYear, "-10-01")))),
    HyDOY - (NoDaysPerYear - yday(as_date(paste0(HyYear, "-10-01")))),
    HyDOY - 1 + yday(as_date(paste0(HyYear, "-10-01")))))

swe <- swe %>%
  mutate(Year = ifelse(HyDOY < DOY, HyYear, HyYear + 1))
swe$HyYear <- swe$HyYear + 1

swe$Date <- as_date(paste0(swe$Year, "-", swe$DOY), format = "%Y-%j")

swel <- pivot_longer(swe, contains("_"), names_to = "Name", 
                     values_to = "SWE") |> 
  separate(Name, into = c("Subbasin", "layer"), sep = "_Subbasin_", 
           remove = FALSE) |> 
  mutate(layer = factor(layer, levels = c(10:1)))

# As this data extraction can take several minutes, we store the snow water 
# equivalents in an RData file for later use. 
# save(list = "swel", file = "SWE.RData")
```

You find 4 sample files from the HMASR product available in the Atbashy demo data folder to try out the code above. We have done the pre-processesing for Atbashy and make available the SWE.RData file which contains daily average SWE per HRU in the Atbashy model.

### Write check node file to read out all SWE in the Atbashy model.

Data can be exported from RS Minerve with various methods. The manual export of all SWE model results in a larger model can become time consuming, therefore RS Minerve offers the possibility to import a so called check node file to specify a selection of model variables to export. The below code snipped shows how to write a check node file for the extracting of SWE simulation results from RS Minerve.


```r
Object_IDs <- st_read(paste0(data_path, 
                             "GIS/16076_HRU.shp")) |> 
  st_drop_geometry() 

data <- tibble(
  Model = rep("Model Atbashy", length(Object_IDs$name)), 
  Object = c(rep("HBV92", length(Object_IDs$name))), 
  ID = Object_IDs$name, 
  Variable = rep("SWE (m)")
)

writeSelectionCHK(filepath = paste0(data_path, "RSMINERVE/SWE.chk"), 
                  data = data, 
                  name = "SWE")
```

In RS Minerve selection and plots tab, import the check node file SWE.chk written above and plot the data. Then export the data to a file which is read into RStudio below.

### Read RS Minerve SWE results

Below we read the simulated SWE produced with an initial parameter set that was created without taking into account SWE observations.


```r
swe_sim <- readResultCSV(
  paste0(data_path, 
         "RSMINERVE/Atbaschy_Results_SWE_initial_params.csv")) |>  
  mutate(Subbasin = gsub("\\_Subbasin\\_\\d+$", "", model), 
         "Elevation band" = str_extract(model, "\\d+$") |> as.numeric(), 
         "Elevation band" = factor(`Elevation band`, levels = c(1:20)))

ggplot(swe_sim) + 
  geom_point(aes(date, value, colour = `Elevation band`), alpha = 0.4, size = 0.4) + 
  scale_colour_viridis_d() + 
  facet_wrap("Subbasin") + 
  theme_bw()
```

![Simulated SWE per HRU in the Atbashy model.](figure/unnamed-chunk-4-1.png)

This data can be used to manually validate the SWE with secondary data sources like for example the High Mountain Asia Snow Reanalysis Product (Liu et al., 2021. https://doi.org/10.5067/HNAUGJQXSCVU).

### Read in observations of snow water equivalent

The data has been downloaded and pre-processed (see above).


```r
# Loads SWE extracted from HMASR per HRU in the Atbashy model. 
# For the sake of simplicity, we have extracted the SWE data for the Atbashy 
# example. 
# See the code chunk above under "Extract observed SWE" for an example of how 
# to extract SWE from the HMASR product yourselve. 
load(paste0(data_path, "/SNOW/SWE.RData"))

compare_swe <- swe_sim |> 
  rename(Sim = value) |> 
  dplyr::select(date, model, Sim, Subbasin, `Elevation band`) |> 
  left_join(swel |> 
              dplyr::select(Date, Name, SWE) |> 
              rename(Obs = SWE), 
            by = c("date" = "Date", "model" = "Name")) |>
  mutate(Month = month(date), 
         Year = hyear(date), 
         Month_str = factor(format(date, "%b"), 
                            levels = c("Jan", "Feb", "Mar", "Apr", "May", 
                                       "Jun", "Jul", "Aug", "Sep", "Oct", 
                                       "Nov", "Dec")), 
         "Obs-Sim" = Obs - Sim)

RMSE = sqrt(mean(compare_swe$`Obs-Sim`, na.rm = TRUE))

ggplot(compare_swe) +
  geom_abline(intercept = 0, slope = 1) + 
  geom_point(aes(Obs, Sim), size = 0.4) +
  scale_color_viridis_d() + 
  xlab("Observed SWE [m]") + 
  ylab("Simulated SWE [m]") + 
  coord_fixed() + xlim(0, 1.5) + ylim(0, 1.5) + 
  theme_bw()
```

![Overall observed vs. simulated snow water equivalent in the Atbashy model.](figure/unnamed-chunk-5-1.png)


```r
ggplot(compare_swe) +
  geom_abline(intercept = 0, slope = 1) + 
  geom_point(aes(Obs, Sim, colour = `Elevation band`), size = 0.4) +
  scale_color_viridis_d() + 
  xlab("Observed SWE [m]") + 
  ylab("Simulated SWE [m]") + 
  facet_wrap("Month_str") + 
  coord_fixed() + xlim(0, 1.5) + ylim(0, 1.5) + 
  theme_bw()
```

![Observed vs. simulated snow water equivalent per month and per elevation band in the Atbashy model.](figure/unnamed-chunk-6-1.png)

Now we can adjust the parameters of the snow modules in the HBV model objects in RS Minerve and iteratively improve the fit between the observed and simulated snow water equivalent.

We can also write the HMASR data to a csv file (see chunk below) and import it to RS Minerve for time series comparison and to facilitate manual calibration.


```r
# Generate date sequence in accordance with RSMinerve Requirements
dates <- tibble(Date = swel$Date |> unique())
datesChar <- posixct2rsminerveChar(dates$Date, tz = "UTC") |> 
  rename(Station = value) |> 
  mutate(Station = gsub(" 02:00", " 00:00", Station), 
         Station = gsub(" 01:00", " 00:00", Station))

# Get names of HRUs
df_body <- swel |>
  dplyr::select(Date, Name, SWE) |> 
  distinct() |> 
  pivot_wider(names_from = Name, values_from = SWE, values_fn = "mean") |> 
  dplyr::select(-Date)

# Construct csv-file header.  
# See the definition of the RSMinerve .csv database file at:
# https://www.youtube.com/watch?v=p4Zh7zBoQho
header_Station <- tibble(
  Station = c('X','Y','Z','Sensor','Category','Unit','Interpolation'))

# Get random X and Y coordinate, they are not relevant for the model but we need
# an entry for importing the file to RS Minerve. 
HRU_XYZ <- matrix(0, nrow = 3, ncol = dim(df_body)[2]) |> as.data.frame() 
names(HRU_XYZ) <- names(df_body)

# Sensor (SWE), Category, Unit and Interpolation
nBands <- HRU_XYZ |> dim() |> dplyr::last()
sensorType <- rep("SWE", nBands)
unit <- rep("m", nBands)
category <- rep("Snow depth", nBands)
interpolation <- rep("linear", nBands)
sensor <- rbind(sensorType, category, unit, interpolation) |> as_tibble()
names(sensor) <- names(df_body)

# Put everything together
file2write <- rbind(HRU_XYZ, sensor)
file2write <- header_Station |> add_column(file2write)
file2write <- file2write |> add_row(cbind(datesChar, df_body) |> 
                                      mutate_all(as.character))
file2write <- rbind(names(file2write), file2write)

# Write file to disk
write_csv(file2write, paste0(data_path, "RSMINERVE/SWEobs.csv"), 
          col_names = FALSE)
```

### View SWE simulation results after manual calibration


```r
swe_sim <- readResultCSV(
  paste0(data_path, 
         "RSMINERVE/Atbaschy_Results_SWE_manual_cal.csv")) |> 
  mutate(Subbasin = gsub("\\_Subbasin\\_\\d+$", "", model), 
         "Elevation band" = str_extract(model, "\\d+$") |> as.numeric(), 
         "Elevation band" = factor(`Elevation band`, levels = c(1:20)))

load(paste0(data_path, "/SNOW/SWE.RData"))

compare_swe <- swe_sim |> 
  rename(Sim = value) |> 
  dplyr::select(date, model, Sim, Subbasin, `Elevation band`) |> 
  left_join(swel |> 
              dplyr::select(Date, Name, SWE) |> 
              rename(Obs = SWE), 
            by = c("date" = "Date", "model" = "Name")) |>
  mutate(Month = month(date), 
         Year = hyear(date), 
         Month_str = factor(format(date, "%b"), 
                            levels = c("Jan", "Feb", "Mar", "Apr", "May", 
                                       "Jun", "Jul", "Aug", "Sep", "Oct", 
                                       "Nov", "Dec")), 
         "Obs-Sim" = Obs - Sim)

RMSE = sqrt(mean(compare_swe$`Obs-Sim`, na.rm = TRUE))

ggplot(compare_swe) +
  geom_abline(intercept = 0, slope = 1) + 
  geom_point(aes(Obs, Sim), size = 0.4) +
  scale_color_viridis_d() + 
  xlab("Observed SWE [m]") + 
  ylab("Simulated SWE [m]") + 
  coord_fixed() + xlim(0, 1.5) + ylim(0, 1.5) + 
  theme_bw()
```

![Overall observed vs. simulated snow water equivalent in the Atbashy model after manual calibration using SWE extracted from HMASR.](figure/unnamed-chunk-8-1.png)


```r
ggplot(compare_swe) +
  geom_abline(intercept = 0, slope = 1) + 
  geom_point(aes(Obs, Sim, colour = `Elevation band`), size = 0.4) +
  scale_color_viridis_d() + 
  xlab("Observed SWE [m]") + 
  ylab("Simulated SWE [m]") + 
  facet_wrap("Month_str") + 
  coord_fixed() + xlim(0, 1.5) + ylim(0, 1.5) + 
  theme_bw()
```

![Observed vs. simulated snow water equivalent per month and per elevation band in the Atbashy model after manual calibration against SWE from HMASR.](figure/unnamed-chunk-9-1.png)

The use of the SWE from the HMASR product improves the hydrological model.

## References

