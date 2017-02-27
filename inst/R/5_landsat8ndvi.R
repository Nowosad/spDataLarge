# https://aws.amazon.com/public-data-sets/landsat/
## other stuff
# http://grindgis.com/blog/vegetation-indices-arcgis
#https://blogs.esri.com/esri/arcgis/2014/01/06/deriving-temperature-from-landsat-8-thermal-bands-tirs/
## calculate ndvi from red (band 1) and near-infrared (band 2) channel
# Band 4 reflectance= (2.0000E-05 * (“sub_tif_Band_4”)) + -0.100000

process_landsat8_ndvi <- function(input, type){
        DN_to_radiance <- function(value){
                value*2.0000E-05-0.1
        }
        r4 <- DN_to_radiance(input)
        if (type == 1){
                ndvi <- overlay(r4[[1]], r4[[2]], fun = function(x, y) {
                        (y-x) / (y+x)
                })
                writeRaster(ndvi, 'inst/data/landsat8_ndvi_spk.tif', overwrite=TRUE)
        } else if (type == 2){
                savi <- overlay(r4[[1]], r4[[2]] ,fun = function(x, y) {
                        l=0.5
                        ((y-x) / (y+x+l)) * (1+l)
                })
                writeRaster(savi, 'inst/data/landsat8_savi_spk.tif', overwrite=TRUE)
        }
}

