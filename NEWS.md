# riversCentralAsia (Development Version)

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
