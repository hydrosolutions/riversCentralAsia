#' Write parameters to RS Minerve parameter file
#'
#' @param parameters Tibble with parameters for each RS Minerve object. Multiple
#'   parameter sets may be possible. See Details & Examples for more info on the
#'   column requirements.
#' @param outfilepath Character string with path to file to be written.
#' @return NULL for success.
#' @details `parameters` contains 5 columns: \cr
#'   `Object` (character) identifying the RSMinerve object type (e.g. Station).
#'     See Vignette Parameters for more information on the objects available in
#'     RSMinerveR. \cr
#'   `Name` is the user specified name of the object in the RSMinerve model
#'     (e.g. Meteo station A). \cr
#'   `Parameters` names all parameters for each object (e.g. Zone, X \[m\],
#'     Y \[m\], etc.). See Vignette Parameters for more information on the
#'     parameters of the available objects in RSMinerveR. \cr
#'   `Values` contains the parameter values (e.g. "A", 4500, 3000). \cr
#'   `Parameter set` (optional) is used to differentiate between multiple
#'     parameter sets. The function will write
#'     length(unique(parameters$`Parameter set`)) parameter files, appending the
#'     value of Parameter set to the base file name. \cr
#'   The outfilepath is edited in the case where several parameter sets are written
#' @examples
#' \dontrun{
#' filepath <- normalizePath(file.path("Tutorial_Parameters.txt"))
#' params <- readRSMParameters(filepath)
#' params <- params |>
#' mutate(Values = ifelse((Object == "GSM" & Parameters == "Kgl [1/d]"),
#'                         Values/2, Values))
#' writeRSMParameters(params, filepath)
#' }
#' @family RS Minerve IO
#' @export
writeRSMParameters <- function(parameters, outfilepath) {

  # A parameter tibble may not contain more than one set of parameters for a model.
  if (!("Parameter set" %in% colnames(parameters))) {
    parameters <- parameters |>
      dplyr::mutate("Parameter set" = "1")
  }

  # If multiple parameter sets are to be written to multiple files.
  for (i in base::unique(parameters$`Parameter set`) ) {
    # Split file name and create list of new file names
    if (base::length(base::unique(parameters$`Parameter set`)) > 1) {
      filepath <- gsub(".txt", paste0("_", i, ".txt"), outfilepath)
    } else {
      filepath <- outfilepath
    }

    conn <- base::file(filepath, open = "w")

    # Write header lines of parameter file
    base::writeLines("RS MINERVE - Parameters", conn)
    base::writeLines(paste0("Version 4.0.0.0 - ",
                            paste0(lubridate::as_datetime(lubridate::now()))), conn)
    base::writeLines("Model: PATH", conn)
    base::writeLines("Description: Model", conn)
    base::writeLines("Database:", conn)

    # Write object summaries
    base::writeLines("OBJECTS", conn)
    object_summary <- parameters |>
      dplyr::filter(`Parameter set` == i) |>
      dplyr::group_by(Object) |>
      dplyr::summarise(no = base::length(base::unique(Name)))
    for (j in c(1:dim(object_summary)[1])) {
      base::writeLines(paste0(object_summary$Object[j], "\t",
                              object_summary$no[j]), conn)
    }

    # Write parameters per object
    # Note the degree symbol has to be escaped with \u00B0
    base::writeLines("VALUES", conn)
    parameter_summary <- parameters |>
      dplyr::filter(`Parameter set` == i)
    for (j in c(1:base::dim(object_summary)[1])) {
      if (object_summary$Object[j] == "Comparator") {
        temp <- parameter_summary |>
          dplyr::filter(Object == "Comparator")
        base::writeLines("Comparator	Zone	", conn)
        for (k in c(1:base::dim(temp)[1])) {
          base::writeLines(paste0(temp$Name[k], "\t", temp$Zone[k]), conn)
        }
      } else if (object_summary$Object[j] == "GSM") {
        temp <- parameter_summary |>
          dplyr::filter(Object == "GSM")
        names <- base::unique(temp$Name)
        base::writeLines("GSM	Zone	A (m2)	An (mm/\u00B0C/day)	ThetaCri (-)	bp (d/mm)	Tcp1 (\u00B0C)	Tcp2 (\u00B0C)	Tcf (\u00B0C)	Agl (mm/\u00B0C/day)	Tcg (\u00B0C)	Kgl (1/d)	Ksn (1/d)", conn)
        for (l in c(1:base::length(names))) {
          temp2 <- parameter_summary |>
            dplyr::filter(Name == names[l])
          to_write <- base::paste0(names[l], "\t", temp2$Zone[1])
          for (k in c(1:base::dim(temp2)[1])) {
            to_write <- paste0(to_write, "\t", temp2$Values[k])
          }
          base::writeLines(to_write, conn)
        }
      } else if (object_summary$Object[j] == "HBV92") {
        temp <- parameter_summary |>
          dplyr::filter(Object == "HBV92")
        names <- base::unique(temp$Name)
        base::writeLines("HBV92	Zone	A (m2)	CFMax (mm/\u00B0C/d)	CFR (-)	CWH (-)	TT (\u00B0C)	TTInt (\u00B0C)	TTSM (\u00B0C)	Beta (-)	FC (mm)	PWP (-)	SUMax (mm)	Kr (1/d)	Ku (1/d)	Kl (1/d)	Kperc (1/d)", conn)
        for (l in c(1:base::length(names))) {
          temp2 <- parameter_summary |>
            dplyr::filter(Name == names[l])
          to_write <- base::paste0(names[l], "\t", temp2$Zone[1])
          for (k in c(1:base::dim(temp2)[1])) {
            to_write <- paste0(to_write, "\t", temp2$Values[k])
          }
          base::writeLines(to_write, conn)
        }
      } else if (object_summary$Object[j] == "Junction") {
        temp <- parameter_summary |>
          dplyr::filter(Object == "Junction")
        base::writeLines("Junction	Zone	", conn)
        for (k in c(1:base::dim(temp)[1])) {
          base::writeLines(paste0(temp$Name[k], "\t", temp$Zone[k]), conn)
        }
      } else if (object_summary$Object[j] == "Kinematic") {
        temp <- parameter_summary |>
          dplyr::filter(Object == "Kinematic")
        names <- base::unique(temp$Name)
        base::writeLines("Kinematic	Zone	L (m)	B0 (m)	m (-)	J0 (-)	K (m1/3/s)	N (-)", conn)
        for (l in c(1:base::length(names))) {
          temp2 <- parameter_summary |>
            dplyr::filter(Name == names[l])
          to_write <- base::paste0(names[l], "\t", temp2$Zone[1])
          for (k in c(1:base::dim(temp2)[1])) {
            to_write <- paste0(to_write, "\t", temp2$Values[k])
          }
          base::writeLines(to_write, conn)
        }
      } else if (object_summary$Object[j] == "SOCONT") {
        temp <- parameter_summary |>
          dplyr::filter(Object == "SOCONT")
        names <- base::unique(temp$Name)
        base::writeLines("SOCONT	Zone	A (m2)	An (mm/\u00B0C/day)	ThetaCri (-)	bp (d/mm)	Tcp1 (\u00B0C)	Tcp2 (\u00B0C)	Tcf (\u00B0C)	HGR3Max (m)	KGR3 (1/s)	L (m)	J0 (-)	Kr (m1/3/s)", conn)
        for (l in c(1:base::length(names))) {
          temp2 <- parameter_summary |>
            dplyr::filter(Name == names[l])
          to_write <- base::paste0(names[l], "\t", temp2$Zone[1])
          for (k in c(1:base::dim(temp2)[1])) {
            to_write <- paste0(to_write, "\t", temp2$Values[k])
          }
          base::writeLines(to_write, conn)
        }
      } else if (object_summary$Object[j] == "Source") {
        temp <- parameter_summary |>
          dplyr::filter(Object == "Source")
        base::writeLines("Source	Zone	", conn)
        for (k in c(1:base::dim(temp)[1])) {
          base::writeLines(paste0(temp$Name[k], "\t", temp$Zone[k]), conn)
        }
      } else if (object_summary$Object[j] == "Station") {
        temp <- parameter_summary |>
          dplyr::filter(Object == "Station")
        names <- base::unique(temp$Name)
        base::writeLines("Station	Zone	X (m)	Y (m)	Z (masl)	Search Radius (m)	No. min. of stations (-)	Gradient P", conn)
        for (l in c(1:base::length(names))) {
          temp2 <- parameter_summary |>
            dplyr::filter(Name == names[l])
          to_write <- base::paste0(names[l], "\t", temp2$Zone[1])
          for (k in c(1:base::dim(temp2)[1])) {
            to_write <- paste0(to_write, "\t", temp2$Values[k])
          }
          base::writeLines(to_write, conn)
        }
      }
    }

    base::close.connection(conn)

  }

  return(NULL)
}


