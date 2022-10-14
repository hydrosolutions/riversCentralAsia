## riversCentralAsia 1.1.0 

cleaning up of the package functions and documentation
- release

## riversCentralAsia 0.4.1. 

Added import function of iEasyHydro .csv files

- import_iEasyHydro_data()

## riversCentralAsia 0.4 

with numerous additions and improvements. The following new functions are available:

- computeDiurnalTemperatureCycle()
- generateHourlyFromDaily_PT()


## riversCentralAsia 0.3 

with several new functions that facilitate a) ERA5 data handling, bias correction, donwscaling, etc., b) prepare data for the stochastic weather generator RMAWGEN and c) handle importing and exporting files to the hydrological-hydraulic RS MINERVE model.

- function biasCorrect_ERA5_CHELSA()
- function climateScenarioPreparation_RMAWGEN()
- function downscale_ClimPred_monthly_BasinElBands()
- function generate_ERA5_Subbasin_CSV()
- function load_minerve_input_csv
- function posixct2rsminerveCHar()
- function prepare_RMAWGEN_input_data()


## riversCentralAsia 0.2.2

- Refined decadeMaker.R to accommodate non-full year data ranges

## riversCentralAsia 0.2

Release 0.2 include various improvements.

- No more pracma package dependencies in functions.
- Removed factors from loadTabularData so as to allow for the loading of any station data.
- Added monthly station data of precipitation of Oygaing station.

## riversCentralAsia 0.1.3

- Now, the station code is a factor.

- Added gauging station locations and corresponding contributing catchment sizes to the pre-packaged Chirchik river data.

## riversCentralAsia 0.1.2

-   Package extension to also load meteorological data, including precipitation `P` and temperature `T`, apart from the discharge data `Q`. Fort this , the function `loadTabularData` got a new argument `dataType` which can take now one of the following values: `{Q,P,T}`.

-   Added a `unit` column that stores units of the data loaded in `char` format which the user can specify, e.g.

    -   'degC' for temperature in degrees Celsius,

    -   'mm' for cumulative precipitation over the interval period, i.e. 10-days (decadal) or monthly, and

    -   'm3s' for average discharge over the interval period.

## riversCentralAsia 0.1.1

### Improvements

-   Adding optional name of river to `loadTabularData` function. Returns an additional tibble column with the corresponding river name.

-   Making sample discharge data available of Chirchik River where data from the gauging stations 16279 (Chatkal River, Khudaydod), 16290 (Pskem River, Mullala), 16298 (Nauvalisoy River, Sidzhak) and 16294 (Inflow Charvak) is included. In the future, more data from other river basins will be included.

### Fixes

## riversCentralAsia 0.1.0

Initial Release
