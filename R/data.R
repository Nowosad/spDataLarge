#' Elevation raster data
#'
#' Elevation raster data from SRTM of the Zion National Park area
#'
#' @format A RasterLayer object
#'
#' @source \url{http://srtm.csi.cgiar.org/SRT-ZIP/SRTM_V41/SRTM_Data_GeoTiff/srtm_14_05.zip}
"elevation"

#' Land cover raster data
#'
#' This is a dataset containing the National Land Cover Database 2011 product for
#' the Zion National Park area simplified to eight land cover categories
#'
#' @format A RasterLayer object
#' \itemize{
#'         \item{1} {Water}
#'         \item{2} {Developed}
#'         \item{3} {Barren}
#'         \item{4} {Forest}
#'         \item{5} {Shrubland}
#'         \item{6} {Herbaceous}
#'         \item{7} {Cultivated}
#'         \item{8} {Wetlands}
#' }
#'
#' @source \url{https://www.mrlc.gov/nlcd2011.php}
"nlcd"

#' Point vector data
#'
#' Dataset containing 30 randomly located points in the Zion National Park
#'
#' @format A sf object
#'
"zion_points"

#' New Zeleand elevation raster data
#'
#' Elevation raster data of the New Zeleand area from the Mapzen Terrain Service
#'
#' @format A RasterLayer object
#'
#' @seealso
#' See the elevatr package: https://cran.r-project.org/web/packages/elevatr
#'
#' @source \url{https://aws.amazon.com/public-datasets/terrain/}
"nz_elev"
