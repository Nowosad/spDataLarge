download_srtm <- function(destination_filename){
        url <- "http://srtm.csi.cgiar.org/SRT-ZIP/SRTM_V41/SRTM_Data_GeoTiff/srtm_14_05.zip"
        download.file(url, destination_filename)
        return(destination_filename)
}

preprocess_srtm <- function(filename, border_vector){
        dir_name <- dirname(filename)
        unzip(filename, exdir = dir_name)
        vector_obj <- st_read(border_vector)
        vector_extent <- vector_obj %>%
                st_buffer(., 1000) %>%
                st_transform(., crs = 4326) %>%
                as(., "Spatial") %>%
                extent(.)
        paste0(dir_name, "/srtm_14_05.tif") %>%
                raster(.) %>%
                # projectRaster(., crs = st_crs(vector_obj)$proj4string) %>%
                crop(., vector_extent) %>%
                writeRaster(., paste0(dir_name, "/srtm.tif"),
                            overwrite=TRUE, datatype="INT2U", options=c("COMPRESS=DEFLATE"))

        dir(dir_name, pattern = "srtm_14_05*", full.names = TRUE) %>%
                file.remove(.)
        dir(dir_name, pattern = "readme.txt", full.names = TRUE) %>%
                file.remove(.)
}
