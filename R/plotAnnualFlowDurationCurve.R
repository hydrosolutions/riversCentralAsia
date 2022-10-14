#' plot the annual flow duration curve of a river discharge data set.
#'
#' @param data tibble output of computeAnnualFlowDurationCurve
#' @param column str name of column with discharge data to plot (same as in
#'   computeAnnualFlowDurationCurve()).
#' @return A figure with the yearly average rating curve (black line) and the
#'   data of the individual years in grey.
#' @seealso [computeAnnualFlowDurationCurve()]
#' @family Post-processing
#' @export

plotAnnualFlowDurationCurve <- function(data, column){

  if(!(column %in% colnames(data))) {
    cat("Error in columns of data:", column, "not found.\n")
  } else {
    data <- data |> dplyr::rename(Q = tidyselect::all_of(column))
  }
  if(!("Ma" %in% colnames(data))) {
    cat("Error in columns of data: Ma not found.\n")
  }

  xlabel <- ifelse(max(data$Ma) > 300, "Days",
                   ifelse(max(data$Ma) == 12, "Months", ""))
  colours <- c("Yearly" = "grey", "Average" = "black")

  mean_rating_curve <- data |>
    dplyr::select(Ma, Q) |>
    dplyr::group_by(Ma) |>
    dplyr::summarise("Q [m3/s]" = mean(Q, na.rm = TRUE))

  pplot <- ggplot2::ggplot(data |> dplyr::group_by(HYear)) +
    ggplot2::geom_point(ggplot2::aes(Ma, Q, colour = "Yearly")) +
    ggplot2::geom_line(data = mean_rating_curve,
                       ggplot2::aes(Ma, `Q [m3/s]`, colour = "Average")) +
    ggplot2::ylim(c(0, max(data$Q))) +
    ggplot2::ggtitle("Yearly rating curve") +
    ggplot2::labs(x = xlabel,
                  y = "Q [m3/s]",
                  colour = "Legend") +
    ggplot2::scale_colour_manual(values = colours,
                                 guide = ggplot2::guide_legend(override.aes = list(
                                   linetype = c("blank", "solid"),
                                   shape = c(20, NA)))) +
    ggplot2::theme_bw()

  return(pplot)

}
