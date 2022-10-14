#' Reads parameters from RSMinerve parameter file
#'
#' @param filepath Character with path to file to read.
#' @return Tibble containing all parameters read from file.
#' @details The suported RSMInerve objects are described in the vignette
#'   Overview Objects. \cr
#'   `parameters` contains 6 columns: \cr
#'     `Object` (character) identifying the RSMinerve object type (e.g.
#'       Station). See Vignette Parameters for more information on the objects
#'       available in RSMinerveR. \cr
#'     `Name` is the user specified name of the object in the RSMinerve model
#'       (e.g. Meteo station A). \cr
#'     `Zone` is the name of the zone an object is assigned to (e.g. "A"). \cr
#'     `Parameters` names all parameters for each object (e.g. X \[m\], Y \[m\],
#'       etc.). The parameter names are the same as in the RS Minerve parameter
#'       file. See Vignette Parameters for more information on the parameters of
#'       the available objects in RSMinerveR. \cr
#'     `Values` contains the parameter values as numerics (e.g. 4500, 3000).
#' @examples
#' \dontrun{
#' filepath <- normalizePath(file.path("Tutorial_Parameters.txt"))
#' params <- readRSMParameters(filepath)
#' }
#' @family RS Minerve IO
#' @export
readRSMParameters <- function(filepath) {

  # Read in the number of objects
  objects <- NULL

  conn <- base::file(filepath, open = "r")

  # Read header lines
  line <- base::readLines(conn, n = 5)

  # Read objects line
  line <- base::readLines(conn, n = 1)

  while (length(line[1]) > 0) {

    if (line == "OBJECTS") {
      line <- base::readLines(conn, n = 1)
      if (length(line) > 0) {
        temp <- base::strsplit(line, "\t", )
        objects <- base::rbind(objects, tibble::tibble(Object = temp[[1]][1],
                                                       Number = temp[[1]][2]))
      }
      while(line != "VALUES") {
        line <- base::readLines(conn, n = 1)
        if (line != "VALUES" & length(line) > 0) {
          temp <- base::strsplit(line, "\t", )
          objects <- base::rbind(objects, tibble::tibble(Object = temp[[1]][1],
                                                         Number = temp[[1]][2]))
        }
      }

    }

    line <- base::readLines(conn, n = 1)
    if (length(line) == 0) {
      break
    }

  }

  base::close.connection(conn)

  # Calculate number of line(s) to read for each object
  header_lines <- 6 + base::dim(objects)[1] + 1
  objects <- dplyr::mutate(objects,
                           Index = c(1:base::dim(objects)[1]),
                           Line_numbers = 0,
                           Lines = list(0))

  objects$Line_numbers[1] <- list(c((header_lines + objects$Index[1] + 1):
                               (header_lines + objects$Index[1] +
                                  base::max(base::as.numeric(objects$Number[1])))))
  objects$Lines[[1]] <- readSpecificLine(filepath, objects$Line_numbers[[1]])
  for (i in c(2:base::dim(objects)[1])) {
    objects$Line_numbers[i] <- list(c((header_lines + objects$Index[i] +
                                 base::sum(base::as.numeric(
                                   objects$Number[1:(i-1)])) +
                                 1):
                               (header_lines + objects$Index[i] +
                                 base::sum(base::as.numeric(
                                   objects$Number[1:(i-1)])) +
                                 base::max(base::as.numeric(objects$Number[i])))))
    objects$Lines[[i]] <- readSpecificLine(filepath, objects$Line_numbers[[i]])
  }


  # Now parse the lines to a tibble
  output <- NULL

  for (i in c(1:base::dim(objects)[1])) {
    temp <- purrr::map_df(objects$Lines[[i]], parseObject,
                          Object = objects$Object[i])
    output <- base::rbind(temp, output)
  }

  return(output)

}


#' Read specified line from file
#' @param filepath Character path to file to be read
#' @param linenumber numeric or list of numerics indicating which line to read
#' @return Character of line or list of character lines to read from file
#' @keywords internal
readSpecificLine <- function(filepath, linenumber) {

  conn <- base::file(filepath, open = "r")
  base::readLines(conn, n = (linenumber[1]-1))
  line <- base::readLines(conn, n = length(linenumber))
  base::close.connection(conn)

  return(line)
}


#' Parses a line with the appropriate function
#' @param Object Character string describing the object
#' @param line Character string with line to read
#' @return Tibble containing parameter values read from line
#' @keywords internal
parseObject <- function(Object, line) {
  if (Object == "Comparator") {
    output <- parseComparator(line)
  } else if (Object == "GSM") {
    output <- parseGSM(line)
  } else if (Object == "HBV92") {
    output <- parseHBV(line)
  } else if (Object == "Junction") {
    output <- parseJunction(line)
  } else if (Object == "Kinematic") {
    output <- parseKinematic(line)
  } else if (Object == "SOCONT") {
    output <- parseSOCONT(line)
  } else if (Object == "Source") {
    output <- parseSource(line)
  } else if (Object == "Station") {
    output <- parseStation(line)
  } else {
    cat("Error: Cannot read", line, "from", Object)
    output <- NULL
  }
  return(output)
}


#' Parse comparator object
#' @param line A line string to be parsed
#' @return tibble with object name, parameter names and values
#' @keywords internal
parseComparator <- function(line) {
  temp <- base::strsplit(line, "\t", )
  object <- tibble::tibble(Object = "Comparator",
                   Name = temp[[1]][1],
                   Zone = temp[[1]][2]) |>
    dplyr::mutate(Parameters = as.character(NA),
                  Values = as.numeric(NA))
  return(object)
}

#' Parse junction object
#' @param line A line string to be parsed
#' @return tibble with object name, parameter names and values
#' @keywords internal
parseJunction <- function(line) {
  temp <- base::strsplit(line, "\t", )
  object <- tibble::tibble(Object = "Junction",
                   Name = temp[[1]][1],
                   Zone = temp[[1]][2]) |>
    dplyr::mutate(Parameters = as.character(NA),
                  Values = as.numeric(NA))
  return(object)
}

#' Parse source object
#' @param line A line string to be parsed
#' @return tibble with object name, parameter names and values
#' @keywords internal
parseSource <- function(line) {
  temp <- base::strsplit(line, "\t", )
  object <- tibble::tibble(Object = "Source",
                   Name = temp[[1]][1],
                   Zone = temp[[1]][2]) |>
    dplyr::mutate(Parameters = as.character(NA),
                  Values = as.numeric(NA))
  return(object)
}

#' Parse GSM object
#' @param line A line string to be parsed
#' @return tibble with object name, parameter names and values
#' @keywords internal
parseGSM <- function(line) {
  temp <- base::strsplit(line, "\t", )
  object <- tibble::tibble(Object = "GSM",
                   Name = temp[[1]][1],
                   Zone = temp[[1]][2],
                   `A [m2]` = as.numeric(temp[[1]][3]),
                   `An [mm/deg C/d]` = as.numeric(temp[[1]][4]),
                   `ThetaCri [-]` = as.numeric(temp[[1]][5]),
                   `bp [d/mm]` = as.numeric(temp[[1]][6]),
                   `Tcp1 [deg C]` = as.numeric(temp[[1]][7]),
                   `Tcp2 [deg C]` = as.numeric(temp[[1]][8]),
                   `Tcf [deg C]`= as.numeric(temp[[1]][9]),
                   `Agl [mm/deg C/d]`= as.numeric(temp[[1]][10]),
                   `Tcg [deg C]`= as.numeric(temp[[1]][11]),
                   `Kgl [1/d]`= as.numeric(temp[[1]][12]),
                   `Ksn [1/d]`= as.numeric(temp[[1]][13]))
  object <- tidyr::pivot_longer(object, cols = -c(Object, Name, Zone),
                                names_to = "Parameters",
                                values_to = "Values")
  return(object)
}

#' Parse HBV object
#' @param line A line string to be parsed
#' @return tibble with object name, parameter names and values
#' @keywords internal
parseHBV <- function(line) {
  temp <- base::strsplit(line, "\t", )
  object <- tibble::tibble(Object = "HBV92",
                           Name = temp[[1]][1],
                           Zone = temp[[1]][2],
                           `A [m2]` = as.numeric(temp[[1]][3]),
                           `CFMax [mm/deg C/d]` = as.numeric(temp[[1]][4]),
                           `CFR [-]` = as.numeric(temp[[1]][5]),
                           `CWH [-]` = as.numeric(temp[[1]][6]),
                           `TT [deg C]` = as.numeric(temp[[1]][7]),
                           `TTInt [deg C]` = as.numeric(temp[[1]][8]),
                           `TTSM [deg C]`= as.numeric(temp[[1]][9]),
                           `Beta [-]`= as.numeric(temp[[1]][10]),
                           `FC [mm]`= as.numeric(temp[[1]][11]),
                           `PWP [-]`= as.numeric(temp[[1]][12]),
                           `SUMax [mm]`= as.numeric(temp[[1]][13]),
                           `Kr [1/d]`= as.numeric(temp[[1]][14]),
                           `Ku [1/d]`= as.numeric(temp[[1]][15]),
                           `Kl [1/d]`= as.numeric(temp[[1]][16]),
                           `Kperc [1/d]`= as.numeric(temp[[1]][17]))
  object <- tidyr::pivot_longer(object, cols = -c(Object, Name, Zone),
                                names_to = "Parameters",
                                values_to = "Values")
  return(object)
}

#' Parse SOCONT object
#' @param line A line string to be parsed
#' @return tibble with object name, parameter names and values
#' @keywords internal
parseSOCONT <- function(line) {
  temp <- base::strsplit(line, "\t", )
  object <- tibble::tibble(Object = "SOCONT",
                   Name = temp[[1]][1],
                   Zone = temp[[1]][2],
                   `A [m2]` = as.numeric(temp[[1]][3]),
                   `An [mm/deg C/day]` = as.numeric(temp[[1]][4]),
                   `ThetaCri [-]` = as.numeric(temp[[1]][5]),
                   `bp [d/mm]` = as.numeric(temp[[1]][6]),
                   `Tcp1 [deg C]` = as.numeric(temp[[1]][7]),
                   `Tcp2 [deg C]` = as.numeric(temp[[1]][8]),
                   `Tcf [deg C]`= as.numeric(temp[[1]][9]),
                   `HGR3Max [m]`= as.numeric(temp[[1]][10]),
                   `KGR3 [1/s]`= as.numeric(temp[[1]][11]),
                   `L [m]`= as.numeric(temp[[1]][12]),
                   `J0 [-]`= as.numeric(temp[[1]][13]),
                   `Kr [m1/3/s]` = as.numeric(temp[[1]][14]))
  object <- tidyr::pivot_longer(object, cols = -c(Object, Name, Zone),
                                names_to = "Parameters",
                                values_to = "Values")
  return(object)
}


#' Parse Kinematic object
#' @param line A line string to be parsed
#' @return tibble with object name, parameter names and values
#' @keywords internal
parseKinematic <- function(line) {
  temp <- base::strsplit(line, "\t", )
  object <- tibble::tibble(Object = "Kinematic",
                   Name = temp[[1]][1],
                   Zone = temp[[1]][2],
                   `L [m]` = as.numeric(temp[[1]][3]),
                   `B0 [m]` = as.numeric(temp[[1]][4]),
                   `m [-]` = as.numeric(temp[[1]][5]),
                   `J0 [-]` = as.numeric(temp[[1]][6]),
                   `K [m1/3/s]` = as.numeric(temp[[1]][7]),
                   `N [-]` = as.numeric(temp[[1]][8]))
  object <- tidyr::pivot_longer(object, cols = -c(Object, Name, Zone),
                                names_to = "Parameters",
                                values_to = "Values")
  return(object)
}


#' Parse Station object
#' @param line A line string to be parsed
#' @return tibble with object name, parameter names and values
#' @keywords internal
parseStation <- function(line) {
  temp <- base::strsplit(line, "\t", )
  object <- tibble::tibble(Object = "Station",
                   Name = temp[[1]][1],
                   Zone = temp[[1]][2],
                   `X [m]` = as.numeric(temp[[1]][3]),
                   `Y [m]` = as.numeric(temp[[1]][4]),
                   `Z [masl]` = as.numeric(temp[[1]][5]),
                   `Search Radius [m]` = as.numeric(temp[[1]][6]),
                   `No. min. of stations [-]` = as.numeric(temp[[1]][7]),
                   `Gradient P [m/s/m]` = as.numeric(temp[[1]][8]),
                   `Gradient T [C/m]` = as.numeric(temp[[1]][9]),
                   `Gradient ETP [m/s/m]` = as.numeric(temp[[1]][10]),
                   `Coeff P [-]` = as.numeric(temp[[1]][11]),
                   `Coeff T [-]` = as.numeric(temp[[1]][12]),
                   `Coeff ETP [-]` = as.numeric(temp[[1]][13]))
  object <- tidyr::pivot_longer(object, cols = -c(Object, Name, Zone),
                                names_to = "Parameters",
                                values_to = "Values")
  return(object)
}
