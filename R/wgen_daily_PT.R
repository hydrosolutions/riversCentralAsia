#' Compute stochastic daily weather time series using RMAWGEN and a climate scenario
#'
#' Wraper function to compute daily weather variables (precipitation, minimum and maximum temperatures) based on a climate scenario
#'
#' @param param List with RMAWGEN parameters (see ?RMAWGEN::RMAWGEN for mroe infomation)
#' @param station_data List with key station statistics, including STATION_NAMES, ELEVATION, STATION_LATLONG, LOCATION, PRECIPITATION, TEMPERATURE_MIN and TEMPERATURE_MAX. This is output of the function prepare_RMAWGEN_input_data()
#' @param station_subset Optional subset of station names that should be modeled. If NULL, the entire set as given by station_data$STATION_NAMES will be used.
#' @param climScen Optional climate scenario that conditions the generation of future stochastic weather variables on norm climate (output from GMCs) for the individual stations. If NULL, the simulated period will cover the observation periuod.
#' @param returnVAR Return the var models? If this option is set to FALSE, the P_gen and T_gen files become more manageable.
#' @return Stochastic multi-site weather generator RMAWGEN precipitation and temperature models.
#' @export
wgen_daily_PT <- function(param, station_data, station_subset, clim_scen,returnVAR){

  if (base::is.null(clim_scen)){
    prec_norm = NULL
    tasmin_norm = NULL
    tasmax_norm = NULL
    year_min_sim = param$year_min
    year_max_sim = param$year_max

  } else {
    prec_norm = clim_scen$prec_norm
    tasmin_norm = clim_scen$tasmin_norm
    tasmax_norm = clim_scen$tasmax_norm
    year_min_sim = clim_scen$year_min
    year_max_sim = clim_scen$year_max
  }

  if (base::is.null(station_subset)){
    station = param$station
  } else {
    station = station_subset
  }

  # Set random generator seed
  base::set.seed(param$seed)

  # A. Precipitation Generator
  exogen <- NULL
  exogen_sim <- exogen

  P_gen <-
    RMAWGEN::ComprehensivePrecipitationGenerator(station = station,
                                        prec_all = station_data$PRECIPITATION,
                                        year_min = param$year_min,
                                        year_max = param$year_max,
                                        year_min_sim = year_min_sim,
                                        year_max_sim = year_max_sim,
                                        exogen = exogen,
                                        exogen_sim = exogen_sim,
                                        p = param$p,
                                        n_GPCA_iteration = param$n_GPCA_iter_prec,
                                        n_GPCA_iteration_residuals = param$n_GPCA_iteration_residuals_prec,
                                        mean_climate_prec_sim = prec_norm[,station],
                                        sample = "monthly",
                                        valmin = param$valmin,
                                        extremes = TRUE,
                                        nscenario = param$nscenario
    )

  # Use of measured and observed temperature as exogenous variables
  exogen_sim <- P_gen$prec_gen
  exogen <- P_gen$prec_mes

  # B. Generation of temperature max and min
  T_gen <-
    RMAWGEN::ComprehensiveTemperatureGenerator(station = station,
                                      Tx_all = station_data$TEMPERATURE_MAX,
                                      Tn_all = station_data$TEMPERATURE_MIN,
                                      year_min = param$year_min,
                                      year_max = param$year_max,
                                      exogen = exogen,
                                      exogen_sim = exogen_sim,
                                      year_min_sim = year_min_sim,
                                      year_max_sim = year_max_sim,
                                      p = param$p,
                                      n_GPCA_iteration = param$n_GPCA_iter,
                                      n_GPCA_iteration_residuals = param$n_GPCA_iteration_residuals,
                                      mean_climate_Tn_sim = tasmin_norm[,station],
                                      mean_climate_Tx_sim = tasmax_norm[,station],
                                      sample = "monthly",
                                      nscenario = param$nscenario
    )


  # Prepare output by minimizing output size
  if (returnVAR==FALSE){
    # Precipitation
    P_gen$var = NULL
    P_gen$prec_spline = NULL
    P_gen$prec_spline_sim = NULL
    P_gen$data_prec = NULL
    # Temperature
    T_gen$var = NULL
    T_gen$input = NULL
    T_gen$temporary = NULL
    T_gen$output$Tx_spline = NULL
    T_gen$output$Tn_spline = NULL
  }

  results2return <- list(P_gen = P_gen,T_gen = T_gen,
                         year_min = param$year_min, year_max = param$year_max,
                         year_min_sim = year_min_sim, year_max_sim = year_max_sim)

  return(results2return)
}
