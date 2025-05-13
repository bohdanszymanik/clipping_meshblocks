library(sf)
library(dplyr)
library(ggplot2)


mb2013 <- st_read("C:\\Users\\user\\Downloads\\statsnz-meshblock-boundaries-2013-SHP\\meshblock-boundaries-2013.shp")
nz_coastline <- st_transform(st_read("C:\\Users\\user\\Downloads\\lds-nz-coastline-mean-high-water-SHP\\nz-coastline-mean-high-water.shp"), st_crs(mb2013))

st_crs(mb2013) # EPSG:2193 = NZTM/NZCD2000
st_crs(nz_coastline) # EPSG:2193 = NZTM/NZCD2000

# this should work... but it doesn't
mb2013_clipped <- st_intersection(mb2013, x = nz_coastline)

ggplot(mb2013) + geom_sf() # shows the original 2013 meshblocks reaching out into the sea
ggplot(nz_coastline) + geom_sf() # shows the nz coastline

ggplot(mb2013_clipped) + geom_sf()

# no point in doing this part yet!
st_write(mb2013_clipped, "mb2013_clipped.shp")

# next part of my plan was to create circular clipped areas around cities
# but I need to figure out why my original coastline clipping isn't working first!!!!


# Auckland is centred on -36.84029281823505, 174.77910330635922
# Wellington is centred on -41.19411697139204, 174.928276227328
# Christchurch centred on -43.51103546580568, 172.59955702651035

akld_centre <- st_point(c(174.77910330635922, -36.84029281823505 ))
wgtn_centre <- st_point(c(174.928276227328, -41.19411697139204))
chch_centre <- st_point(c(172.59955702651035, -43.51103546580568))

sfc_akld_centre <- st_sfc(akld_centre)
sfc_wgtn_centre <- st_sfc(wgtn_centre)
sfc_chch_centre <- st_sfc(chch_centre)


class(sfc_akld_centre)
st_crs(sfc_akld_centre) # no coord system is yet assigned
# either assign directly
st_crs(sfc_akld_centre) = 2193

# or from mb2013_clipped
st_crs(mb2013_clipped) # 2193
st_transform(sfc_akld_centre, st_crs(mb2013_clipped))

akld_buffer <- st_buffer(sfc_akld_centre, dist=radius)




radius <- 500000

akld_buffer <- st_buffer(akld_centre, dist=radius)
wgtn_buffer <- st_buffer(wgtn_centre, dist=radius)
chch_buffer <- st_buffer(chch_centre, dist=radius)

mb2013_akld_clipped <- st_intersection(mb2013_clipped, akld_buffer)
mb2013_wgtn_clipped <- st_intersection(mb2013_clipped, wgtn_buffer)
mb2013_chch_clipped <- st_intersection(mb2013_clipped, chch_buffer)

ggplot(mb2013_akld_clipped) + geom_sf()
ggplot(mb2013_wgtn_clipped) + geom_sf()
ggplot(mb2013_chch_clipped) + geom_sf()




