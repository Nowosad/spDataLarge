# Filename: 09_location_geomarketing.R (2026-01-21)
#
# TO DO: Generate census_de, metro_names and shops for location/geomarketing chapter
# Uses z22 package for Census 2022 data during data preparation
#
# Author(s): jannes-m
#
# IMPORTANT: Requires z22 package to be installed (GitHub version for coordinate fix)
# remotes::install_github("JsLth/z22")
#
#**********************************************************
# CONTENTS----
#**********************************************************
# 1 attach packages
# 2 census_de (bundled census data)
# 3 metro_names (generated from Census 2022 population data)
# 4 shops (downloaded from OSM for identified metros)

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
# 2 census_de----
#**********************************************************

# Load Census 2022 data at 1km resolution (women from 2011, others from 2022)
pop = z22::z22_data("population", res = "1km", year = 2022, as = "df") |>
  rename(pop = cat_0)
women = z22::z22_data("women", year = 2011, res = "1km", as = "df") |>
  rename(women = cat_0)
mean_age = z22::z22_data("age_avg", res = "1km", year = 2022, as = "df") |>
  rename(mean_age = cat_0)
hh_size = z22::z22_data("household_size_avg", res = "1km", year = 2022, as = "df") |>
  rename(hh_size = cat_0)

census_de = pop |>
  left_join(women, by = c("x", "y")) |>
  left_join(mean_age, by = c("x", "y")) |>
  left_join(hh_size, by = c("x", "y")) |>
  select(x, y, pop, women, mean_age, hh_size)

usethis::use_data(census_de, overwrite = TRUE)

#**********************************************************
# 3 metro_names----
#**********************************************************

# Use pop from census_de (already loaded in section 2)
pop_clean = pop |>
  mutate(pop = ifelse(pop < 0, NA, pop)) |>
  select(x, y, pop)

# Convert to raster
pop_ras = terra::rast(pop_clean, type = "xyz", crs = "EPSG:3035")

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
# 4 shops----
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
  points$osm_points
})

# Check for missing downloads
ind = purrr::map_dbl(shops, nrow) == 0
if (any(ind)) {
  message("Metropolitan areas without features:\n",
          paste(metro_names_vec[ind], collapse = ", "), "\nPlease retry!")
}

# Select only specific columns and combine
shops = purrr::map_dfr(shops, dplyr::select, osm_id, shop)

usethis::use_data(shops, overwrite = TRUE)
