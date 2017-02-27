# http://www.gdos.gov.pl/dane-i-metadane
download_border_spk <- function(destination_filename){
        url <- "http://sdi.gdos.gov.pl/wfs?SERVICE=WFS&VERSION=1.0.0&REQUEST=GetFeature&TYPENAME=GDOS:ParkiKrajobrazowe&SRSNAME=EPSG:2180&outputFormat=shape-zip&format_options=charset:windows-1250"
        download.file(url, destination_filename, method='curl')
}

process_border_spk <- function(zipper){
        unzip(zipper, exdir='inst/data/parki_krajobrazowe_pl/')
        # if (file.exists(zipper)) file.remove(zipper)
        pk <- shapefile('inst/data/parki_krajobrazowe_pl/ParkiKrajobrazowePolygon.shp', encoding='CP1250')
        spk <- subset(pk, nazwa=='Suwalski Park Krajobrazowy')
        proj4string(spk) <- "+init=epsg:2180"
        spk
        # saveRDS(spk, 'data/granica_spk_rds')
}



