library(sf)
library(dplyr)

mb2013 <- st_read("C:\\Users\\user\\Downloads\\statsnz-meshblock-boundaries-2013-SHP\\meshblock-boundaries-2013.shp")
nz_coastline <- st_transform(st_read("C:\\Users\\user\\Downloads\\lds-nz-coastline-mean-high-water-SHP\\nz-coastline-mean-high-water.shp"), st_crs(mb2013))

mb2013_clipped <- st_intersection(mb2013, nz_coastline)

plot(st_geometry(mb2013_clipped), col+"blue", main="Clipped meshblocks 2013")
plot(st_geometry(nz_coastline), add=TRUE, col="grey")
