riversCentralAsia: An R package for hydrological modelling
================
3 August 2022

<!-- README.md is generated from README.Rmd. Please edit that file -->

# riversCentralAsia

## Summary

The R package riversCentralAsia includes a set of tools to facilitate
and automate data preparation for hydrological modelling. It thus
contributes to more reproducible modeling workflows and makes
hydrological modeling more accessible to students.

The package has been developed within the frame of a master level course
on applied hydrological modelling in Central Asia and is extensively
used in the open-source book [Modeling of Hydrological Systems in
Semi-Arid Central
Asia](https://hydrosolutions.github.io/caham_book/)(Siegfried and Marti
2022). The workflows are further validated within the Horizon 2020
project [HYDRO4U](https://hydro4u.eu/).

While the package has been developed for the Central Asia region, most
of the functions are generic and can be used for modelling projects
anywhere in the world.

## Statement of need

Data preparation comes before hydrological modelling and is actually one
of the biggest work chunks in the modelling process. This package
includes a number of helper functions that can be connected to efficient
workflows that automatize the data preparation process for hydrological
modelling. The functionality includes:

-   Efficient processing of present and future climate forcing,
    including hydro-meterological data from Central Asia and
    down-scaling of ERA5 re-analysis data

-   The preparation of GIS layers for automated model generation

-   Simplified modelling of glacier dynamics

-   Post-processing of simulation results, e.g. computation of flow
    duration curves

-   I/O interface with the hydrologic-hydraulic modelling software [RS
    Minerve](https://crealp.ch/rs-minerve/) which can be accessed within
    R using the package
    [RSMinerveR](https://github.com/hydrosolutions/RSMinerveR).

While here, we focus on the description of the individual functions, the
strengths of the package comes to play mostly when the functions are
connected to automatize the data preparation process. These workflows
are extensively documented in the book [Modeling of Hydrological Systems
in Semi-Arid Central
Asia](https://hydrosolutions.github.io/caham_book/).

Currently, a relatively complete dataset of the Chirchik River Basin
with decadal and monthly data on discharge, precipitation and
temperature is included.

## Related packages

The R package
[RSMinverveR](https://github.com/hydrosolutions/RSMinerveR) allows the
running of the hydrologic-hydraulic modelling software [RS
Minerve](https://crealp.ch/rs-minerve/) directly from R without using
the RS Minerve user interface. This functionality is for advanced R and
RS Minerve users that wish to further speed up their modelling workflow.

## Installation

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("hydrosolutions/riversCentralAsia")
#> Skipping install of 'riversCentralAsia' from a github remote, the SHA1 (26b5949c) has not changed since last install.
#>   Use `force = TRUE` to force installation
library(riversCentralAsia)
```

Note that windows users require a working installation of
[RTools](https://cran.r-project.org/bin/windows/Rtools/).

## Community guidelines

Please consult the documentation and the examples provided in the
[package
documentation](https://hydrosolutions.github.io/riversCentralAsia/index.html)
and in the open-source course book [Modeling of Hydrological Systems in
Semi-Arid Central Asia](https://hydrosolutions.github.io/caham_book/).

For problems using the functions of for suggestions, please use the
[issue
tool](https://github.com/hydrosolutions/riversCentralAsia/issues).

## How to cite

Please cite the package as:

Tobias Siegfried, & Beatrice Marti (2021): riversCentralAsia
<version number>. <https://doi.org/10.5281/zenodo.4667422>

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.4667422.svg)](https://doi.org/10.5281/zenodo.4667422)

## Examples

This is a basic example which shows you how to visualize some of the
included data.

``` r
library(riversCentralAsia)
library(tidyverse)
library(timetk)

# Loading and visualising discharge data
ChirchikRiverBasin  # load data
ChirchikRiverBasin |> 
  # Filter for the data type, here discharge "Q"
  dplyr::filter(type == "Q") |> 
  drop_na() |> 
  group_by(river) |> 
  plot_time_series(
    date,
    data,
    .interactive = FALSE,
    .facet_ncol = 2,
    .smooth = FALSE, 
    .y_lab = "Discharge [m3/s]", 
    .x_lab = "Year", 
    .title = "Discharge time series in the ChirchikRiverBasin data set"
    )
```

## References

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-CAHAM:2022" class="csl-entry">

Siegfried, Tobias, and Beatrice Marti. 2022. *Modeling of Hydrological
Systems in Semi-Arid Central Asia*. hydrosolutions.
https://doi.org/<https://doi.org/10.5281/zenodo.6350042>.

</div>

</div>
