download_borders <- function(destination_filename){
        url <- "https://irma.nps.gov/DataStore/DownloadFile/580617"
        download.file(url, destination_filename)
        return(destination_filename)
}
preprocess_borders <- function(filename, clean = TRUE){
        dir_name <- dirname(filename)
        unzip(filename, exdir = dir_name)
        st_read(paste0(dir_name, "/nps_boundary.shp")) %>%
                filter(PARKNAME=="Zion") %>%
                st_transform(., 26912) %>%
                st_cast(., "POLYGON") %>%
                st_write(paste0(dir_name, "/zion.gpkg"))
        if(clean){
                dir(path=dir_name, pattern="nps_boundary.*", full.names = TRUE) %>%
                        file.remove(.)
        }
}
