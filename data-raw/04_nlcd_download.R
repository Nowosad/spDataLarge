download_nlcd <- function(destination_filename){
        url <- "http://gisdata.usgs.gov/tdds/downloadfile.php?TYPE=nlcd2011_imp_state&ORIG=SBDDG&FNAME=NLCD2011_IMP_Utah.zip"
        download.file(url, destination_filename)
        return(destination_filename)
}

preprocess_nlcd <- function(filename, border_vector){
        dir_name <- paste0(dirname(filename), "/nlcd2011dir")
        ifelse(!dir.exists(dir_name), dir.create(dir_name), FALSE)
        unzip(filename, exdir = dir_name)
        vector_obj <- st_read(border_vector)
        vector_extent <- vector_obj %>%
                st_buffer(., 1000) %>%
                as(., "Spatial") %>%
                extent(.)

        gdalUtils::gdalwarp(srcfile = paste0(dir_name, "/NLCD2011_IMP_Utah.tif"),
                            dstfile = paste0(dir_name, "/NLCD2011_IMP_Utah_rp.tif"),
                            t_srs = st_crs(vector_obj)$proj4string)

        paste0(dir_name, "/NLCD2011_IMP_Utah.tif") %>%
                raster(.) %>%
                crop(., vector_extent) %>%
                writeRaster(., paste0(dir_name, "/nlcd2011.tif"),
                            overwrite=TRUE, datatype="INT1U", options=c("COMPRESS=DEFLATE"))

        dir(dir_name, full.names = TRUE) %>%
                file.remove(.)
        unlink(dir_name)
}


filename = "inst/raster/nlcd2011"
border_vector = "inst/vector/zion.gpkg"
