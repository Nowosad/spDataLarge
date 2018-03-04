download_nlcd <- function(destination_filename){
        url <- "http://www.landfire.gov/bulk/downloadfile.php?TYPE=nlcd2011&FNAME=nlcd_2011_landcover_2011_edition_2014_10_10.zip"
        download.file(url, destination_filename)
        return(destination_filename)
}

preprocess_nlcd <- function(filename, border_vector){
        dir_name <- dirname(filename)
        ifelse(!dir.exists(dir_name), dir.create(dir_name), FALSE)
        system(paste("unzip", filename, "-d", dir_name))
        # unzip(filename, exdir = dir_name)
        vector_obj <- st_read(border_vector)
        vector_extent <- vector_obj %>%
                st_buffer(., 1000) %>%
                as(., "Spatial") %>%
                extent(.)

        gdalUtils::gdalwarp(srcfile = paste0(dir_name, "/nlcd_2011_landcover_2011_edition_2014_10_10/nlcd_2011_landcover_2011_edition_2014_10_10.img"),
                            dstfile = paste0(dir_name, "/nlcd_2011_landcover_2011_edition_2014_10_10/nlcd_2011_landcover_2011_edition_2014_10_10rp.tif"),
                            t_srs = st_crs(vector_obj)$proj4string,
                            te = c(vector_extent[1], vector_extent[3], vector_extent[2], vector_extent[4]))

        paste0(dir_name, "/nlcd_2011_landcover_2011_edition_2014_10_10/nlcd_2011_landcover_2011_edition_2014_10_10rp.tif") %>%
                raster(.) %>%
                writeRaster(., paste0(dir_name, "/nlcd2011.tif"),
                            overwrite=TRUE, datatype="INT1U", options=c("COMPRESS=DEFLATE"))

        unlink(paste0(dir_name, "/nlcd_2011_landcover_2011_edition_2014_10_10"), recursive = TRUE, force = TRUE)
        file.remove(filename)
        return(paste0(dir_name, "/nlcd2011.tif"))
}
