% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/constructors_navigation.R
\name{go}
\alias{go}
\title{wrapper around remDr$navigate method to generate safe navigation code}
\usage{
go(url, prev = NULL)
}
\arguments{
\item{url}{a character string specifying the name of the object holding the url string or the url string the function should navigate to.}

\item{prev}{a placeholder for the output of functions being piped into go(). Defaults to NULL and should not be altered.}
}
\value{
a character string defining 'RSelenium' navigation instructions that can be pasted into a scraping function
}
\description{
wrapper around remDr$navigate method to generate safe navigation code
}
\examples{
\dontrun{

go("https://www.wikipedia.org/") \%>>\%
show()

}
}
