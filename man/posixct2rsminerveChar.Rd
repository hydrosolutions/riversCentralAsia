% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/posixct2rsminerveChar.R
\name{posixct2rsminerveChar}
\alias{posixct2rsminerveChar}
\title{Function to convert POSIXCT-dates to a character representation as required
by RSminerve}
\usage{
posixct2rsminerveChar(dateVec, tz = "")
}
\arguments{
\item{dateVec}{Date vector}

\item{tz}{Optional character indicating time zone for as.POSIXct. Default is
system internal time zone (""). "GTM" or known local time zone of
data recommended.}
}
\value{
Dateframe with dates in dd.mm.yyyy hh:mm:ss representation
}
\description{
Reformats a POSIXct date formats to a string (vec) with the format
dd.mm.yyyy hh:mm:ss.
This is the format that RSMinerve accepts for time series.
}
\examples{
date_vec <- c("2018-01-01 01:00:00", "2018-01-01 02:00:00", "2018-01-01 03:00:00")
rsminerve_date_vec <- posixct2rsminerveChar(date_vec, "GMT")
}
\seealso{
Other Helper functions: 
\code{\link{\%>\%}()},
\code{\link{aggregate_to_monthly}()},
\code{\link{cutRaster2Basin}()},
\code{\link{decadeMaker}()},
\code{\link{generateSeqDates}()},
\code{\link{hyear}()},
\code{\link{monDateSeq}()}
}
\concept{Helper functions}