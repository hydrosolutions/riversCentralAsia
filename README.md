
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

We now have a
[web-site](https://hydrosolutions.github.io/riversCentralAsia/index.html)
for the package where you can find vignettes on how to use the
functions. Please note that the web-site is work in progress and
continuously being updated.

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

    #> -- Attaching packages --------------------------------------- tidyverse 1.3.1 --
    #> v ggplot2 3.3.5     v purrr   0.3.4
    #> v tibble  3.1.2     v dplyr   1.0.7
    #> v tidyr   1.1.3     v stringr 1.4.0
    #> v readr   1.4.0     v forcats 0.5.1
    #> -- Conflicts ------------------------------------------ tidyverse_conflicts() --
    #> x dplyr::filter() masks stats::filter()
    #> x dplyr::lag()    masks stats::lag()
    #> Registered S3 method overwritten by 'tune':
    #>   method                   from   
    #>   required_pkgs.model_spec parsnip
