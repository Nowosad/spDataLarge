# https://aws.amazon.com/public-data-sets/landsat/

download_landsat8 <- function(destination_filename, band){
        filename <- paste0("http://landsat-pds.s3.amazonaws.com/L8/187/022/LC81870222015186LGN00/LC81870222015186LGN00_B", band, ".TIF")
        download.file(filename, destination_filename, method='curl')
}

crop_landsat <- function(first_band, second_band, spk){
        r <- stack(first_band, second_band)
        spk10 <- gBuffer(spk, width=10000) %>% spTransform(., proj4string(r))
        r2 <- crop(r, spk10) %>% projectRaster(., crs=proj4string(spk))
        spk1 <- gBuffer(spk, width=1000)
        r3 <- crop(r2, spk1) %>% mask(., spk1)
}

### temperature
#http://gis.stackexchange.com/a/137755/20955
#https://blogs.esri.com/esri/arcgis/2014/01/06/deriving-temperature-from-landsat-8-thermal-bands-tirs/

process_landsat8_temp <- function(input){
        DN_to_radiance <- function(value){
                value*0.0003342+0.1
        }
        radiance_to_kelvin <- function(value, band){
                if (band=='band10'){
                        1321.08 / log((774.89/DN_to_radiance(value))+1)
                } else if (band=='band11'){
                        1201.14 / log((480.89/DN_to_radiance(value))+1)
                }

        }
        kelvin_to_celcius <- function(value){
                value - 273.15
        }
        band_10_cel <- input[[1]] %>% radiance_to_kelvin(., 'band10') %>% kelvin_to_celcius(.)
        band_11_cel <- input[[2]] %>% radiance_to_kelvin(., 'band11') %>% kelvin_to_celcius(.)
        r4 <- stack(band_11_cel, band_11_cel)
        writeRaster(r4[[1]], 'inst/data/landsat8_temperature_spk.tif', overwrite=TRUE)
}

