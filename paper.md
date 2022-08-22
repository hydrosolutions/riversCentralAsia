---
title: 'riversCentralAsia: An R package for hydrological modelling'
tags:
- R
- hydrology
- modelling
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

The R package riversCentralAsia includes a set of tools to facilitate and automate data preparation for hydrological modelling. It thus contributes to more reproducible modeling workflows and makes hydrological modeling more accessible to students.

The package has been developed within the frame of a master level course on applied hydrological modelling in Central Asia and is extensively used in the open-source book Modeling of Hydrological Systems in Semi-Arid Central Asia [@CAHAM:2022]. The workflows are further validated within the Horizon 2020 project HYDRO4U [@Hydro4u:2022].

While the package has been developed for the Central Asia region, most of the functions are generic and can be used for modelling projects anywhere in the world.

## Statement of need

Data preparation comes before hydrological modelling and is actually one of the biggest work chunks in the modelling process. This package includes a number of helper functions that can be connected to efficient workflows that automatize the data preparation process for hydrological modelling. The functionality includes:

- Efficient processing of present and future climate forcing, including hydro-meterological data from Central Asia and down-scaling of ERA5 re-analysis data

- The preparation of GIS layers for automated model generation

- Simplified modelling of glacier dynamics

- Post-processing of simulation results, e.g. computation of flow duration curves

- I/O interface with the hydrologic-hydraulic modelling software RS Minerve [@rsm:2021] which can be accessed within R using the package RSMinerveR [@RSMinerveR:2022].

While here, we focus on the description of the individual functions, the strengths of the package comes to play mostly when the functions are connected to automatize the data preparation process. These workflows are extensively documented in the book Modeling of Hydrological Systems in Semi-Arid Central Asia [@CAHAM:2022].


Currently, a relatively complete dataset of the Chirchik River Basin with decadal and monthly data on discharge, precipitation and temperature is included.


## Related packages
The R package RSMinverveR [@RSMinerveR:2022] allows the running of the hydrologic-hydraulic modelling software RS Minerve [@rsm:2021] directly from R without using the RS Minerve user interface. This functionality is for advanced R and RS Minerve users that wish to further speed up their modelling workflow.

There are a number of existing R packages available that support data preparation and  hydrological modelling [@slater_using_2019]. However, there is no R package to facilitate hydrological modelling specifically with RS Minerve which is a powerful, accessible tool for water resources management in mountainous regions.  

## Installation

You can install the development version from [GitHub](https://github.com/){target="_blank"} with:

```# install.packages("devtools")```  
```devtools::install_github("hydrosolutions/riversCentralAsia")```   
```library(riversCentralAsia)```  

Note that windows users require a working installation of RTools [@RTools:2022] to install packages from github.


## Mentions
The package is used extensively in the course book Modeling of Hydrological Systems in Semi-Arid Central Asia [@CAHAM:2022].

The workflows presented in the course book, using the riversCentralAsia package, are further validated within the Horizon 2020 project HYDRO4U [@Hydro4u:2022] where future small hydro power potential is evaluated using hydrological modelling.

For R & RS Minerve users, the package RSMinverveR [@RSMinerveR:2022] is recommended which allows the interfacing between R and RS Minerve (with examples based on the Visual Basic Script examples by CREALP).

## Acknowledgement
The preparation of the course book and thus the preparation of the package was financially supported by the Swiss Agency for Development and Cooperation, the German Kazakh University in Almaty and hydrosolutions.


## References

