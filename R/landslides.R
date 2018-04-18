#' Terrain attributes and landslide dataset
#'
#' Data used in the "Statistical learning for geographic data" chapter in Geocomputation with R.
#' See \url{http://geocompr.robinlovelace.net/spatial-cv.html} for details.
#'
#' @format raster brick (\code{ta}) data frame object (\code{lsl})
#'
#' @source `data("landslides", package = "RSAGA")`
#' @aliases ta lsl
#' @examples \dontrun{
#' library(RQGIS)
#' library(sf)
#' library(raster)
#' library(tidyverse)
#' # attach data
#' data("landslides", package = "RSAGA")
#' # landslide points
#' non_pts = filter(landslides, lslpts == FALSE)
#' # select landslide points
#' lsl_pts = filter(landslides, lslpts == TRUE)
#' # randomly select 175 non-landslide points
#' set.seed(11042018)
#' non_pts_sub = sample_n(non_pts, size = nrow(lsl_pts))
#' # create smaller landslide dataset (lsl)
#' lsl = bind_rows(non_pts_sub, lsl_pts)
#' # digital elevation model
#' dem = raster(dem$data,
#'              crs = "+proj=utm +zone=17 +south +datum=WGS84 +units=m +no_defs",
#'              xmn = dem$header$xllcorner,
#'              xmx = dem$header$xllcorner + dem$header$ncols * dem$header$cellsize,
#'              ymn = dem$header$yllcorner,
#'              ymx = dem$header$yllcorner + dem$header$nrows * dem$header$cellsize)
#' # create ta (terrain attributs)
#' # slope, aspect, curvatures
#' set_env(dev = FALSE)  # using QGIS 2.18
#' find_algorithms("curvature")
#' alg = "saga:slopeaspectcurvature"
#' get_usage(alg)
#' # terrain attributes (ta)
#' out = run_qgis(alg, ELEVATION = dem, METHOD = 6, UNIT_SLOPE = "degree",
#'                UNIT_ASPECT = "degree",
#'                ASPECT = file.path(tempdir(), "aspect.tif"),
#'                SLOPE = file.path(tempdir(), "slope.tif"),
#'                C_PLAN = file.path(tempdir(), "cplan.tif"),
#'                C_PROF = file.path(tempdir(), "cprof.tif"),
#'                load_output = TRUE)
#' # use brick because then the layers will be in memory and not on disk
#' ta = brick(out[names(out) != "ASPECT"])
#' names(ta) = c("slope", "cplan", "cprof")
#' # catchment area
#' find_algorithms("[Cc]atchment")
#' alg = "saga:flowaccumulationtopdown"
#' get_usage(alg)
#' carea = run_qgis(alg, ELEVATION = dem, METHOD = 4,
#'                  FLOW = file.path(tempdir(), "carea.tif"),
#'                  load_output = TRUE)
#' # transform carea
#' log10_carea = log10(carea)
#' names(log10_carea) = "log10_carea"
#' names(dem) = "elev"
#' # add log_carea
#' ta = addLayer(x = ta, dem, log10_carea)
#' # extract values to points, i.e., create predictors
#' lsl[, names(ta)] = raster::extract(ta, lsl[, c("x", "y")])
#' }
"lsl"


