#' Datasets providing building blocks for a location analysis
#'
#' Data used in the geomarketing chapter in Geocomputation with R.
#' See \url{http://geocompr.robinlovelace.net/location.html} for details.
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


