library(sf)
library(dplyr)
library(ggplot2)


mb2013 <- st_read("statsnz-meshblock-boundaries-2013-SHP\\meshblock-boundaries-2013.shp")

# first, let's chop up into 3 regions surrounding akld, wgtn, chch
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

nz_coastline <- st_transform(st_read("lds-nz-coastline-mean-high-water-SHP\\nz-coastline-mean-high-water.shp"), st_crs(mb2013))

st_crs(mb2013) # EPSG:2193 = NZTM/NZCD2000
st_crs(nz_coastline) # EPSG:2193 = NZTM/NZCD2000

# this should work... but it doesn't
mb2013_akld_clipped1 <- st_intersection(mb2013_akld_clipped, x = nz_coastline)

ggplot(mb2013_akld_clipped1) + geom_sf() # shows the original 2013 meshblocks reaching out into the sea
ggplot(nz_coastline) + geom_sf() # shows the nz coastline


nz_coastline_akld <- st_intersection(nz_coastline, st_transform(akld_buffer, "EPSG:2193"))

ggplot(nz_coastline_akld) + geom_sf()
# I've realised looking at that that there are a few issues during the 
# intersection with the meshblock data
# treatment of small offshore islands, treatment of lakes, and if I use
# the clipped nz_coastline around the cities then parts of the coastline
# are open/unbounded. Obviously a lot more going on with the clipping 
# process on a coastline than I had originally thought.
ggplot(mb2013_clipped) + geom_sf()

# no point in doing this part yet!
st_write(mb2013_clipped, "mb2013_clipped.shp")






mb2013_akld <- st_intersection(mb2013, akld_buffer)
