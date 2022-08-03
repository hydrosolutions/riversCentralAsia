
<!-- README.md is generated from README.Rmd. Please edit that file -->

# riversCentralAsia

<!-- badges: start -->
<!-- badges: end -->

riversCentralAsia is an R Package with helper functions to - load,
manage and analyze hydrometeorological data from Central Asia, - process
and analyze as well as downscale ERA5 reanalysis data for arbitrary
basins in the region (shapefile required), - process and analyze
high-resolution past, current and future monthly CHELSA climatologies, -
generate daily/hourly climate scenarios using the stochastic weather
generator RMAWGEN, - prepare export files for hydrological-hydraulic
modeling using the RS MINERVE software, and - analyze climate impact
scenarios.

Currently, a relatively complete dataset of the Chirchik River Basin
with decadal and monthly data on discharge, precipitation and
temperature is included. More data will be made available in upcoming
iterations of the package

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.4667422.svg)](https://doi.org/10.5281/zenodo.4667422)

## Documentation & use cases

We now have a
[web-site](https://hydrosolutions.github.io/riversCentralAsia/index.html)
for the package where you can find articles (vignettes) on how to use
the functions. Please note that the web-site is work in progress and
continuously being updated.

### Direct links to articles and use cases

[Introduction on glaciers in water resources modelling and available
data](https://hydrosolutions.github.io/riversCentralAsia/articles/glaciers-01-intro.html)  
[Temperature index models for estimating glacier
melt](https://hydrosolutions.github.io/riversCentralAsia/articles/glaciers-02-DDMWB.html)  
[How to include glacier melt in RS
Minerve](https://hydrosolutions.github.io/riversCentralAsia/articles/glaciers-04-glaciers-RSM.html)

## License Information

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a><br />This
work is licensed under a
<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative
Commons Attribution-ShareAlike 4.0 International License</a>.

## Installation

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("hydrosolutions/riversCentralAsia")
```
Note that Windows users require RTools to install R packages from github. 

## Example

This is a basic example which shows you how to visualize some of the
included data.

``` r
library(riversCentralAsia)
library(tidyverse)
library(timetk)
## basic example code
#ChirchikRiverBasin  # load data
#ChirchikRiverBasin |> group_by(code) |> plot_time_series(date,data,
#                                                         .interactive = FALSE,
#                                                         .facet_ncol  = 2,
#                                                         .smooth      = FALSE)
```
