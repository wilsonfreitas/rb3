% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rb3-package.R
\name{rb3_bootstrap}
\alias{rb3_bootstrap}
\title{Initialize the rb3 package cache folders}
\usage{
rb3_bootstrap()
}
\description{
This function sets up the necessary directory structure for caching rb3 data.
It creates a main cache folder and three subfolders: 'raw', 'meta', and 'db'.
The folder paths are stored in the rb3 registry for later use.
}
\details{
The function first checks if the 'rb3.cachedir' option is set. If not, it uses
a subfolder in the temporary directory. It creates the main cache folder and
the three subfolders if they don't already exist, then stores their paths in
the rb3 registry.

The cache structure includes:
\itemize{
\item raw folder - for storing raw downloaded data
\item db folder - for database files
}
}
\examples{
\dontrun{
options(rb3.cachedir = "~/rb3-cache")
rb3_bootstrap()
}

}
