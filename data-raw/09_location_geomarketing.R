# Filename: 09_location_geomarketing.R (2026-01-21)
#
# TO DO: Generate metro_names and shops for location/geomarketing chapter
# Uses z22 package for Census 2022 data instead of bundled census_de
#
# Author(s): jannes-m
#
# IMPORTANT: Requires z22 package to be installed
# install.packages("z22", repos = "https://geocompx.r-universe.dev")
#
#**********************************************************
# CONTENTS----
#**********************************************************
# 1 attach packages
# 2 metro_names (generated from Census 2022 population data)
# 3 shops (downloaded from OSM for identified metros)

#**********************************************************
# 1 attach packages----
#**********************************************************

library("dplyr")
library("osmdata")
library("tmaptools")
library("terra")
library("sf")
library("purrr")
library("z22")

#**********************************************************
# 2 metro_names----
#**********************************************************

# Load Census 2022 population data at 1km resolution
pop = z22::z22_data("population", res = "1km", year = 2022, as = "df") |>
  rename(pop = cat_0) |>
  mutate(pop = ifelse(pop < 0, NA, pop)) |>
  # Correct z22 coordinate offset (z22 adds 500m to already-midpoint coordinates)
  mutate(x = x - 500, y = y - 500) |>
  # Reorder columns for terra::rast (expects x, y, values)
  select(x, y, pop)

# Convert to raster
pop_ras = terra::rast(pop, type = "xyz", crs = "EPSG:3035")

# Aggregate by factor 20 and filter >500,000 population
pop_agg = terra::aggregate(pop_ras, fact = 20, fun = sum, na.rm = TRUE)
pop_agg = pop_agg[pop_agg > 500000, drop = FALSE]

# Convert to polygons representing metro regions
polys = pop_agg |>
  terra::patches(directions = 8) |>
  terra::as.polygons() |>
  sf::st_as_sf()
metros = polys |>
  dplyr::group_by(patches) |>
  dplyr::summarize()

# Reverse geocode centroids to get metro names
metro_names = sf::st_centroid(metros, of_largest_polygon = TRUE) |>
  tmaptools::rev_geocode_OSM(as.data.frame = TRUE) |>
  dplyr::select(city, town, state)

# Move town name to city column where city is NA
metro_names = dplyr::mutate(metro_names, city = ifelse(is.na(city), town, city))

usethis::use_data(metro_names, overwrite = TRUE)

#**********************************************************
# 3 shops----
#**********************************************************

# Prepare metro names for OSM queries
# Census 2022 detects 10 metros; some need manual correction:
# - Wuelfrath/Velbert -> Duesseldorf (part of greater Duesseldorf region)
# - Langenhagen -> Hannover (part of Hannover metro)
metro_names_vec = metro_names$city |>
  as.character() |>
  (\(x) ifelse(x %in% c("Velbert", "W\u00fclfrath"), "Duesseldorf", x))() |>
  (\(x) ifelse(x == "Langenhagen", "Hannover", x))() |>
  (\(x) gsub("\u00fc", "ue", x))()

# Download shops from OSM for each metro area
shops = purrr::map(metro_names_vec, function(x) {
  message("Downloading shops of: ", x, "\n")
  Sys.sleep(sample(seq(10, 15, 0.1), 1))
  query = osmdata::opq(x) |>
    osmdata::add_osm_feature(key = "shop")
  points = osmdata::osmdata_sf(query)
  iter = 2
  while (nrow(points$osm_points) == 0 && iter > 0) {
    points = osmdata::osmdata_sf(query)
    iter = iter - 1
  }
  # Select only osm_id and shop columns, preserving geometry
  points$osm_points[, c("osm_id", "shop")]
})

# Check for missing downloads
ind = purrr::map_dbl(shops, nrow) == 0
if (any(ind)) {
  message("Metropolitan areas without features:\n",
          paste(metro_names_vec[ind], collapse = ", "), "\nPlease retry!")
}

# Combine sf objects using rbind (preserves geometry)
shops = do.call(rbind, shops)

usethis::use_data(shops, overwrite = TRUE)
