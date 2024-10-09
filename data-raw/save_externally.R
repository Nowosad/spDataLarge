library(purrr)
rda2list = function(file) {
        e = new.env()
        load(file, envir = e)
        li = list(as.list(e))
        names(li) = tools::file_path_sans_ext(basename(file))
        return(li)
}

single_saver = function(x, filepath){
        print(filepath)
        if (inherits(x, "sf")){
                sf::write_sf(x, paste0(filepath, ".gpkg"))
        } else if (inherits(x, "sp")) {
                sf::write_sf(st_as_sf(x), paste0(filepath, ".gpkg"))
        } else if (inherits(x, "data.frame") || inherits(x, "matrix") || inherits(x, "numeric")) {
                write.csv(x, paste0(filepath, ".csv"), row.names = FALSE)
        } else if (inherits(x, "nb") && !inherits(x, "listw")){
                spdep::write.nb.gal(x, paste0(filepath, ".gal"))
        }
        #
        # } else if (inherits(x, "matrix"))
}

saver = function(x, outdir){
        for (i in seq_along(x)){
                name = names(x)[i]
                single_saver(x[[i]], paste0(outdir, "/", name))
        }
}

dir.create("../spData_files/data-large", showWarnings = FALSE)
dir("data", full.names = TRUE) |>
        lapply(rda2list) |>
        lapply(list_flatten, name_spec = "{inner}", name_repair = "minimal") |>
        list_flatten() |>
        saver("../spData_files/data-large")

ext_files = c("inst/vector/zion.gpkg", dir("inst/raster", full.names = TRUE))
file.copy(ext_files, "../spData_files/data-large/")
