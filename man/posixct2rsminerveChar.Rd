% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/posixct2rsminerveChar.R
\name{posixct2rsminerveChar}
\alias{posixct2rsminerveChar}
\title{Function to convert POSIXCT-dates to a character representation as required by RSminerve}
\usage{
posixct2rsminerveChar(dateVec)
}
\arguments{
\item{dateVec}{Date vector}
}
\value{
Dateframe with dates in dd.mm.yyyy hh:mm:ss representation
}
\description{
Reformats a POSIXct date formats to a string (vec) with the format dd.mm.yyyy hh:mm:ss
This is the format that RSMinerve accepts for time series.
}
