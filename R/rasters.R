#' Digital elevation model (DEM) of the Mongón study area.
#'
#' A raster file (EPSG:32717) representing altitude
#'   (ASTER GDEM, LP DAAC 2012).  For more details, please refer to Muenchow et
#'   al. (2013).
#'
#' @format A geotiff file
#'
#' @examples
#'
#' system.file("raster/dem.tif", package = "spDataLarge")
#'
#' @name dem.tif
#'
#' @references Muenchow, J., Bräuning, A., Rodríguez, E.F. & von Wehrden, H.
#' (2013): Predictive mapping of species richness and plant species'
#' distributions of a Peruvian fog oasis along an altitudinal gradient.
#' Biotropica 45, 5, 557-566, doi: 10.1111/btp.12049.
#'
#' LP DAAC (2012): Land Processes Distributed Active Archive Center, located at
#' the U.S. Geological Survey (USGS) Earth Resources Observation and Science
#' (EROS) Center. Available at: https://lpdaac.usgs.gov/ (last accessed 25
#' January 2012).
NULL


#' Dataset landsat
#'
#' This is a dataset containing the four bands (2, 3, 4, 5) of the Landsat 8 image for
#' the area of Zion National Park
#'
#' @format A multilayer geotiff file
#'
#' @examples
#'
#' system.file("raster/landsat.tif", package = "spDataLarge")
#'
#' @name landsat.tif
#'
#'
#' @source \url{http://landsat-pds.s3.amazonaws.com/L8/038/034/LC80380342015230LGN00/}
NULL

#' Normalized difference vegetation index for the Mongón study area.
#'
#' NDVI raster file (EPSG:32717) computed from a Landsat
#'   scene (path 9, row 67, acquisition date: 09/22/2000; USGS 2013). For more
#'   details, please refer to Muenchow et al. (2013).
#'
#'
#' @format A geotiff file
#'
#' @examples
#'
#' system.file("raster/ndvi.tif", package = "spDataLarge")
#'
#' @name ndvi.tif
#'
#' @references Muenchow, J., Bräuning, A., Rodríguez, E.F. & von Wehrden, H.
#' (2013): Predictive mapping of species richness and plant species'
#' distributions of a Peruvian fog oasis along an altitudinal gradient.
#' Biotropica 45, 5, 557-566, doi: 10.1111/btp.12049.
#'
#' USGS (2013): U.S. Geological Survey. Earth Explorer. Available at:
#' http://earthexplorer.usgs.gov/ (last accessed 1 March 2013).
NULL

#' Dataset nlcd
#'
#' This is a dataset containing a simplified version of the National Land Cover Database 2011 product for
#' the Zion National Park area
#'
#' @format A geotiff file
#'
#' @examples
#'
#' system.file("raster/nlcd.tif", package = "spDataLarge")
#'
#' @name nlcd.tif
#'
#' @source \url{https://www.mrlc.gov/nlcd2011.php}
NULL


#' Dataset nlcd2011
#'
#' This is a dataset containing the National Land Cover Database 2011 product for
#' the Zion National Park area
#'
#' @format A geotiff file
#'
#' @examples
#'
#' system.file("raster/nlcd2011.tif", package = "spDataLarge")
#'
#' @name nlcd2011.tif
#'
#' @source \url{https://www.mrlc.gov/nlcd2011.php}
NULL



#' New Zeleand elevation raster data
#'
#' Elevation raster data of the New Zealand area from the Mapzen Terrain Service.
#' For teaching purposes only
#'
#' @format A geotiff file
#'
#' @examples
#'
#' system.file("raster/nz_elev.tif", package = "spDataLarge")
#'
#' @name nz_elev.tif
#'
#' @seealso
#' See the elevatr package: https://cran.r-project.org/web/packages/elevatr
#'
#' @source \url{https://aws.amazon.com/public-datasets/terrain/}
NULL


#' Dataset srtm
#'
#' This is a dataset containing the elevation raster data from SRTM of
#' the Zion National Park area
#'
#' @format A geotiff file
#'
#' @examples
#'
#' system.file("raster/srtm.tif", package = "spDataLarge")
#'
#' @name srtm.tif
#'
#' @source \url{http://srtm.csi.cgiar.org/SRT-ZIP/SRTM_V41/SRTM_Data_GeoTiff/srtm_14_05.zip}
NULL
