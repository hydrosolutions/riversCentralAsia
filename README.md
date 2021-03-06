
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
temperature is included. Continue reading
[here](doc/data_documentation.Rmd) for a more detailed description of
the available data. More data will be made available in upcoming
iterations of the package

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.4667422.svg)](https://doi.org/10.5281/zenodo.4667422)

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

## Example

This is a basic example which shows you how to visualize some of the
included data.

``` r
library(riversCentralAsia)
library(tidyverse)
#> ── Attaching packages ─────────────────────────────────────── tidyverse 1.3.0 ──
#> ✓ ggplot2 3.3.3     ✓ purrr   0.3.4
#> ✓ tibble  3.1.0     ✓ dplyr   1.0.5
#> ✓ tidyr   1.1.3     ✓ stringr 1.4.0
#> ✓ readr   1.4.0     ✓ forcats 0.5.1
#> ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
#> x dplyr::filter() masks stats::filter()
#> x dplyr::lag()    masks stats::lag()
library(timetk)
## basic example code
ChirchikRiverBasin # load data
#> # A tibble: 29,892 x 14
#>    date        data  norm units type  code  station   river   basin   resolution
#>    <date>     <dbl> <dbl> <chr> <fct> <chr> <chr>     <chr>   <chr>   <fct>     
#>  1 1932-01-10  48.8  38.8 m3s   Q     16279 Khudaydod Chatkal Chirch… dec       
#>  2 1932-01-20  48.4  37.5 m3s   Q     16279 Khudaydod Chatkal Chirch… dec       
#>  3 1932-01-31  42.4  36.6 m3s   Q     16279 Khudaydod Chatkal Chirch… dec       
#>  4 1932-02-10  43.7  36.4 m3s   Q     16279 Khudaydod Chatkal Chirch… dec       
#>  5 1932-02-20  44.2  36.3 m3s   Q     16279 Khudaydod Chatkal Chirch… dec       
#>  6 1932-02-29  47.7  36.9 m3s   Q     16279 Khudaydod Chatkal Chirch… dec       
#>  7 1932-03-10  54.1  39.4 m3s   Q     16279 Khudaydod Chatkal Chirch… dec       
#>  8 1932-03-20  63.2  47.6 m3s   Q     16279 Khudaydod Chatkal Chirch… dec       
#>  9 1932-03-31 103    60.5 m3s   Q     16279 Khudaydod Chatkal Chirch… dec       
#> 10 1932-04-10 103    86.4 m3s   Q     16279 Khudaydod Chatkal Chirch… dec       
#> # … with 29,882 more rows, and 4 more variables: lon_UTM42 <dbl>,
#> #   lat_UTM42 <dbl>, altitude_masl <dbl>, basinSize_sqkm <dbl>
ChirchikRiverBasin %>% group_by(code) %>% plot_time_series(date,data,
                                                           .interactive = FALSE,
                                                           .facet_ncol  = 2,
                                                           .smooth      = FALSE)
#> Warning: Removed 3 row(s) containing missing values (geom_path).
```

<img src="man/figures/README-example-1.png" width="100%" />
