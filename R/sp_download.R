#' sp_download
#'
#' @export
#' @description Retrieves external files from the spDataLarge package
#' @importFrom utils download.file
#' @importFrom tools file_ext
#' @importFrom purrr map2
#' @param filenames names of files
#' @param dest_folder optional destination folder
#' @examples \dontrun{
#' sp_download(c("zion.gpkg", "landsat_b3.tif"))
#' }
#'
sp_download <- function(filenames, version_id, dest_folder = NULL){

        baseurl = "https://github.com/Nowosad/spDataLarge/blob/master/inst/"

        urls <- lapply(filenames, get_single_url)

        if (!is.null(dest_folder)){
                dir.create(dest_folder)
                file_paths <- file.path(dest_folder, filenames)
        } else {
                file_paths <- file.path(filenames)
        }

        invisible(
                map2(urls, file_paths, get_if_not_exists)
                )

}

get_single_url <- function(filename){
        if (tolower(file_ext(filename))=="tif"){
                folder_name = "raster/"
        } else {
                folder_name = "vector/"
        }

        url = paste0(baseurl, folder_name, filename, "?raw=true")
        url
}

get_if_not_exists <- function(url, destfile){
        if(!file.exists(destfile)){
                download.file(url, destfile)
        }else{
                message(paste0("A local copy of ", url, " already exists on disk"))
        }
}

