generalize_nlcd = function(new_file_name){
        nlcd = raster(new_file_name)
        m = c(11, 11, 1, 21, 23, 2, 31, 31, 3, 41, 43, 4, 52, 52, 5, 71, 71, 6, 81, 82, 7, 90, 95, 8)
        rclmat = matrix(m, ncol = 3, byrow = TRUE)
        nlcd = ratify(reclassify(nlcd, rclmat, include.lowest = TRUE, right = NA))
        landcover_names = c("Water", "Developed", "Barren", "Forest", "Shrubland", "Herbaceous", "Cultivated", "Wetlands")
        landcover_cols = c("#476ba0", "#aa0000", "#b2ada3", "#68aa63", "#a58c30", "#c9c977", "#dbd83d", "#bad8ea")
        levels(nlcd) = cbind(levels(nlcd)[[1]], data.frame(levels = landcover_names,
                                                           colors = landcover_cols))
        nlcd
}
