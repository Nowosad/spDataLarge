#' Datasets providing building blocks for a location analysis
#'
#' Data used in the location chapter in Geocomputation with R.
#' See \url{http://geocompr.robinlovelace.net/transport.html} for details.
#'
#' @format sf data frame objects
#'
#' @aliases metro_names shops
#' @examples \dontrun{
#' download.file("https://tinyurl.com/ybtpkwxz",
#' destfile = "census.zip", mode = "wb")
#' unzip("census.zip") # unzip the files
#' census_de = readr::read_csv2(list.files(pattern = "Gitter.csv"))
#' }
"census_de"


