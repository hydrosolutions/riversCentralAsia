#' Climate Scenario Preparations
#'
#' Climate scenarios output from function `downscale_ClimPred_monthly_BasinElBands()` is prepared for the stochastic weather generator RMAWGEN.
#'
#' @param pathN Path to climate scenario files that are downscaled on catchment-subbasin elevation bands
#' @param fileN File name where climate projections are stored (.rda file)
#' @param param RMAWGEN parameters stored as list with param$year_min_sim_Period1, param$year_max_sim_Period1, param$year_min_sim_Period2 and param$year_max_sim_Period2 specified.
#' @return List of 12 climate scenarios, i.e. RCP45 and RCP85, climate models ACCESS1_3, CMCC-CM and MIROC5, two periods of interest (2051-2060 and 2091-2100). Scenario name, monthly precipitation (prec), minimum (tasmin) and maximum (tasmax) temperatures, year_min and year_max are stored in scenario list entires.
#' @family Pre-processing
#' @export
climateScenarioPreparation_RMAWGEN <- function(pathN,fileN,param){

  load(file=paste0(pathN,fileN,'.rda')) # loads all available climate scenarios for a basin

  # 1. Generate scenario files

  # Precipitation (pr) projections
  ## MIROC5 Model
  prec_RCP45_MIROC5_Period1 <- downscaled_ClimPred_rcp45_MIROC5$pr %>%
    filter(year>=param$year_min_sim_Period1 & year<= param$year_max_sim_Period1) %>%
    dplyr::select(-c('month','day','year')) %>% as.matrix()
  prec_RCP85_MIROC5_Period1 <- downscaled_ClimPred_rcp85_MIROC5$pr %>%
    filter(year>=param$year_min_sim_Period1 & year<= param$year_max_sim_Period1) %>%
    dplyr::select(-c('month','day','year')) %>% as.matrix()
  prec_RCP45_MIROC5_Period2 <- downscaled_ClimPred_rcp45_MIROC5$pr %>%
    filter(year>=param$year_min_sim_Period2 & year<= param$year_max_sim_Period2) %>%
    dplyr::select(-c('month','day','year')) %>% as.matrix()
  prec_RCP85_MIROC5_Period2 <- downscaled_ClimPred_rcp85_MIROC5$pr %>%
    filter(year>=param$year_min_sim_Period2 & year<= param$year_max_sim_Period2) %>%
    dplyr::select(-c('month','day','year')) %>% as.matrix()
  ## ACCESS1_3 Model
  prec_RCP45_ACCESS1_3_Period1 <- downscaled_ClimPred_rcp45_ACCESS1_3$pr %>%
    filter(year>=param$year_min_sim_Period1 & year<= param$year_max_sim_Period1) %>%
    dplyr::select(-c('month','day','year')) %>% as.matrix()
  prec_RCP85_ACCESS1_3_Period1 <- downscaled_ClimPred_rcp85_ACCESS1_3$pr %>%
    filter(year>=param$year_min_sim_Period1 & year<= param$year_max_sim_Period1) %>%
    dplyr::select(-c('month','day','year')) %>% as.matrix()
  prec_RCP45_ACCESS1_3_Period2 <- downscaled_ClimPred_rcp45_ACCESS1_3$pr %>%
    filter(year>=param$year_min_sim_Period2 & year<= param$year_max_sim_Period2) %>%
    dplyr::select(-c('month','day','year')) %>% as.matrix()
  prec_RCP85_ACCESS1_3_Period2 <- downscaled_ClimPred_rcp85_ACCESS1_3$pr %>%
    filter(year>=param$year_min_sim_Period2 & year<= param$year_max_sim_Period2) %>%
    dplyr::select(-c('month','day','year')) %>% as.matrix()
  ## CMCC_CM
  prec_RCP45_CMCC_CM_Period1 <- downscaled_ClimPred_rcp45_CMCC_CM$pr %>%
    filter(year>=param$year_min_sim_Period1 & year<= param$year_max_sim_Period1) %>%
    dplyr::select(-c('month','day','year')) %>% as.matrix()
  prec_RCP85_CMCC_CM_Period1 <- downscaled_ClimPred_rcp85_CMCC_CM$pr %>%
    filter(year>=param$year_min_sim_Period1 & year<= param$year_max_sim_Period1) %>%
    dplyr::select(-c('month','day','year')) %>% as.matrix()
  prec_RCP45_CMCC_CM_Period2 <- downscaled_ClimPred_rcp45_CMCC_CM$pr %>%
    filter(year>=param$year_min_sim_Period2 & year<= param$year_max_sim_Period2) %>%
    dplyr::select(-c('month','day','year')) %>% as.matrix()
  prec_RCP85_CMCC_CM_Period2 <- downscaled_ClimPred_rcp85_CMCC_CM$pr %>%
    filter(year>=param$year_min_sim_Period2 & year<= param$year_max_sim_Period2) %>%
    dplyr::select(-c('month','day','year')) %>% as.matrix()

  # Mean minimum temperature (tasmin) projections
  ## MIROC5
  tasmin_RCP45_MIROC5_Period1 <- downscaled_ClimPred_rcp45_MIROC5$tasmin %>%
    filter(year>=param$year_min_sim_Period1 & year<= param$year_max_sim_Period1) %>%
    dplyr::select(-c('month','day','year')) %>% as.matrix()
  tasmin_RCP85_MIROC5_Period1 <- downscaled_ClimPred_rcp85_MIROC5$tasmin %>%
    filter(year>=param$year_min_sim_Period1 & year<= param$year_max_sim_Period1) %>%
    dplyr::select(-c('month','day','year')) %>% as.matrix()
  tasmin_RCP45_MIROC5_Period2 <- downscaled_ClimPred_rcp45_MIROC5$tasmin %>%
    filter(year>=param$year_min_sim_Period2 & year<= param$year_max_sim_Period2) %>%
    dplyr::select(-c('month','day','year')) %>% as.matrix()
  tasmin_RCP85_MIROC5_Period2 <- downscaled_ClimPred_rcp85_MIROC5$tasmin %>%
    filter(year>=param$year_min_sim_Period2 & year<= param$year_max_sim_Period2) %>%
    dplyr::select(-c('month','day','year')) %>% as.matrix()
  ## ACCESS1_3
  tasmin_RCP45_ACCESS1_3_Period1 <- downscaled_ClimPred_rcp45_ACCESS1_3$tasmin %>%
    filter(year>=param$year_min_sim_Period1 & year<= param$year_max_sim_Period1) %>%
    dplyr::select(-c('month','day','year')) %>% as.matrix()
  tasmin_RCP85_ACCESS1_3_Period1 <- downscaled_ClimPred_rcp85_ACCESS1_3$tasmin %>%
    filter(year>=param$year_min_sim_Period1 & year<= param$year_max_sim_Period1) %>%
    dplyr::select(-c('month','day','year')) %>% as.matrix()
  tasmin_RCP45_ACCESS1_3_Period2 <- downscaled_ClimPred_rcp45_ACCESS1_3$tasmin %>%
    filter(year>=param$year_min_sim_Period2 & year<= param$year_max_sim_Period2) %>%
    dplyr::select(-c('month','day','year')) %>% as.matrix()
  tasmin_RCP85_ACCESS1_3_Period2 <- downscaled_ClimPred_rcp85_ACCESS1_3$tasmin %>%
    filter(year>=param$year_min_sim_Period2 & year<= param$year_max_sim_Period2) %>%
    dplyr::select(-c('month','day','year')) %>% as.matrix()
  ## CMCC_CM
  tasmin_RCP45_CMCC_CM_Period1 <- downscaled_ClimPred_rcp45_CMCC_CM$tasmin %>%
    filter(year>=param$year_min_sim_Period1 & year<= param$year_max_sim_Period1) %>%
    dplyr::select(-c('month','day','year')) %>% as.matrix()
  tasmin_RCP85_CMCC_CM_Period1 <- downscaled_ClimPred_rcp85_CMCC_CM$tasmin %>%
    filter(year>=param$year_min_sim_Period1 & year<= param$year_max_sim_Period1) %>%
    dplyr::select(-c('month','day','year')) %>% as.matrix()
  tasmin_RCP45_CMCC_CM_Period2 <- downscaled_ClimPred_rcp45_CMCC_CM$tasmin %>%
    filter(year>=param$year_min_sim_Period2 & year<= param$year_max_sim_Period2) %>%
    dplyr::select(-c('month','day','year')) %>% as.matrix()
  tasmin_RCP85_CMCC_CM_Period2 <- downscaled_ClimPred_rcp85_CMCC_CM$tasmin %>%
    filter(year>=param$year_min_sim_Period2 & year<= param$year_max_sim_Period2) %>%
    dplyr::select(-c('month','day','year')) %>% as.matrix()

  # Mean maximum temperature (tasmax) projections
  ## MIROC5
  tasmax_RCP45_MIROC5_Period1 <- downscaled_ClimPred_rcp45_MIROC5$tasmax %>%
    filter(year>=param$year_min_sim_Period1 & year<= param$year_max_sim_Period1) %>%
    dplyr::select(-c('month','day','year')) %>% as.matrix()
  tasmax_RCP85_MIROC5_Period1 <- downscaled_ClimPred_rcp85_MIROC5$tasmax %>%
    filter(year>=param$year_min_sim_Period1 & year<= param$year_max_sim_Period1) %>%
    dplyr::select(-c('month','day','year')) %>% as.matrix()
  tasmax_RCP45_MIROC5_Period2 <- downscaled_ClimPred_rcp45_MIROC5$tasmax %>%
    filter(year>=param$year_min_sim_Period2 & year<= param$year_max_sim_Period2) %>%
    dplyr::select(-c('month','day','year')) %>% as.matrix()
  tasmax_RCP85_MIROC5_Period2 <- downscaled_ClimPred_rcp85_MIROC5$tasmax %>%
    filter(year>=param$year_min_sim_Period2 & year<= param$year_max_sim_Period2) %>%
    dplyr::select(-c('month','day','year')) %>% as.matrix()
  ## ACCESS1_3
  tasmax_RCP45_ACCESS1_3_Period1 <- downscaled_ClimPred_rcp45_ACCESS1_3$tasmax %>%
    filter(year>=param$year_min_sim_Period1 & year<= param$year_max_sim_Period1) %>%
    dplyr::select(-c('month','day','year')) %>% as.matrix()
  tasmax_RCP85_ACCESS1_3_Period1 <- downscaled_ClimPred_rcp85_ACCESS1_3$tasmax %>%
    filter(year>=param$year_min_sim_Period1 & year<= param$year_max_sim_Period1) %>%
    dplyr::select(-c('month','day','year')) %>% as.matrix()
  tasmax_RCP45_ACCESS1_3_Period2 <- downscaled_ClimPred_rcp45_ACCESS1_3$tasmax %>%
    filter(year>=param$year_min_sim_Period2 & year<= param$year_max_sim_Period2) %>%
    dplyr::select(-c('month','day','year')) %>% as.matrix()
  tasmax_RCP85_ACCESS1_3_Period2 <- downscaled_ClimPred_rcp85_ACCESS1_3$tasmax %>%
    filter(year>=param$year_min_sim_Period2 & year<= param$year_max_sim_Period2) %>%
    dplyr::select(-c('month','day','year')) %>% as.matrix()
  ## CMCC_CM
  tasmax_RCP45_CMCC_CM_Period1 <- downscaled_ClimPred_rcp45_CMCC_CM$tasmax %>%
    filter(year>=param$year_min_sim_Period1 & year<= param$year_max_sim_Period1) %>%
    dplyr::select(-c('month','day','year')) %>% as.matrix()
  tasmax_RCP85_CMCC_CM_Period1 <- downscaled_ClimPred_rcp85_CMCC_CM$tasmax %>%
    filter(year>=param$year_min_sim_Period1 & year<= param$year_max_sim_Period1) %>%
    dplyr::select(-c('month','day','year')) %>% as.matrix()
  tasmax_RCP45_CMCC_CM_Period2 <- downscaled_ClimPred_rcp45_CMCC_CM$tasmax %>%
    filter(year>=param$year_min_sim_Period2 & year<= param$year_max_sim_Period2) %>%
    dplyr::select(-c('month','day','year')) %>% as.matrix()
  tasmax_RCP85_CMCC_CM_Period2 <- downscaled_ClimPred_rcp85_CMCC_CM$tasmax %>%
    filter(year>=param$year_min_sim_Period2 & year<= param$year_max_sim_Period2) %>%
    dplyr::select(-c('month','day','year')) %>% as.matrix()

  # Organize Scenario files

  # Scenarios
  ## RCP45, MIROC5, Period 1
  rcp45_MIROC5_Period1 <- list(scen = 'rcp45_MIROC5_Period1',
                             prec = prec_RCP45_MIROC5_Period1,
                             tasmin = tasmin_RCP45_MIROC5_Period1,
                             tasmax = tasmax_RCP45_MIROC5_Period1,
                             year_min = 2051,
                             year_max = 2060)
  rcp45_MIROC5_Period1 <- monthlyNorms_ClimateScenario(rcp45_MIROC5_Period1)
  ## RCP45, MIROC5, Period 2
  rcp45_MIROC5_Period2 <- list(scen = 'rcp45_MIROC5_Period2',
                             prec = prec_RCP45_MIROC5_Period2,
                             tasmin = tasmin_RCP45_MIROC5_Period2,
                             tasmax = tasmax_RCP45_MIROC5_Period2,
                             year_min = 2091,
                             year_max = 2100)
  rcp45_MIROC5_Period2 <- monthlyNorms_ClimateScenario(rcp45_MIROC5_Period2)
  ## RCP45, ACCESS1_3, Period 1
  rcp45_ACCESS1_3_Period1 <- list(scen = 'rcp45_ACCESS1_3_Period1',
                                prec = prec_RCP45_ACCESS1_3_Period1,
                                tasmin = tasmin_RCP45_ACCESS1_3_Period1,
                                tasmax = tasmax_RCP45_ACCESS1_3_Period1,
                                year_min = 2051,
                                year_max = 2060)
  rcp45_ACCESS1_3_Period1 <- monthlyNorms_ClimateScenario(rcp45_ACCESS1_3_Period1)
  ## RCP45, ACCESS1_3, Period 2
  rcp45_ACCESS1_3_Period2 <- list(scen = 'rcp45_ACCESS1_3_Period2',
                                prec = prec_RCP45_ACCESS1_3_Period2,
                                tasmin = tasmin_RCP45_ACCESS1_3_Period2,
                                tasmax = tasmax_RCP45_ACCESS1_3_Period2,
                                year_min = 2091,
                                year_max = 2100)
  rcp45_ACCESS1_3_Period2 <- monthlyNorms_ClimateScenario(rcp45_ACCESS1_3_Period2)
  ## RCP45, CMCC_CM, Period 1
  rcp45_CMCC_CM_Period1 <- list(scen = 'rcp45_CMCC_CM_Period1',
                              prec = prec_RCP45_CMCC_CM_Period1,
                              tasmin = tasmin_RCP45_CMCC_CM_Period1,
                              tasmax = tasmax_RCP45_CMCC_CM_Period1,
                              year_min = 2051,
                              year_max = 2060)
  rcp45_CMCC_CM_Period1 <- monthlyNorms_ClimateScenario(rcp45_CMCC_CM_Period1)
  ## RCP45, CMCC_CM, Period 2
  rcp45_CMCC_CM_Period2 <- list(scen = 'rcp45_CMCC_CM_Period2',
                              prec = prec_RCP45_CMCC_CM_Period2,
                              tasmin = tasmin_RCP45_CMCC_CM_Period2,
                              tasmax = tasmax_RCP45_CMCC_CM_Period2,
                              year_min = 2091,
                              year_max = 2100)
  rcp45_CMCC_CM_Period2 <- monthlyNorms_ClimateScenario(rcp45_CMCC_CM_Period2)
  ## RCP85, MIROC5, Period 1
  rcp85_MIROC5_Period1 <- list(scen = 'rcp85_MIROC5_Period1',
                             prec = prec_RCP85_MIROC5_Period1,
                             tasmin = tasmin_RCP85_MIROC5_Period1,
                             tasmax = tasmax_RCP85_MIROC5_Period1,
                             year_min = 2051,
                             year_max = 2060)
  rcp85_MIROC5_Period1 <- monthlyNorms_ClimateScenario(rcp85_MIROC5_Period1)
  ## RCP85, MIROC5, Period 2
  rcp85_MIROC5_Period2 <- list(scen = 'rcp85_MIROC5_Period2',
                             prec = prec_RCP85_MIROC5_Period2,
                             tasmin = tasmin_RCP85_MIROC5_Period2,
                             tasmax = tasmax_RCP85_MIROC5_Period2,
                             year_min = 2091,
                             year_max = 2100)
  rcp85_MIROC5_Period2 <- monthlyNorms_ClimateScenario(rcp85_MIROC5_Period2)
  ## RCP85, ACCESS1_3, Period 1
  rcp85_ACCESS1_3_Period1 <- list(scen = 'rcp85_ACCESS1_3_Period1',
                                prec = prec_RCP85_ACCESS1_3_Period1,
                                tasmin = tasmin_RCP85_ACCESS1_3_Period1,
                                tasmax = tasmax_RCP85_ACCESS1_3_Period1,
                                year_min = 2051,
                                year_max = 2060)
  rcp85_ACCESS1_3_Period1 <- monthlyNorms_ClimateScenario(rcp85_ACCESS1_3_Period1)
  ## RCP85, ACCESS1_3, Period 2
  rcp85_ACCESS1_3_Period2 <- list(scen = 'rcp85_ACCESS1_3_Period2',
                                prec = prec_RCP85_ACCESS1_3_Period2,
                                tasmin = tasmin_RCP85_ACCESS1_3_Period2,
                                tasmax = tasmax_RCP85_ACCESS1_3_Period2,
                                year_min = 2091,
                                year_max = 2100)
  rcp85_ACCESS1_3_Period2 <- monthlyNorms_ClimateScenario(rcp85_ACCESS1_3_Period2)
  ## RCP85, CMCC_CM, Period 1
  rcp85_CMCC_CM_Period1 <- list(scen = 'rcp85_CMCC_CM_Period1',
                              prec = prec_RCP85_CMCC_CM_Period1,
                              tasmin = tasmin_RCP85_CMCC_CM_Period1,
                              tasmax = tasmax_RCP85_CMCC_CM_Period1,
                              year_min = 2051,
                              year_max = 2060)
  rcp85_CMCC_CM_Period1 <- monthlyNorms_ClimateScenario(rcp85_CMCC_CM_Period1)
  ## RCP85, CMCC_CM, Period 2
  rcp85_CMCC_CM_Period2 <- list(scen = 'rcp85_CMCC_CM_Period2',
                              prec = prec_RCP85_CMCC_CM_Period2,
                              tasmin = tasmin_RCP85_CMCC_CM_Period2,
                              tasmax = tasmax_RCP85_CMCC_CM_Period2,
                              year_min = 2091,
                              year_max = 2100)
  rcp85_CMCC_CM_Period2 <- monthlyNorms_ClimateScenario(rcp85_CMCC_CM_Period2)

  clim_scen <- list()

  clim_scen$rcp45_MIROC5_Period1 <- rcp45_MIROC5_Period1
  clim_scen$rcp45_MIROC5_Period2 <- rcp45_MIROC5_Period2
  clim_scen$rcp45_ACCESS1_3_Period1 <- rcp45_ACCESS1_3_Period1
  clim_scen$rcp45_ACCESS1_3_Period2 <- rcp45_ACCESS1_3_Period2
  clim_scen$rcp45_CMCC_CM_Period1 <- rcp45_CMCC_CM_Period1
  clim_scen$rcp45_CMCC_CM_Period2 <- rcp45_CMCC_CM_Period2

  clim_scen$rcp85_MIROC5_Period1 <- rcp85_MIROC5_Period1
  clim_scen$rcp85_MIROC5_Period2 <- rcp85_MIROC5_Period2
  clim_scen$rcp85_ACCESS1_3_Period1 <- rcp85_ACCESS1_3_Period1
  clim_scen$rcp85_ACCESS1_3_Period2 <- rcp85_ACCESS1_3_Period2
  clim_scen$rcp85_CMCC_CM_Period1 <- rcp85_CMCC_CM_Period1
  clim_scen$rcp85_CMCC_CM_Period2 <- rcp85_CMCC_CM_Period2

  return(clim_scen)

}
