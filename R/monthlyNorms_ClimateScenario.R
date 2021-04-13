#' Compute Monthly Norm of Min. and Max. Temperature and Precipitation of a Climate Scenario
#'
#' Helper function to compute monthly norms of climate variables
#'
#' @param climScenario Climate scenario (see also function climateScenarioPreparation_RMAWGEN())
#' @return climScenario list with added norms (prec_norm, tasmin_norm, tasmax_norm)
#' @export
monthlyNorms_ClimateScenario <- function(climScenario){

  base::options(dplyr.summarise.inform = FALSE)
  # dates
  dateSeq <- riversCentralAsia::generateSeqDates(climScenario$year_min,climScenario$year_max,"month")
  # prec
  prec <- climScenario$prec %>% tibble::as_tibble()
  prec <- dateSeq %>% tibble::add_column(prec)
  prec_norm <-
    prec %>% pivot_longer(-date) %>% mutate(month = month(date),.before = 2) %>%
    group_by(month,name) %>% summarize(prec_norm = mean(value)) %>%
    pivot_wider(names_from = name,values_from = prec_norm) %>% ungroup() %>%
    dplyr::select(-month) %>% as.matrix()
  # These monthly norms are in mm/month. We need the norms though in mm/day. Let us convert it carefully.
  nDaysMonth <- matrix(c(31, 28.25, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31))
  cols <- prec_norm %>% ncol()
  nDaysMonth <- matrix(rep(nDaysMonth,each=cols), ncol=cols, byrow=TRUE)
  prec_norm <- prec_norm / nDaysMonth
  climScenario$prec_norm <- prec_norm
  # tasmin
  tasmin <- climScenario$tasmin %>% tibble::as_tibble()
  tasmin <- dateSeq %>% tibble::add_column(tasmin)
  climScenario$tasmin_norm <-
    tasmin %>% pivot_longer(-date) %>% mutate(month = month(date),.before = 2) %>%
    group_by(month,name) %>% summarize(tasmin_norm = mean(value)) %>%
    pivot_wider(names_from = name,values_from = tasmin_norm) %>% ungroup() %>%
    dplyr::select(-month) %>% as.matrix()
  # tasmax
  tasmax <- climScenario$tasmax %>% tibble::as_tibble()
  tasmax <- dateSeq %>% tibble::add_column(tasmax)
  climScenario$tasmax_norm <-
    tasmax %>% pivot_longer(-date) %>% mutate(month = month(date),.before = 2) %>%
    group_by(month,name) %>% summarize(tasmax_norm = mean(value)) %>%
    pivot_wider(names_from = name,values_from = tasmax_norm) %>% ungroup() %>%
    dplyr::select(-month) %>% as.matrix()

  # Wrap up
  return(climScenario)

}

