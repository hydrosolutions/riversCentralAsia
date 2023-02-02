---
title: 'riversCentralAsia: An R package to support data pre- and postprocessing for hydrological modelling with RS MINERVE'
tags:
- R
- hydrology
- Central Asia
date: "3 August 2022"
output: pdf_document
authors:
- name: Beatrice Marti
  orcid: "0000-0003-2089-3478"
  equal-contrib: yes
  affiliation: 1
- name: Tobias Siegfried
  orcid: "0000-0002-2995-9253"
  equal-contrib: yes
  affiliation: 1
bibliography: paper.bib
affiliations:
- name: hydrosolutions GmbH, Zurich, Switzerland
  index: 1
---

<!-- README.md is generated from README.Rmd. Please edit that file -->


## Summary

The R package *riversCentralAsia* includes a set of tools to facilitate and automate data preparation for hydrological modelling. It thus contributes to more reproducible modelling workflows and makes hydrological modelling more accessible to students and to interested professional modellers. 

The package has been developed within the frame of a master level course on applied hydrological modelling in Central Asia [@marti_comprehensive_2023] and is extensively used in the open-source book "Modelling of Hydrological Systems in Semi-Arid Central Asia" [@CAHAM:2022]. The workflows are further validated within the Horizon 2020 project HYDRO4U [@Hydro4u:2022].

While the package has been developed for the Central Asia region, most of the functions are generic and can be used for modelling projects anywhere in the world.

The most important functionalities of the package as well as the data that can be processed with the package are described in the the articles of the [project documentation site](https://hydrosolutions.github.io/riversCentralAsia/){target="_blank"} but the examples in the course book ["Modelling of Hydrological Systems in Semi-Arid Central Asia"](https://hydrosolutions.github.io/caham_book/){target="_blank"} demonstrate the full range of functions available and how to use them in a workflow.

## Statement of need

Data preparation comes before hydrological modelling and is actually one of the biggest work chunks in the modelling process. This package includes a number of helper functions that can be connected to efficient workflows that automatize the data preparation process for hydrological modelling as shown in the figure below. The package thereby supports a more reproducible modelling workflow and improves the scalability of hydrological modelling. 

!["Overview over the modelling workflow whos R-components are supported by the riversCentralAsia package (Image source: Marti et al., 2022). Abbreviations are explained in the text. The workflow relies entirely on free, publicly available data and software."](./man/figures/fig_01_model_chain_bw.png){ width=80% }  

The data preparation step covered by the *riversCentralAsia* package includes the derivation of hydrological response units (HRU) using a basin outline and the [SRTM digital elevation model (DEM)](https://doi.org/10.5067/MEaSUREs/SRTM/SRTMGL1.003){target="_blank"} [@nasa_jpl_nasa_2013]. The [derivation of the basin outline](https://hydrosolutions.github.io/caham_book/geospatial_data.html#sec-catchment-delineation){target="_blank"} and [processing of geospatial layers for import to the hydrological modelling software RS MINERVE](https://hydrosolutions.github.io/caham_book/geospatial_data.html#sec-preparation-of-rsminerve-input-files){target="_blank"} [@rsm:2021] in QGIS [@qgis_development_team_qgis_2022] is described in detail in @CAHAM:2022.  

Although the High Mountain region of Central Asia is generally perceived as a data scarce region, a number of gridded data products are available that form a fair basis for regional hydrological modelling at seasonal time scales. [CHELSA v2.1](https://chelsa-climate.org/){target="_blank"} [@karger_climatologies_2017; @chelsa-climatologies-2021] is a weather data product at 1 km squared grid resolution. The *riversCentralAsia* package includes the function [*gen_HRU_Climate_CSV_RSMinerve*](https://hydrosolutions.github.io/riversCentralAsia/reference/gen_HRU_Climate_CSV_RSMinerve.html){target="_blank"} which extracts CHELSA precipitation or temperature data on the hydrological response units and returns the data in an RS MINERVE readable format.  

[Glacier thinning](https://www.nature.com/articles/s41586-021-03436-z){target="_blank"} and [glacier ablation](https://doi.org/10.1038/s41467-021-23073-4){target="_blank"} rates are data sets from the open-access literature which can be used to calibrate the [GSM model (a glacier runoff model) objects](https://crealp.github.io/rsminerve-releases/tech_hydrological_models.html#sec-model_gsm){target="_blank"} in RS MINERVE. Data on snow water equivalents is sourced from the [High Mountain Asia Snow Reanalysis (HMASR) Product](https://doi.org/10.5067/HNAUGJQXSCVU){target="_blank"} [@liu_spatiotemporal_2021; @liu_high_2021] and can be used to calibrate the snow module of the [HBV model (a rainfall-runoff model) objects](https://crealp.github.io/rsminerve-releases/tech_hydrological_models.html#sec-model_hbv) in RS MINERVE. The *riversCentralAsia* package site includes a [demonstration of how HMASR data can be used for model calibration](https://hydrosolutions.github.io/riversCentralAsia/articles/05-snow-calibration.html){target="_blank"}. The process is very similar for the calibration of glacier thinning and discharge.  

River discharge is taken from the hydrological year books of the Hydrometeorological Institutes in Central Asia. The package *riversCentralAsia* includes discharge time series from the Chirchiq river basin (located to the north-east of Tashkent (Uzbekistan)) as well as several functions for loading discharge data, aggregating and visualization of discharge data and discharge statistics (discharge characterization) (see the [documentation on the discharge functions](https://hydrosolutions.github.io/riversCentralAsia/articles/01-discharge-processing-examples.html){target="_blank"}).  
And last but not least, [CMIP6 climate model results are available from Copernicus](https://cds.climate.copernicus.eu/cdsapp#!/dataset/projections-cmip6?tab=form){target="_blank"}. The *riversCentralAsia* package can be used for [bias correction of climate projections](https://hydrosolutions.github.io/riversCentralAsia/reference/doQuantileMapping.html){target="_blank"} using CHELSA data and to produce RS MINERVE readable climate forcing. We use quantile mapping as statistical bias correction method [@gudmundsson_technical_2012; @qmap_package].    

Hydrological modelling is done using the free hydrologic-hydraulic modelling software
<a href="https://crealp.ch/rs-minerve/" target="_blank">RS MINERVE</a> (not included in this package) [@rsm:2021]. Some alternative geoprocessing workflows in [QGIS](https://www.qgis.org/en/site/){target="_blank"} are described in @CAHAM:2022. 

The *riversCentralAsia* package functionality includes:

-   Efficient processing of present and future weather forcing,
    including hydro-meterological data from Central Asia ([time series](https://hydrosolutions.github.io/riversCentralAsia/articles/01-discharge-processing-examples.html){target="_blank"} and re-analysis data) and
    down-scaling of climate projection data (a more advanced topic which
    is described in the [course book](https://hydrosolutions.github.io/caham_book/climate_data.html){target="_blank"})

-   The [preparation of GIS layers for automated model
    generation](https://hydrosolutions.github.io/riversCentralAsia/articles/02-preparation-of-climate-forcing.html){target="_blank"}

-   [Volume area scaling of glaciers](https://hydrosolutions.github.io/riversCentralAsia/articles/04-glacier-functions.html){target="_blank"}

-   Post-processing of simulation results, e.g. [extraction and visualisation of snow water
    equivalent](https://hydrosolutions.github.io/riversCentralAsia/articles/05-snow-calibration.html){target="_blank"} or [computation of flow duration curves](https://hydrosolutions.github.io/riversCentralAsia/reference/computeAnnualFlowDurationCurve.html){target="_blank"}

-   I/O interface with the hydrologic-hydraulic modelling software that allows reading and writing of input and output files of the hydraulic-hydrological modelling software <a href="https://crealp.ch/rs-minerve/" target="_blank">RS MINERVE</a>.

While here, we focus on the description of the individual functions, the
strengths of the package comes to play mostly when the functions are
connected to automatize the data preparation process. These workflows
are extensively documented in the book
<a href="https://hydrosolutions.github.io/caham_book/"
target="_blank">"Modelling of Hydrological Systems in Semi-Arid Central
Asia"</a>.

Currently, a relatively complete dataset of the Chirchik River Basin
with decadal and monthly data on discharge, precipitation and
temperature is included.


## Related packages
The hydraulic-hydrological modelling software RS MINERVE can be accessed through Common Language Runtime (CLR) directly from within R, thus the use of the RS MINERVE GUI can be avoided and multiple runs of large models can be speed up. The [GitHub repository RSMinerveR](https://github.com/hydrosolutions/RSMinerveR){target="_blank"} includes examples of how to use CLR commands to use the Visual Basic interface with RS MINERVE documented in the [technical manual](https://crealp.github.io/rsminerve-releases/tech_scripts.html){target="_blank} [@roquier_rs_2022]. This functionality is recommended for advanced users of RS MINERVE only. 

There are a number of existing R packages available that support data preparation and  hydrological modelling [@slater_using_2019]. However, apart from *riversCentralAsia*, there is no R package to facilitate hydrological modelling specifically with RS MINERVE which is a powerful, accessible tool for water resources management in mountainous regions.  

## Installation

The package requires R >= 4.1. It can be installed from the [GitHub repository](https://github.com/hydrosolutions/riversCentralAsia){target="_blank"} using 

```devtools::install_github("hydrosolutions/riversCentralAsia")```. 

The package has many dependencies which will be installed alongside
*riversCentralAsia*. To successfully install the package you need prior
installations of the following packages: rlang, magrittr, stringr and
purrr. Windows users further need a working installation of RTools [@RTools:2022]. 

## Mentions
The package is used extensively in the course book modelling of Hydrological Systems in Semi-Arid Central Asia [@CAHAM:2022]. The course book is published jointly with free lecture material and student case studies and can be used as basis for a master-level course on hydrological modelling [@marti_comprehensive_2023].    

The workflows presented in the course book, using the *riversCentralAsia* package, are further validated within the Horizon 2020 project HYDRO4U [@Hydro4u:2022] where future small hydro power potential is evaluated using hydrological modelling.

For advanced R & RS Minerve users, the vignettes in the repository *RSMinverveR* [@RSMinerveR:2022] is recommended which allows the interfacing between R and RS MINERVE (with examples based on the Visual Basic Script examples by CREALP).

## Acknowledgement
The preparation of the course book and thus the preparation of the package was financially supported by the Swiss Agency for Development and Cooperation, the German Kazakh University in Almaty and hydrosolutions. 


## References
