# Filename: 09_location_geomarketing.R (2022-12-01)

# TO DO: save data used in the location/geomarketing chapter
# the code here is basically a copy of code/chapters/14-location.R

# Author(s): jannes-m

#**********************************************************
# CONTENTS----
#**********************************************************

# 1 attach packages and data
# 2 census_de
# 3 metro_names
# 4 shops

#**********************************************************
# 1 attach packages and data----
#**********************************************************

# attach packages
library("dplyr")
library("osmdata")
library("readr")
library("tmaptools")
library("terra")

#**********************************************************
# 2 census_de----
#**********************************************************

download.file("https://tinyurl.com/ybtpkwxz",
              destfile = "census.zip", mode = "wb")
unzip("census.zip") # unzip the files
census_de = readr::read_csv2(list.files(pattern = "Gitter.csv"))
usethis::use_data(census_de)

#**********************************************************
# 3 metro_names----
#**********************************************************

# pop = population, hh_size = household size
input = dplyr::select(census_de, x = x_mp_1km, y = y_mp_1km, pop = Einwohner,
                      women = Frauen_A, mean_age = Alter_D,
                      hh_size = HHGroesse_D)
input_tidy = dplyr::mutate(
        input,
        dplyr::across(.fns =  ~ifelse(.x %in% c(-1, -9), NA, .x)))
input_ras = terra::rast(input_tidy, type = "xyz", crs = "EPSG:3035")
rcl_pop = matrix(c(1, 1, 127, 2, 2, 375, 3, 3, 1250,
                   4, 4, 3000, 5, 5, 6000, 6, 6, 8000),
                 ncol = 3, byrow = TRUE)
rcl_women = matrix(c(1, 1, 3, 2, 2, 2, 3, 3, 1, 4, 5, 0),
                   ncol = 3, byrow = TRUE)
rcl_age = matrix(c(1, 1, 3, 2, 2, 0, 3, 5, 0),
                 ncol = 3, byrow = TRUE)
rcl_hh = rcl_women
rcl = list(rcl_pop, rcl_women, rcl_age, rcl_hh)
reclass = input_ras
for (i in seq_len(terra::nlyr(reclass))) {
        reclass[[i]] = terra::classify(x = reclass[[i]], rcl = rcl[[i]],
                                       right = NA)
}
names(reclass) = names(input_ras)

pop_agg = terra::aggregate(reclass$pop, fact = 20, fun = sum, na.rm = TRUE)
pop_agg = pop_agg[pop_agg > 500000, drop = FALSE]
polys = pop_agg |>
        terra::patches(directions = 8) |>
        terra::as.polygons() |>
        sf::st_as_sf()
metros = polys |>
        dplyr::group_by(patches) |>
        dplyr::summarize()

metro_names = sf::st_centroid(metros, of_largest_polygon = TRUE) |>
        tmaptools::rev_geocode_OSM(as.data.frame = TRUE) |>
        dplyr::select(city, town, state)
# smaller cities are returned in column town. To have all names in one column,
# we move the town name to the city column in case it is NA
metro_names = dplyr::mutate(metro_names, city = ifelse(is.na(city), town, city))

usethis::use_data(metro_names, overwrite = TRUE)

#**********************************************************
# 4 shops----
#**********************************************************
metro_names = metro_names$city |>
        as.character() |>
        {\(x) ifelse(x == "Velbert", "Düsseldorf", x)}() |>
        {\(x) gsub("ü", "ue", x)}()

shops = purrr::map(metro_names, function(x) {
  message("Downloading shops of: ", x, "\n")
  # give the server a bit time
  Sys.sleep(sample(seq(5, 10, 0.1), 1))
  query = osmdata::opq(x) |>
    osmdata::add_osm_feature(key = "shop")
  points = osmdata::osmdata_sf(query)
  # request the same data again if nothing has been downloaded
  iter = 2
  while (nrow(points$osm_points) == 0 & iter > 0) {
    points = osmdata_sf(query)
    iter = iter - 1
  }
  # return only the point features
  points$osm_points
})


# checking if we have downloaded shops for each metropolitan area
ind = purrr::map_dbl(shops, nrow) == 0
if (any(ind)) {
  message("There are/is still (a) metropolitan area/s without any features:\n",
          paste(metro_names[ind], collapse = ", "), "\nPlease fix it!")
}

# select only specific columns
shops = purrr::map_dfr(shops, dplyr::select, osm_id, shop)
usethis::use_data(shops)
