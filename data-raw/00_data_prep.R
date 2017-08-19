library(raster)
library(sf)
library(tidyverse)

source("inst/R/01_borders_download.R")
source("inst/R/02_landsat_download.R")
source("inst/R/03_srtm_download.R")

## park borders
"inst/vector/nps_boundary.zip" %>%
        download_borders(.) %>%
        preprocess_borders(.)

## landsat8
filenames <- c("inst/raster/landsat_b2.tif",
               "inst/raster/landsat_b3.tif",
               "inst/raster/landsat_b4.tif",
               "inst/raster/landsat_b5.tif")
bands <- c(2, 3, 4, 5)

map2(filenames, bands, download_landsat8) %>%
        map(~preprocess_lansat8(., "inst/vector/zion.gpkg"))

## srtm
"inst/raster/srtm_14_05.zip" %>%
        download_srtm(.) %>%
        preprocess_srtm(., "inst/vector/zion.gpkg")


## nlcd
