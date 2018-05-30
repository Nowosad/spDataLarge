# Filename: london_streets.R (2018-05-30)
#
# TO DO: Download and save streets of London
#
# Author(s): Jannes Muenchow
#
#**********************************************************
# CONTENTS-------------------------------------------------
#**********************************************************
#
# 1. ATTACH PACKAGES AND DATA
# 2. DOWNLOAD AND SAVE DATA
#
#**********************************************************
# 1 ATTACH PACKAGES AND DATA-------------------------------
#**********************************************************

# attach packages
library(sf)
library(osmdata)
library(spData)
# attach data
data(cycle_hire)
points = cycle_hire[1:25, ]

#**********************************************************
# 2 DOWNLOAD AND SAVE DATA---------------------------------
#**********************************************************

b_box = sf::st_bbox(cycle_hire)
london_streets = opq(b_box) %>%
        add_osm_feature(key = "highway") %>%
        osmdata_sf() %>%
        `[[`("osm_lines")
london_streets = dplyr::select(london_streets, 1)
# devtools::use_data(london_streets, overwrite = TRUE)
