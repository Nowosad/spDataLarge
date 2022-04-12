library("qgisprocess")
library("terra")
dem = terra::rast(system.file("raster/dem.tif", package = "spDataLarge"))
ndvi = terra::rast(system.file("raster/ndvi.tif", package = "spDataLarge"))

alg = "saga:sagawetnessindex"
args = qgis_arguments(alg)
# qgisprocess::qgis_show_help(alg)

ep = qgisprocess::qgis_run_algorithm(
        alg = "saga:sagawetnessindex",
        DEM = dem,
        SLOPE_TYPE = 1,
        SLOPE = tempfile(fileext = ".sdat"),
        AREA = tempfile(fileext = ".sdat"),
        .quiet = TRUE)
# read in catchment area and catchment slope
ep = ep[c("AREA", "SLOPE")] |>
        unlist() |>
        terra::rast()
names(ep) = c("carea", "cslope")
# make sure all rasters share the same origin
terra::origin(ep) = origin(dem)
ep = c(dem, ndvi, ep)
ep$carea = log10(ep$carea)

# save data to the data folder of the package
terra::writeRaster(ep, filename = "inst/raster/ep.tif", overwrite = TRUE,
                   datatype = "FLT4S", gdal = c("COMPRESS=DEFLATE"))

