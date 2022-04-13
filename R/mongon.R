#' @title Random points.
#' @name random_points
#' @description An [sf] (EPSG:32717) object with 100 randomly sampled points
#'   (stratified by altitude) on the Mt. Mongón (Peru). For more details, please
#'   refer to Muenchow et al. (2013). The data is used in the "Ecology" chapter
#'   in Geocomputation with R. See
#'   \url{https://geocompr.robinlovelace.net/eco.html} for details.
#' @format An [sf] object with 100 rows and 3 variables: \describe{
#'   \item{id}{Plot ID.} \item{spri}{Number of vascular plant species per plot
#'   (species richness).} \item{geometry}{Simple feature point geometry.} }
#' @examples
#' data("random_points", package = "spDataLarge")
#' @references Muenchow, J., Bräuning, A., Rodríguez, E.F. & von Wehrden, H.
#'   (2013): Predictive mapping of species richness and plant species'
#'   distributions of a Peruvian fog oasis along an altitudinal gradient.
#'   Biotropica 45, 5, 557-566, doi: 10.1111/btp.12049.
NULL

#' @title Mask of the study area on the Mount Mongón
#' @name study_area
#' @description An [sf] (EPSG:32717) object of geometry class polygon.
#' @format An [sf] object with 1 row and 2 variables: \describe{
#'   \item{name}{Name.} \item{geometry}{Simple feature polygon geometry.}}
#' @examples
#' data("study_area", package = "spDataLarge")
#' @references Muenchow, J., Bräuning, A., Rodríguez, E.F. & von Wehrden, H.
#'   (2013): Predictive mapping of species richness and plant species'
#'   distributions of a Peruvian fog oasis along an altitudinal gradient.
#'   Biotropica 45, 5, 557-566, doi: 10.1111/btp.12049.
NULL

#' @title Community matrix of the Mt. Mongón
#' @name comm
#' @description A community matrix with species as columns and sites as rows.
#'   The rownames correspond to the id which can be also found in
#'   [random_points]. Please note that in fact 100 sites have been visited but
#'   in 16 of them no species could be found (see again [random_points]). The
#'   data is used in the "Ecology" chapter in Geocomputation with R. See
#'   \url{https://geocompr.robinlovelace.net/eco.html} for details.

#' @format A dataframe with 100 sites (rows) and 69 species (columns). Species
#'   presence is given in percentage points (between 0-100% per species and
#'   site). Due to overlapping cover between individual plants, the total cover
#'   per site can be >100\%.
#' @examples
#' data("comm", package = "spDataLarge")
#' @references Muenchow, J., Bräuning, A., Rodríguez, E.F. & von Wehrden, H.
#'   (2013): Predictive mapping of species richness and plant species'
#'   distributions of a Peruvian fog oasis along an altitudinal gradient.
#'   Biotropica 45, 5, 557-566, doi: 10.1111/btp.12049.
NULL

#' @title Digital elevation model (DEM) of the Mongón study area.
#' @name dem.tif
#' @description A raster geotiff (EPSG:32717) representing altitude
#'   (ASTER GDEM, LP DAAC 2012) with 117 rows and 117 columns: \describe{
#'   \item{dem}{Altitude in m asl.}. For more details, please refer to Muenchow et
#'   al. (2013).}.
#'    The data is used in the "Ecology" chapter in Geocomputation with R.
#'    See \url{https://geocompr.robinlovelace.net/eco.html} for details.
#' @format A geotiff file
#' @examples
#' system.file("raster/ndvi.tif", package = "spDataLarge")
#' @references Muenchow, J., Bräuning, A., Rodríguez, E.F. & von Wehrden, H.
#' (2013): Predictive mapping of species richness and plant species'
#' distributions of a Peruvian fog oasis along an altitudinal gradient.
#' Biotropica 45, 5, 557-566, doi: 10.1111/btp.12049.
#'
#' LP DAAC (2012): Land Processes Distributed Active Archive Center, located at
#' the U.S. Geological Survey (USGS) Earth Resources Observation and Science
#' (EROS) Center. Available at: https://lpdaac.usgs.gov/ (last accessed 25
#' January 2012).
NULL

#' @title Normalized difference vegetation index for the Mongón study area.
#' @name ndvi.tif
#' @description NDVI raster geotiff (EPSG:32717) computed from a Landsat scene
#'   (path 9, row 67, acquisition date: 09/22/2000; USGS 2013) with 117 rows and
#'   117 columns: \describe{ \item{ndvi}{Normalized difference vegetation
#'   index.}. For more details, please refer to Muenchow et al. (2013).}.
#'   The data is used in the "Ecology" chapter in Geocomputation with R.
#'   See \url{https://geocompr.robinlovelace.net/eco.html} for details.

#' @format A geotiff file
#' @examples
#' system.file("raster/ndvi.tif", package = "spDataLarge")
#' @references Muenchow, J., Bräuning, A., Rodríguez, E.F. & von Wehrden, H.
#' (2013): Predictive mapping of species richness and plant species'
#' distributions of a Peruvian fog oasis along an altitudinal gradient.
#' Biotropica 45, 5, 557-566, doi: 10.1111/btp.12049.
#'
#' USGS (2013): U.S. Geological Survey. Earth Explorer. Available at:
#' http://earthexplorer.usgs.gov/ (last accessed 1 March 2013).
NULL

#' @title Environmental predictors
#' @name ep.tif
#' @description A geotiff file (CRS: UTM zone 17S; EPSG:32717) with 117 rows and 117 columns:
#' \enumerate{
#'     \item{\code{dem}} {Digital elevation model (ASTER GDEM, LP DAAC 2012), see also [spDataLarge::dem].}
#'     \item{\code{ndvi}} {Normalized Differenced Vegetation index.}
#'     \item{\code{carea}} {Catchment area.}
#'     \item{\code{cslope}} {Catchment slope}
#'     }
#' The data is used in the "Ecology" chapter in Geocomputation with R.
#' See \url{https://geocompr.robinlovelace.net/eco.html} for details.
#'
#' @format A geotiff file
#' @examples
#' system.file("raster/ep.tif", package = "spDataLarge")
#' @references
#' LP DAAC (2012): Land Processes Distributed Active Archive Center, located
#' at the U.S. Geological Survey (USGS) Earth Resources Observation
#' and Science (EROS) Center. Available at: https://lpdaac.usgs.gov/
#' (last accessed 25 January 2012).
#'
#' Muenchow, J., Brauning, A., Rodriguez, E.F. & von Wehrden, H. (2013):
#' Predictive mapping of species richness and plant species' distributions of a
#' Peruvian fog oasis along an altitudinal gradient. Biotropica 45, 5, 557-566,
#' doi: 10.1111/btp.12049.
#'
#' Muenchow, J., Schratz, P., and A. Brenning. 2017. RQGIS: Integrating R with
#' QGIS for Statistical Geocomputing. The R Journal 9, 2, 409-428.
#' https://rjournal.github.io/archive/2017/RJ-2017-067/RJ-2017-067.pdf.
NULL
