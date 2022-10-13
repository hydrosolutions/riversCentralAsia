---
title: "Introduction to the package"
output: rmarkdown::html_vignette
bibliography: [references.bib, HMA_bibliography.bib]
vignette: >
  %\VignetteIndexEntry{Introduction to the package}
  %\VignetteEngine{knitr::knitr}
  %\VignetteEncoding{UTF-8}
---



This package aims at streamlining pre-and post-processing of various types of data for hydrological modelling in Central Asia. It is under continuous development. 

Several use-cases for the packages functionality are demonstrated in the CAHAM book [Modeling of Hydrological Systems in Semi-Arid Central Asia](https://hydrosolutions.github.io/caham_book/){target="_blank"}. 

## Installation

```r
# install.packages("devtools")
devtools::install_github("hydrosolutions/riversCentralAsia", 
                         quiet = TRUE)
#> 
#>   There is a binary version available but the source version is later:
#>    binary source needs_compilation
#> wk  0.6.0  0.7.0              TRUE
library(riversCentralAsia, quietly = TRUE)
```

Note for windows users: the installation from github requires [RTools](https://cran.r-project.org/bin/windows/Rtools/){target="_blank"}.  

## Data
The package includes an example data set with discharge time series as well as temperature and precipitation time series from the runoff formation zone of the Chirchiq river basin. 

```r
library(riversCentralAsia, quietly = TRUE)
library(tidyverse, quietly = TRUE)
library(timetk, quietly = TRUE)
ChirchikRiverBasin  # load data
#> # A tibble: 29,892 × 14
#>    date        data  norm units type  code  station  river basin resol…¹ lon_U…²
#>    <date>     <dbl> <dbl> <chr> <fct> <chr> <chr>    <chr> <chr> <fct>     <dbl>
#>  1 1932-01-10  48.8  38.8 m3s   Q     16279 Khudayd… Chat… Chir… dec      598278
#>  2 1932-01-20  48.4  37.5 m3s   Q     16279 Khudayd… Chat… Chir… dec      598278
#>  3 1932-01-31  42.4  36.6 m3s   Q     16279 Khudayd… Chat… Chir… dec      598278
#>  4 1932-02-10  43.7  36.4 m3s   Q     16279 Khudayd… Chat… Chir… dec      598278
#>  5 1932-02-20  44.2  36.3 m3s   Q     16279 Khudayd… Chat… Chir… dec      598278
#>  6 1932-02-29  47.7  36.9 m3s   Q     16279 Khudayd… Chat… Chir… dec      598278
#>  7 1932-03-10  54.1  39.4 m3s   Q     16279 Khudayd… Chat… Chir… dec      598278
#>  8 1932-03-20  63.2  47.6 m3s   Q     16279 Khudayd… Chat… Chir… dec      598278
#>  9 1932-03-31 103    60.5 m3s   Q     16279 Khudayd… Chat… Chir… dec      598278
#> 10 1932-04-10 103    86.4 m3s   Q     16279 Khudayd… Chat… Chir… dec      598278
#> # … with 29,882 more rows, 3 more variables: lat_UTM42 <dbl>,
#> #   altitude_masl <dbl>, basinSize_sqkm <dbl>, and abbreviated variable names
#> #   ¹​resolution, ²​lon_UTM42
ChirchikRiverBasin |> 
  filter(type == "Q", 
         code %in% c("16279", "16290", "16298", "16300")) |> 
  group_by(code, station, river) |> 
  drop_na() |> 
  plot_time_series(
    date, data,
    .interactive = TRUE,
    .facet_ncol  = 2, 
    .facet_collapse = TRUE, .facet_collapse_sep = " - ", 
    .smooth      = FALSE, 
    .y_lab = "Q [m3/s]")
```

<img src="figure/unnamed-chunk-3-1.png" alt="plot of chunk unnamed-chunk-3" width="100%" />

## Tools
The package `riversCentralAsia` includes a variety of functions to facilitate data pre- and post-processing for hydrological and hydraulic modelling with RS Minerve in Central Asia.    
  
[RS Minerve](https://crealp.ch/rs-minerve/){target="_blank"} is a free hydrological and hydraulic modelling software developed in Switzerland by CREALP and partners. 

In summary, the functions can be grouped into:   
* Reading and writing of input and output files of RS Minerve    
* Pre- and post-processing of data for hydrolgical modelling with RS Minerve  
* Glacier modelling tools  
* Various helper tools for analysing and plotting hydrological data 

## Acknowledgements
This packages builds on previous work of R, RStudio and RS Minerve developers. It further relies on free data made available by publicly funded research. Open source R methods books and public forums inspired and supported the writing of the package.       









