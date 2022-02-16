#' Landslide dataset from Southern Ecuador
#'
#' Data used in the "Statistical learning for geographic data" chapter in Geocomputation with R.
#' See \url{http://geocompr.robinlovelace.net/spatial-cv.html} for details.
#'
#' @format The landslide dataset consists of two objects (CRS: UTM zone 17S; EPSG:32717):
#' \enumerate{
#'     \item{\code{lsl}} {A \code{data.frame} object representing the coordinates of landslide initiation points with 350 rows and 8 columns.}
#'     \item{\code{study_mask}  {An \code{sf}-object delineating the natural part of the study area.}
#'     }
#'}
#' @source Landslide dataset of the RSAGA package: \code{data("landslides", package = "RSAGA")}.
#'
#'  \strong{Landslide Data:}
#'
#'   Muenchow, J., Brenning, A., Richter, R. (2012): Geomorphic process rates of
#'   landslides along a humidity gradient in the tropical Andes, Geomorphology
#'   139-140, 271-284. DOI: 10.1016/j.geomorph.2011.10.029.
#'
#'   Stoyan, R. (2000): Aktivitaet, Ursachen und Klassifikation der Rutschungen
#'   in San Francisco/Suedecuador. Unpublished diploma thesis, University of
#'   Erlangen-Nuremberg, Germany.
#'
#' @aliases lsl study_mask
#' @seealso \code{?ta.tif}
#' @examples
#' data("lsl", "study_mask", package = "spDataLarge")
"lsl"

#' Terrain attributes of the landslide dataset from Southern Ecuador
#'
#' Data used in the "Statistical learning for geographic data" chapter in Geocomputation with R.
#' See \url{http://geocompr.robinlovelace.net/spatial-cv.html} for details.
#'
#' @format A geotiff file with the five terrain attribute layers: slope, plan
#'   curvature, profile curvature, elevation and catchment area.
#'
#' @examples
#' terra::rast(system.file("raster/ta.tif", package = "spDataLarge"))
#' @name ta.tif
#' @seealso \code{?lsl}
#' @source DEM dataset of the RSAGA package: \code{data("landslides",
#'   package = "RSAGA")}.
#'
#' \strong{DEM:}
#'
#'   Ungerechts, L. (2010): DEM 10m (triangulated from aerial photo - b/w).
#'   Available online:
#'
#'   `http://www.tropicalmountainforest.org/data_pre.do?citid=901`
#'
#'   Jordan, E., Ungerechts, L., Caceres, B. Penafiel, A. and Francou, B.
#'   (2005): Estimation by photogrammetry of the glacier recession on the
#'   Cotopaxi Volcano (Ecuador) between 1956 and 1997. *Hydrological
#'   Sciences* 50, 949-961.
NULL
