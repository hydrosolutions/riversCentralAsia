---
title: 'riversCentralAsia: An R package for hydrological modelling'
tags:
  - R
  - hydrology
  - modelling
  - Central Asia
authors:
  - name: Beatrice Marti
    orcid: 0000-0003-2089-3478
    equal-contrib: true
    affiliation: 1 # (Multiple affiliations must be quoted)
  - name: Tobias Siegfried
    ocrid: 0000-0002-2995-9253
    equal-contrib: true # (This is how you can denote equal contributions between multiple authors)
    affiliation: 1
affiliations:
 - name: hydrosolutions GmbH, Zurich, Switzerland
   index: 1
date: 3 August 2022
bibliography: paper.bib

# Optional fields if submitting to a AAS journal too, see this blog post:
# https://blog.joss.theoj.org/2018/12/a-new-collaboration-with-aas-publishing
#aas-doi: 10.3847/xxxxx <- update this with the DOI from AAS once you know it.
#aas-journal: Astrophysical Journal <- The name of the AAS journal.
---

# Summary

The R package riversCentralAsia includes a set of tools to facilitate and automate data preparation for hydrological modelling. It thus contributes to more reproducible modeling workflows and makes hydrological modeling more accessible to students. 

The package has been developed within the frame of a master level course on applied hydrological modelling in Central Asia and is extensively used in the open-source book [Modeling of Hydrological Systems in Semi-Arid Central Asia](https://hydrosolutions.github.io/caham_book/)[@CAHAM:2022]. The workflows are further validated within the Horizon 2020 project [HYDRO4U](https://hydro4u.eu/). 

While the package has been developed for the Central Asia region, most of the functions are generic and can be used for modelling projects anywhere in the world. 


# Statement of need

Data preparation comes before hydrological modelling and is actually one of the biggest work chunks in the modelling process. This package includes a number of helper functions that can be connected to efficient workflows that automatize the data preparation process for hydrological modelling. The functionality includes: 

- Efficient processing of present and future climate forcing

- The preparation of GIS layers for automated model generation

- Simplified modelling of glacier dynamics

- Post-processing of simulation results, e.g. computation of flow duration curves

- I/O interface with the hydrologic-hydraulic modelling software [RS Minerve](https://crealp.ch/rs-minerve/) which can be accessed within R using the package [RSMinerveR](https://github.com/hydrosolutions/RSMinerveR).  

While here, we focus on the description of the individual functions, the strengths of the package comes to play mostly when the functions are connected to automatize the data preparation process. These workflows are extensively documented in the book [Modeling of Hydrological Systems in Semi-Arid Central Asia](https://hydrosolutions.github.io/caham_book/). 


# Acknowledgements

We acknowledge funding from the Swiss Agency for Development and Cooperation and from the Horizon 2020 project Hydro4U. Further, we would like to acknowledge the wealth of open-source software and open research data which form the basis for the development of this package. Last but not least we acknowledge the constructive feedback from the students of the master course in Integrated Water Resources Management at the German-Kazakh University in Almaty (2021 & 2022) and the participants of the training-for-teachers program (2022) who enthusiastically tested the package in their assignments. 

# References
