library('XML')
library('sp')
library('raster')
library('rgeos')
library('magrittr')

source('inst/R/1_spk_border.R')
source('inst/R/2_CLC_download.R')
source('inst/R/3_srtm.R')
source('inst/R/4_landsat8temp.R')
source('inst/R/5_landsat8ndvi.R')

## park borders
download_border_spk("inst/data/parki_krajobrazowe_pl.zip")
border <- process_border_spk("inst/data/parki_krajobrazowe_pl.zip")

## simplified corine land cover
download_clc()
process_clc("inst/data/clc/g100_06.tif", border)

## srtm data
download_srtm('inst/data/srtm_41_02.zip')
process_srtm("inst/data/srtm_41_02.zip", border)

## landsat temperature
download_landsat8('inst/data/LC81870222015186LGN00_B10.tif', band=10)
download_landsat8('inst/data/LC81870222015186LGN00_B11.tif', band=11)
cropped_landsat1011 <-  crop_landsat("inst/data/LC81870222015186LGN00_B10.tif",
                                     "inst/data/LC81870222015186LGN00_B11.tif",
                                     border)
process_landsat8_temp(cropped_landsat1011)

## landsat ndvi and savi
download_landsat8('inst/data/LC81870222015186LGN00_B4.tif', band=4)
download_landsat8('inst/data/LC81870222015186LGN00_B5.tif', band=5)
cropped_landsat45 <- crop_landsat("inst/data/LC81870222015186LGN00_B4.tif",
                                  "inst/data/LC81870222015186LGN00_B5.tif",
                                  border)
process_landsat8_ndvi(cropped_landsat45, type=1)
process_landsat8_ndvi(cropped_landsat45, type=2)
