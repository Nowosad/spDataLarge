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
bristol_cents = st_centroid(msoas)[bristol_ttwa, ] |>
        select(geo_code = msoa11cd, name = msoa11nm) |>
        mutate_at(1:2, as.character)
plot(bristol_cents$geometry)
bristol_zones = msoas[msoas$msoa11cd %in% bristol_cents$geo_code, ] |>
        select(geo_code = msoa11cd, name = msoa11nm) |>
        mutate_at(1:2, as.character)

# get origin-destination data ---------------------------------------------

# using wicid open data - see http://wicid.ukdataservice.ac.uk/
od_all = pct::get_od()
bristol_od = od_all |>
        select(o = geo_code1, d = geo_code2, all, bicycle, foot, car_driver, train) |>
        filter(o %in% bristol_zones$geo_code & d %in% bristol_zones$geo_code, all > 19)
summary(bristol_zones$geo_code %in% bristol_od$d)
summary(bristol_zones$geo_code %in% bristol_od$o)

summary(bristol_zones$geo_code %in% bristol_od$d)
summary(bristol_zones$geo_code %in% bristol_od$o)
usethis::use_data(bristol_zones, overwrite = TRUE)
usethis::use_data(bristol_od, overwrite = TRUE)

od_intra = filter(bristol_od, o == d)
od_inter = filter(bristol_od, o != d)

# See the Transportation chapter in Geocomputation with R
# For code using these datasets

# get route network data --------------------------------------------------

bb = st_bbox(bristol_ttwa)
ways_road = opq(bbox = bb) |>
        add_osm_feature(key = "highway", value = "motorway|cycle|primary|secondary", value_exact = FALSE) |>
        osmdata_sf()
ways_rail = opq(bbox = bb) |>
        add_osm_feature(key = "railway", value = "rail") |>
        osmdata_sf()
summary(ways_road)
summary(ways_rail)

mapview::mapview(ways_rail$osm_points)

res_rail_stations = opq(bbox = bb) |>
        add_osm_feature(key = "railway", value = "station") |>
        osmdata_sf()
res = c(ways_road, ways_rail, res_rail_stations)

rail_station_points = res$osm_points |>
        filter(railway == "station" | name == "Bristol Temple Meads") |>
        filter(!duplicated(name))
mapview::mapview(rail_station_points)

bristol_stations_old = rail_station_points |>
        select(name)
bristol_stations = rail_station_points |>
        select(name) |>
        sf::st_set_crs("EPSG:4326")
waldo::compare(bristol_stations_old, bristol_stations)
waldo::compare(sf::st_crs(bristol_zones), sf::st_crs(bristol_stations))

usethis::use_data(bristol_stations, overwrite = TRUE)

# clean osm data ----------------------------------------------------------

ways = st_intersection(res$osm_lines, bristol_ttwa)
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
bristol_ways = st_cast(ways, "LINESTRING") |>
        sf::st_set_crs("EPSG:4326")
summary(st_geometry(bristol_ways))
waldo::compare(spDataLarge::bristol_ways, bristol_ways)
plot(spDataLarge::bristol_ways)
plot(bristol_ways)
usethis::use_data(bristol_ways, overwrite = TRUE)

# Test CRSs:
waldo::compare(sf::st_crs(bristol_zones), sf::st_crs(bristol_stations))
waldo::compare(sf::st_crs(bristol_zones), sf::st_crs(bristol_region))
waldo::compare(sf::st_crs(bristol_zones), sf::st_crs(bristol_ways))
waldo::compare(sf::st_crs(bristol_zones), sf::st_crs(bristol_ttwa))

