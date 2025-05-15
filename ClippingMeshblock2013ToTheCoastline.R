library(sf)
library(dplyr)
library(ggplot2)
library(glue)

# While trying to figure out what is going on with attempting to intersect
# meshblock 2013 to the nz coastline I ended up also doing it in ArcGIS Pro
# what was interesting was how much fast ArcGIS Pro was on the same hardware - couple
# few seconds cf many minutes

# load up the meshblocks 2013 polygon boundaries
mb2013 <- st_read("statsnz-meshblock-boundaries-2013-SHP\\meshblock-boundaries-2013.shp")
ggplot(mb2013) + geom_sf() # plot and you can see how the meshblock boundaries extend beyond the shoreline

# now let's load up a polygon map of the new shoreline
nz_shoreline <- st_read("lds-nz-coastlines-and-islands-polygons-topo-150k-SHP\\nz-coastlines-and-islands-polygons-topo-150k.shp")
ggplot(nz_shoreline) + geom_sf()

# and clip the meshblocks to the shoreline - this takes a long time
# it works a lot quicker if you cut down the shoreline dataset to a region first
# - use a similar approach to the lines further down that create a circular
# buffer around a point
clipped_meshblocks_shoreline <- st_intersection(mb2013, st_transform(nz_shoreline, st_crs(mb2013)))
ggplot(clipped_meshblocks_shoreline) + geom_sf()


# let's chop up our meshblocks into 3 regions surrounding akld, wgtn, chch
# Auckland is centred on -36.8402, 174.7791
# Wellington is centred on -41.1941, 174.9282
# Christchurch centred on -43.5110, 172.5995

# I learn't here - you can't use st_transform to set crs when original crs is NA
# you have to use st_set_crs
akld_centre <- st_set_crs(st_as_sfc("POINT(174.7791 -36.8402 )"), "EPSG:4326")
wgtn_centre <- st_set_crs(st_as_sfc("POINT(174.9282 -41.1941 )"), "EPSG:4326")
chch_centre <- st_set_crs(st_as_sfc("POINT(172.5995 -43.5110 )"), "EPSG:4326")

radius <- 50000

akld_buffer <- st_buffer(akld_centre, dist=radius)
wgtn_buffer <- st_buffer(wgtn_centre, dist=radius)
chch_buffer <- st_buffer(chch_centre, dist=radius)

mb2013_akld <- st_intersection(mb2013, st_transform(akld_buffer, "EPSG:2193"))
mb2013_wgtn <- st_intersection(mb2013, st_transform(wgtn_buffer, "EPSG:2193"))
mb2013_chch <- st_intersection(mb2013, st_transform(chch_buffer, "EPSG:2193"))

ggplot(mb2013_akld) + geom_sf()
ggplot(mb2013_wgtn) + geom_sf()
ggplot(mb2013_chch) + geom_sf()


# now let's clip these to the coastline
akld_clipped_mbs <- st_intersection(mb2013_akld, st_transform(clipped_meshblocks_shoreline, st_crs(mb2013_akld)))
ggplot(akld_clipped_mbs) + geom_sf() # works but there are are some funny looking bits across the 

wgtn_clipped_mbs <- st_intersection(mb2013_wgtn, st_transform(clipped_meshblocks_shoreline, st_crs(mb2013_wgtn)))
ggplot(wgtn_clipped_mbs) + geom_sf()

chch_clipped_mbs <- st_intersection(mb2013_chch, st_transform(clipped_meshblocks_shoreline, st_crs(mb2013_chch)))
ggplot(chch_clipped_mbs) + geom_sf()


# and let's write out to shapefiles
# function to create folder and write out shp files, checks folder existence first
write_shp <- function(feature_layer) {
  feature_layer_name <- deparse(substitute(feature_layer))
  if (!dir.exists(feature_layer_name)) {dir.create(feature_layer_name)}
  st_write(feature_layer, glue("{feature_layer_name}/{feature_layer_name}.shp"))
}

write_shp(akld_clipped_mbs)
write_shp(wgtn_clipped_mbs)
write_shp(chch_clipped_mbs)

# alternatively...
st_write(clipped_meshblocks_shoreline, "clipped_meshblocks_shoreline.shp")
st_write(akld_clipped_mbs, "akld_clipped_mbs.shp")
st_write(wgtn_clipped_mbs, "wgtn_clipped_mbs.shp")
st_write(chch_clipped_mbs, "chch_clipped_mbs.shp")


# just to check the alternative approach - might be better performance
# upfront clip both the full coastline and meshblock feature layers to a small region
# and only then do the intersection
# much, much faster
clipped_meshblocks_shoreline_akld <- st_intersection(clipped_meshblocks_shoreline, st_transform(akld_buffer, "EPSG:2193"))
akld_clipped_mbs2 <- st_intersection(mb2013_akld, st_transform(clipped_meshblocks_shoreline_akld, st_crs(mb2013_akld)))
ggplot(akld_clipped_mbs2) + geom_sf()
# hmmm, same odd dots as before


