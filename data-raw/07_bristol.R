# Aim: download, preprocess, save data from Bristol

# set-up ------------------------------------------------------------------

# remotes::install_github("ropensci/osmdata")
library(sf)
sf::sf_use_s2(FALSE)
library(stplanr)
library(osmdata)
library(tidyverse)
remotes::install_github("robinlovelace/ukboundaries")

# get region data ---------------------------------------------------------

region = getbb("Bristol", format_out = "sf_polygon", limit = 1) |>
        st_set_crs("EPSG:4326")
bristol_region = st_sf(data.frame(Name = "Bristol (OSM)"), geometry = region$geometry)
mapview::mapview(bristol_region)
usethis::use_data(bristol_region, overwrite = TRUE)

library(ukboundaries)
bristol_ttwa = ttwa_simple %>%
        filter(ttwa11nm == "Bristol") %>%
        select(Name = ttwa11nm)
bristol_ttwa$Name = "Bristol (TTWA)"
mapview::mapview(bristol_ttwa)

# Test they can be combined:
rbind(bristol_region, bristol_ttwa)
usethis::use_data(bristol_ttwa, overwrite = TRUE)

# get zones ---------------------------------------------------------------

msoas = msoa2011_vsimple |>
        sf::st_set_crs("EPSG:4326")
bristol_cents = st_centroid(msoas)[region_ttwa, ] |>
        select(geo_code = msoa11cd, name = msoa11nm) |>
        mutate_at(1:2, as.character)
plot(bristol_cents$geometry)
bristol_zones = msoas[msoas$msoa11cd %in% zones_cents$msoa11cd, ] |>
        select(geo_code = msoa11cd, name = msoa11nm) |>
        mutate_at(1:2, as.character)
plot(zones$geometry, add = TRUE)

# get origin-destination data ---------------------------------------------

# using wicid open data - see http://wicid.ukdataservice.ac.uk/
od_all = pct::get_od()
bristol_od = od_all |>
        select(o = geo_code1, d = geo_code2, all, bicycle, foot, car_driver, train) |>
        filter(o %in% zones$geo_code & d %in% zones$geo_code, all > 19)
summary(zones$geo_code %in% bristol_od$d)
summary(zones$geo_code %in% bristol_od$o)

summary(bristol_zones$geo_code %in% bristol_od$d)
summary(bristol_zones$geo_code %in% bristol_od$o)
usethis::use_data(bristol_zones, overwrite = TRUE)
usethis::use_data(bristol_od, overwrite = TRUE)

od_intra = filter(bristol_od, o == d)
od_inter = filter(bristol_od, o != d)

# See the Transportation chapter in Geocomputation with R
# For code using these datasets

# get route network data --------------------------------------------------

bb = st_bbox(region_ttwa)
ways_road = opq(bbox = bb) |>
        add_osm_feature(key = "highway", value = "motorway|cycle|primary|secondary", value_exact = FALSE) |>
        osmdata_sf()
ways_rail = opq(bbox = bb) |>
        add_osm_feature(key = "railway", value = "rail") |>
        osmdata_sf()
res = c(ways_road, ways_rail)
summary(res)

rail_stations = res$osm_points |>
        filter(railway == "station" | name == "Bristol Temple Meads")
# most important vars:
map_int(rail_stations, ~ sum(is.na(.))) |>
        sort() |>
        head()
rail_stations = rail_stations |> select(name)

# clean osm data ----------------------------------------------------------

ways = st_intersection(res$osm_lines, region_ttwa)
ways$highway = as.character(ways$highway)
ways$highway[ways$railway == "rail"] = "rail"
ways$highway = gsub("_link", "", x = ways$highway) |>
        gsub("motorway|primary|secondary", "road", x = _) |>
        as.factor()
ways = ways |>
        select(highway, maxspeed, ref)
summary(st_geometry_type(ways))
# convert to linestring
ways = st_cast(ways, "LINESTRING")
summary(st_geometry(ways))
bristol_ways = st_cast(ways, "LINESTRING")
summary(st_geometry(bristol_ways))
waldo::compare(spDataLarge::bristol_ways, bristol_ways)
plot(spDataLarge::bristol_ways)
plot(bristol_ways)
usethis::use_data(bristol_ways, overwrite = TRUE)

bristol_stations = res$osm_points %>%
        filter(railway == "station" | name == "Bristol Temple Meads")
# most important vars:
map_int(bristol_stations, ~ sum(is.na(.))) %>%
        sort() %>%
        head()
bristol_stations = bristol_stations %>% select(name)
usethis::use_data(bristol_stations, overwrite = TRUE)
