# Filename: 06_lsl.R (2018-04-18)
#
# TO DO: Create terrain attribute raster and extract corresponding values to
#        points
#
# Author(s): Jannes Muenchow
#
#**********************************************************
# CONTENTS-------------------------------------------------
#**********************************************************
#
# 1. ATTACH PACKAGES AND DATA
# 2. DATA PREPROCESSING
#
#**********************************************************
# 1 ATTACH PACKAES AND DATA--------------------------------
#**********************************************************

# attach packages
library(qgisprocess)
library(sf)
library(terra)
library(dplyr)

# attach data
data("landslides", package = "RSAGA")

#**********************************************************
# 2 DATA PREPROCESSING-------------------------------------
#**********************************************************

# landslide points
non_pts = filter(landslides, lslpts == FALSE)
# select landslide points
lsl_pts = filter(landslides, lslpts == TRUE)
# randomly select 175 non-landslide points
set.seed(11042018)
non_pts_sub = sample_n(non_pts, size = nrow(lsl_pts))
# create smaller landslide dataset (lsl)
lsl = bind_rows(non_pts_sub, lsl_pts)
# create raster object from dem
dem = rast(
        vals = dem$data,
        nrows = dem$header$nrows,
        ncols = dem$header$ncols,
        crs = "+proj=utm +zone=17 +south +datum=WGS84 +units=m +no_defs",
        xmin = dem$header$xllcorner,
        xmax = dem$header$xllcorner + dem$header$ncols * dem$header$cellsize,
        ymin = dem$header$yllcorner,
        ymax = dem$header$yllcorner + dem$header$nrows * dem$header$cellsize,
        names = "elev"
        )
# create ta (terrain attributs)
# slope, aspect, curvatures
algs = qgisprocess::qgis_algorithms()
dplyr::filter(algs, grepl("curvature", algorithm))
alg = "saga:slopeaspectcurvature"
qgisprocess::qgis_show_help(alg)
# terrain attributes (ta)
out_nms = paste0(tempdir(), "/", c("slope", "cplan", "cprof"),
                 ".sdat")
args = rlang::set_names(out_nms, c("SLOPE", "C_PLAN", "C_PROF"))
out = qgis_run_algorithm(alg, ELEVATION = dem, METHOD = 6,
                         UNIT_SLOPE = "[1] degree",
                         UNIT_ASPECT = "[1] degree",
                         !!!args,
                         .quiet = TRUE
)
# use brick because then the layers will be in memory and not on disk
ta = rast(vapply(out[names(args)], \(x) x[1], FUN.VALUE = character(1)))
# catchment area
dplyr::filter(algs, grepl("[Cc]atchment", algorithm))
# in the first geocompr edition we used saga::flowaccumulationtopdown instead of
# saga:catchmentarea, hence, the carea values have slightly changed
alg = "saga:catchmentarea"
qgis_show_help(alg)
qgis_arguments(alg)
carea = qgis_run_algorithm(alg,
                           ELEVATION = dem,
                           METHOD = 4,
                           FLOW = file.path(tempdir(), "carea.sdat"))
# transform carea
carea = rast(carea$FLOW[1])
log10_carea = log10(carea)
names(log10_carea) = "log10_carea"

# add log_carea and dem to the terrain attributes
ta = c(ta, elev = dem, log10_carea)
# extract values to points, i.e., create predictors
lsl[, names(ta)] = raster::extract(ta, lsl[, c("x", "y")])
# save data to the data folder of the package
usethis::use_data(lsl, overwrite = TRUE)
terra::writeRaster(ta, filename = "inst/raster/ta.tif", overwrite = TRUE,
                   datatype = "INT2U", gdal = c("COMPRESS=DEFLATE"))
