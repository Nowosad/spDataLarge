# landsat -------------------------------------------------------
# https://aws.amazon.com/public-data-sets/landsat/
download_landsat8 <- function(destination_filename, band){
        filename <- paste0("http://landsat-pds.s3.amazonaws.com/L8/038/034/LC80380342015230LGN00/LC80380342015230LGN00_B", band, ".TIF")
        download.file(filename, destination_filename, method='auto')
        return(destination_filename)
}

preprocess_lansat8 <- function(filename, border_vector){
        vector_extent <- st_read(border_vector) %>%
                st_buffer(., 1000) %>%
                as(., "Spatial") %>%
                extent(.)
        filename %>%
                raster(.) %>%
                crop(., vector_extent) %>%
                writeRaster(., filename, overwrite=TRUE, datatype="INT2U", options=c("COMPRESS=DEFLATE"))
}
