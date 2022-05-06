#' Performs a quantile mapping bias correction
#'
#' Bias correction for climate model output with observations using the package
#' qmap by Lukas Gudmundsson.
#'
#' @param hist_obs Tibble with historical observations for 1 or more stations.
#'   The tibble must contain the columns \code{Date} (class: Date), \code{Basin}
#'   (class: chr) and \code{Ta} OR \code{Pr} (class: num) whereby \code{Ta} contains
#'   temperatures in deg C and \code{Pr} precipitation in mm.
#' @param hist_sim Tibble with simulations of historical time series for the
#'   region of interest.
#'   The tibble must contain the columns \code{Date} (class: Date), \code{Model}
#'   (class: chr) and \code{Ta} OR \code{Pr} (class: num) whereby \code{Ta} contains
#'   temperatures in deg C and \code{Pr} precipitation in mm. \code{Model} specifies
#'   the climate model.
#' @param fut_sim Tibble with simulations of future climate in the region of
#'   interest. The tibble must contain the columns \code{Date} (class: Date),
#'   \code{Model} (class: chr) for the climate model, \code{Scenario} (class:
#'   chr) for the CC scenario and \code{Ta} OR \code{Pr} (class: num) whereby
#'   \code{Ta} contains temperatures in deg C and \code{Pr} precipitation in mm.
#' @return NULL for failure.
#' @details It is assumed that the observations used for bias correction fit into
#'   one single tile of the climate model output.   \cr
#'   Temperatures are transformed to deg K.
#' @examples
#' hist_obs <- tibble::tribble(~Date, ~Basin, ~Pr,
#'                             "1979-01-01", "K_eb1", 0.1,
#'                             "1979-01-01", "K_eb2", 0.2,
#'                             "1979-01-01", "K_eb3", 0.3,
#'                             "1979-01-02", "K_eb1", 0.4,
#'                             "1979-01-02", "K_eb2", 0.5,
#'                             "1979-01-02", "K_eb3", 0.6) |>
#'   dplyr::mutate(Date = as.Date(Date))
#' hist_sim <- hist_obs |>
#'   dplyr::filter(Basin == "K_eb1") |>
#'   dplyr::select(-Basin) |>
#'   dplyr::mutate(Pr = Pr + 1, Model = "A")
#' hist_sim <- hist_sim |>
#'   dplyr::add_row(hist_sim |>
#'                    dplyr::mutate(Pr = Pr + 2, Model = "B"))
#' fut_sim <- hist_sim |>
#'   dplyr::mutate(Scenario = "a") |>
#'   dplyr::add_row(hist_sim |>
#'                    dplyr::mutate(Pr = Pr + 1, Scenario = "b"))
#' fut_sim <- fut_sim |>
#'   dplyr::add_row(fut_sim |>
#'                    dplyr::mutate(Date = as.Date(Date) + 2))
#'
#' results <- doQuantileMapping(hist_obs, hist_sim, fut_sim)
#' mapped_hist_sim <- results[[1]]
#' mapped_fut_sim <- results[[2]]
#' @family Pre-processing
#' @export
doQuantileMapping_Tobi <- function(hist_obs, hist_sim, fut_sim){

  # Detect data type from first tibble
  if ("Ta" %in% base::colnames(hist_obs)) {
    datatype = "Ta"
  } else if ("Pr" %in% base::colnames(hist_obs)) {
    datatype = "Pr"
  } else {
    base::cat("Error: Value column not recognized.\n")
    base::cat("       Valid column names are Ta and Pr.\n")
    return(NULL)
  }

  # Test that column names are consistent in the 3 input tibbles
  if (!(datatype %in% base::colnames(hist_sim))) {
    base::cat("Error: Columns in hist_obs and hist_sim not consistent.\n")
    return(NULL)
  }
  if (!(datatype %in% base::colnames(fut_sim))) {
    base::cat("Error: Columns in hist_obs and fut_sim not consistent.\n")
    return(NULL)
  }

  # Make sure hist_sim spans the same period as hist_obs
  hist_sim <- hist_sim |>
    dplyr::filter(as.POSIXct(.data$Date, tz = "UCT") >=
                    base::max(base::min(base::as.POSIXct(hist_obs$Date,
                                                               tz = "UTC")),
                                    base::min(base::as.POSIXct(hist_sim$Date,
                                                               tz = "UTC"))) &
                    as.POSIXct(.data$Date, tz = "UCT") <=
                    base::min(base::max(base::as.POSIXct(hist_obs$Date,
                                                                 tz = "UTC")),
                                      base::max(base::as.POSIXct(hist_sim$Date,
                                                                 tz = "UTC"))))
  hist_obs <- hist_obs |>
    dplyr::filter(as.POSIXct(.data$Date, tz = "UCT") >=
                    base::max(base::min(base::as.POSIXct(hist_obs$Date,
                                                               tz = "UTC")),
                                    base::min(base::as.POSIXct(hist_sim$Date,
                                                               tz = "UTC"))) &
                               as.POSIXct(.data$Date, tz = "UCT") <=
                    base::min(base::max(base::as.POSIXct(hist_obs$Date,
                                                                 tz = "UTC")),
                                      base::max(base::as.POSIXct(hist_sim$Date,
                                                                 tz = "UTC"))))

  # Temperature conversion to deg K
  if (datatype == "Ta") {
    hist_obs <- hist_obs |> dplyr::mutate(Ta = .data$Ta + 273.15)
    hist_sim <- hist_sim |> dplyr::mutate(Ta = .data$Ta + 273.15)
    fut_sim <- fut_sim |> dplyr::mutate(Ta = .data$Ta + 273.15)
  }

  climateModels <- fut_sim$Model |> base::unique()
  climateScenarios <- fut_sim$Scenario |> base::unique()
  subbasinNames <- hist_obs$Basin |> base::unique()
  hist_date_char <- hist_obs$Date |> base::unique() |> base::as.character()
  fut_date_char <- fut_sim$Date |> base::unique() |> base::as.character()

  # Re-formatting input
  if (datatype == "Ta") {
    hist_obs_wide <- hist_obs |>
      dplyr::select(.data$Date, .data$Basin, .data$Ta) |>
      tidyr::pivot_wider(names_from = .data$Basin, values_from = .data$Ta)
    hist_sim_wide <- hist_sim |>
      dplyr::select(.data$Date, .data$Model, .data$Ta) |>
      tidyr::pivot_wider(names_from = .data$Model, values_from = .data$Ta)
    fut_sim_wide <- fut_sim |>
      dplyr::select(.data$Date, .data$Model, .data$Scenario, .data$Ta) |>
      tidyr::pivot_wider(names_from = .data$Model, values_from = .data$Ta)
  } else {
    hist_obs_wide <- hist_obs |>
      dplyr::select(.data$Date, .data$Basin, .data$Pr) |>
      tidyr::pivot_wider(names_from = .data$Basin, values_from = .data$Pr)
    hist_sim_wide <- hist_sim |>
      dplyr::select(.data$Date, .data$Model, .data$Pr) |>
      tidyr::pivot_wider(names_from = .data$Model, values_from = .data$Pr)
    fut_sim_wide <- fut_sim |>
      dplyr::select(.data$Date, .data$Model, .data$Scenario, .data$Pr) |>
      tidyr::pivot_wider(names_from = .data$Model, values_from = .data$Pr)
  }

  # Quantile mapping for hist_sim. Do one mapping for each hydrol. response unit.
  qmap_param <- base::list()
  for (idx in 1:base::length(climateModels)){
    base::cat("QM hist_sim - Processing model: ", climateModels[idx], "\n")
    # Replicate columns of ..._sim_... data
    hist_obs_model <- hist_obs_wide
    hist_sim_model <- hist_sim_wide |>
      dplyr::select(.data$Date, climateModels[idx]) |>
      dplyr::rename(var = climateModels[idx])
    temp_mat <- base::matrix(hist_sim_model$var) |>
      base::apply(1, base::rep, base::length(subbasinNames)) |> base::t() |>
      tibble::as_tibble(.name_repair = "minimal")
    base::colnames(temp_mat) <- subbasinNames
    hist_sim_model <- dplyr::bind_cols(Date = hist_sim_model$Date, temp_mat)

    # Convert to df
    hist_sim_df <- hist_sim_model |> dplyr::select(-.data$Date) |>
      base::as.data.frame()
    hist_obs_df <- hist_obs_model |> dplyr::select(-.data$Date) |>
      base::as.data.frame()
    base::row.names(hist_sim_df) <- hist_date_char
    base::row.names(hist_obs_df) <- hist_date_char
    # now ready to qmap
    qmap_param[[idx]] <- qmap::fitQmapPTF(hist_obs_df, hist_sim_df)
    hist_sim_df_qmapped <- qmap::doQmapPTF(hist_sim_df, qmap_param[[idx]])
    # go back to tibble and convert back to deg. C
    hist_sim_qmapped_wide <- hist_sim_df_qmapped |>
      tibble::as_tibble(.name_repair = "minimal") |>
      tibble::add_column(Date = hist_date_char, .before = 1)
    if (datatype == "Ta") {
      hist_sim_qmapped_wide <- hist_sim_qmapped_wide |>
        dplyr::mutate(dplyr::across(-.data$Date, ~ . - 273.15))
    }
    # this is now for one climate model
    hist_sim_qmapped_long_model <- hist_sim_qmapped_wide |>
      tidyr::pivot_longer(-"Date", names_to = "Basin", values_to = datatype) |>
      tibble::add_column(Model = climateModels[idx]) |>
      dplyr::mutate(Date = base::as.Date(.data$Date))
    if (idx > 1){
      hist_sim_qmapped_long <- hist_sim_qmapped_long |>
        dplyr::bind_rows(hist_sim_qmapped_long_model)
    } else {
      if (datatype == "Ta") {
        hist_obs <- hist_obs |>
          dplyr::mutate(Ta = .data$Ta - 273.15) |>
          tibble::add_column(Model = "ERA5-CHELSA")
      } else {
        hist_obs <- hist_obs |>
          tibble::add_column(Model = "ERA5-CHELSA")
      }
      hist_sim_qmapped_long <- hist_obs |> dplyr::bind_rows(hist_sim_qmapped_long_model)
    }
  }

  # Quantile mapping for fut_sim
  counter <- 1
  for (idxModel in 1:base::length(climateModels)){
    for (idxScen in 1:base::length(climateScenarios)){
      base::cat("QM fut_sim - Processing Model:", climateModels[idxModel],
                "and Scenario", climateScenarios[idxScen], "\n")
      # Replicate columns of ..._sim_... data
      hist_obs_model <- hist_obs_wide
      fut_sim_model <- fut_sim_wide |>
        dplyr::filter(.data$Scenario == climateScenarios[idxScen]) |>
        dplyr::select(.data$Date, climateModels[idxModel]) |>
        dplyr::rename(var = climateModels[idxModel])
      temp_mat <- base::matrix(fut_sim_model$var) |>
        base::apply(1, base::rep, base::length(subbasinNames)) |> base::t() |>
        tibble::as_tibble(.name_repair = "minimal")
      base::colnames(temp_mat) <- subbasinNames
      fut_sim_model <- dplyr::bind_cols(Date = fut_sim_model$Date, temp_mat)
      # Convert to df
      fut_sim_df <- fut_sim_model |> dplyr::select(-.data$Date) |>
        base::as.data.frame()
      base::row.names(fut_sim_df) <- fut_date_char
      # now ready to qmap
      fut_sim_df_qmapped <- qmap::doQmapPTF(fut_sim_df, qmap_param[[idxModel]])
      fut_sim_qmapped_wide <- fut_sim_df_qmapped |>
        tibble::as_tibble(.name_repair = "minimal") |>
        tibble::add_column(Date = fut_date_char,.before = 1)
      # go back to tibble and convert back to deg. C
      if (datatype == "Ta") {
        fut_sim_qmapped_wide <- fut_sim_qmapped_wide |>
          dplyr::mutate(dplyr::across(-.data$Date, ~ . - 273.15))
      }

      # this is now for one climate model
      fut_sim_qmapped_long_model <- fut_sim_qmapped_wide |>
        tidyr::pivot_longer(-.data$Date, names_to = "Basin", values_to = datatype) |>
        tibble::add_column(Model = climateModels[idxModel],
                           Scenario = climateScenarios[idxScen]) |>
        dplyr::mutate(Date = as.Date(.data$Date))
      if (counter > 1){
        fut_sim_qmapped_long <- fut_sim_qmapped_long |>
          dplyr::bind_rows(fut_sim_qmapped_long_model)
      } else {
        fut_sim_qmapped_long <- fut_sim_qmapped_long_model
      }
      counter <- counter + 1
    }
  }
  cat("DONE!")

  return(base::list(hist_sim_qmapped_long, fut_sim_qmapped_long))

}
