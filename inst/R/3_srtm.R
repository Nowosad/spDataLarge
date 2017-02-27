download_srtm <- function(destination_filename){
        url <- "http://srtm.csi.cgiar.org/SRT-ZIP/SRTM_V41/SRTM_Data_GeoTiff/srtm_41_02.zip"
        download.file(url, destination_filename, method='curl')
}

process_srtm <- function(zipper, spk){
        unzip(zipper, exdir='inst/data/srtm/')
        r <- raster('inst/data/srtm/srtm_41_02.tif')
        spk10 <- gBuffer(spk, width=10000) %>% spTransform(., proj4string(r))
        r2 <- crop(r, spk10) %>% projectRaster(., crs=proj4string(spk))
        spk1 <- gBuffer(spk, width=1000)
        r3 <- crop(r2, spk1) %>% mask(., spk1)
        writeRaster(r3, 'inst/data/srtm_spk.tif', overwrite=TRUE)

}
