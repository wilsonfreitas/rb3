% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/template.R
\name{list_templates}
\alias{list_templates}
\title{List Available Templates}
\usage{
list_templates()
}
\value{
A tibble with the following columns:
\describe{
\item{Description}{The description of the template}
\item{Template}{The template identifier}
}
}
\description{
Retrieves all templates registered in the template registry and returns their properties
as a tibble.
}
\examples{
list_templates()

}
