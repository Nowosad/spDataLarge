# Data for Bristol:

source("https://raw.githubusercontent.com/Robinlovelace/geocompr/transport-updates-2022-08/code/13-transport-data-gen.R")


# Aim: download, preprocess, save input data - todo: save as R script

# set-up ------------------------------------------------------------------

# remotes::install_github("ropensci/osmdata")
library(sf)
sf::sf_use_s2(FALSE)
library(osmdata)
library(tidyverse)


# get region data ---------------------------------------------------------

region = getbb("Bristol", format_out = "sf_polygon", limit = 1) |>
        st_set_crs("EPSG:4326")
bristol_region = st_sf(data.frame(Name = "Bristol (OSM)"), geometry = region$geometry)
mapview::mapview(bristol_region)
dir.create("extdata")
saveRDS(region, "extdata/bristol-region.rds")
remotes::install_github("robinlovelace/ukboundaries")
library(ukboundaries)
region_ttwa = ttwa_simple |>
        filter(grepl("Bristol", ttwa11nm)) |>
        select(Name = ttwa11nm) |>
        sf::st_set_crs("EPSG:4326")
region_ttwa$Name = "Bristol (TTWA)"

# get zones ---------------------------------------------------------------

msoas = msoa2011_vsimple |>
        sf::st_set_crs("EPSG:4326")
zones_cents = st_centroid(msoas)[region_ttwa, ]
plot(zones_cents$geometry)
zones = msoas[msoas$msoa11cd %in% zones_cents$msoa11cd, ] |>
        select(geo_code = msoa11cd, name = msoa11nm) |>
        mutate_at(1:2, as.character)
plot(zones$geometry, add = TRUE)

# get origin-destination data ---------------------------------------------

# using wicid open data - see http://wicid.ukdataservice.ac.uk/
od_all = pct::get_od()
od = od_all |>
        select(o = geo_code1, d = geo_code2, all, bicycle, foot, car_driver, train) |>
        filter(o %in% zones$geo_code & d %in% zones$geo_code, all > 19)
summary(zones$geo_code %in% od$d)
summary(zones$geo_code %in% od$o)

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


bristol_region = getbb("Bristol", format_out = "sf_polygon") %>%
        st_set_crs(4326) %>%
        st_sf(data.frame(Name = "Bristol (OSM)"), geometry = .$geometry)
mapview::mapview(bristol_region)
# usethisis::use_data(bristol_region, overwrite = TRUE)
bristol_ttwa = ttwa_simple %>%
        filter(ttwa11nm == "Bristol") %>%
        select(Name = ttwa11nm)
bristol_ttwa$Name = "Bristol (TTWA)"
mapview::mapview(bristol_ttwa)
# usethisis::use_data(bristol_ttwa, overwrite = TRUE)
bristol_cents = st_centroid(msoa2011_vsimple)[bristol_ttwa, ]
plot(bristol_cents$geometry)
bristol_zones = msoa2011_vsimple[msoa2011_vsimple$msoa11cd %in% bristol_cents$msoa11cd, ] %>%
        select(geo_code = msoa11cd, name = msoa11nm) %>%
        mutate_at(1:2, as.character)
plot(bristol_zones$geometry, add = TRUE)
# Add travel data to the zones
# commented out - manual download from: http://wicid.ukdataservice.ac.uk/
# unzip("~/Downloads/wu03ew_v2.zip")
# od_all = read_csv("wu03ew_v2.csv")
# od_all_small = od_all %>%
#   filter(`Area of residence` %in% bristol_zones$geo_code &
#     `Area of workplace` %in% bristol_zones$geo_code,
#       `All categories: Method of travel to work` > 19)
# readr::write_csv(od_all_small, "od_all_small.csv")
# piggyback::pb_upload("od_all_small.csv")
# file.remove("wu03ew_v2.csv", "julyukrelease_tcm77-369384.xls")
od_all = read_csv("https://github.com/Nowosad/spDataLarge/releases/download/0.2.7.3/od_all_small.csv")
bristol_od = od_all %>%
       select(o = `Area of residence`, d = `Area of workplace`,
              all = `All categories: Method of travel to work`,
              bicycle = Bicycle, foot = `On foot`,
              car_driver = `Driving a car or van`, train = Train) %>%
       filter(o %in% bristol_zones$geo_code & d %in% bristol_zones$geo_code, all > 19)
summary(bristol_zones$geo_code %in% bristol_od$d)
summary(bristol_zones$geo_code %in% bristol_od$o)
# usethisis::use_data(bristol_zones, overwrite = TRUE)
# usethisis::use_data(bristol_od, overwrite = TRUE)
od_intra = filter(bristol_od, o == d)
od_inter = filter(bristol_od, o != d)
desire_lines = od2line(od_inter, bristol_zones)
desire_lines$distance = as.numeric(st_length(desire_lines))
desire_carshort = dplyr::filter(desire_lines, car_driver > 300 & distance < 5000)
route_carshort = stplanr::line2route(desire_carshort, route_fun = route_osrm)
route_carshort = st_as_sf(route_carshort)
# usethisis::use_data(route_carshort, overwrite = TRUE)
bb = st_bbox(bristol_ttwa)
ways_road = opq(bbox = bb) %>%
        add_osm_feature(key = "highway",
                        value = "motorway|cycle|primary|secondary",
                        value_exact = FALSE) %>%
        osmdata_sf()
ways_rail = opq(bbox = bb) %>%
        add_osm_feature(key = "railway", value = "rail") %>%
        osmdata_sf()
res = c(ways_road, ways_rail)
summary(res)
bristol_stations = res$osm_points %>%
        filter(railway == "station" | name == "Bristol Temple Meads")
# most important vars:
map_int(bristol_stations, ~ sum(is.na(.))) %>%
        sort() %>%
        head()
bristol_stations = bristol_stations %>% select(name)
# usethisis::use_data(bristol_stations, overwrite = TRUE)
ways = st_intersection(res$osm_lines, bristol_ttwa)
ways$highway = as.character(ways$highway)
ways$highway[ways$railway == "rail"] = "rail"
ways$highway = gsub("_link", "", x = ways$highway) %>%
        gsub("motorway|primary|secondary", "road", x = .) %>%
        as.factor()
ways = ways %>%
        select(highway, maxspeed, ref)
summary(st_geometry_type(ways))
# convert to linestring
bristol_ways = st_cast(ways, "LINESTRING")
summary(st_geometry(bristol_ways))
# usethisis::use_data(bristol_ways, overwrite = TRUE)


usethis::use_data(bristol_region)
