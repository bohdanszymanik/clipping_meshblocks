import geopandas as gpd
import matplotlib.pyplot as plt
import time

s0 = time.perf_counter()
mbs_2013 = gpd.read_file("C:/Users/user/wd/RSpatialExs/statsnz-meshblock-boundaries-2013-SHP/meshblock-boundaries-2013.shp")
print(f"mbs_2013 loaded {time.perf_counter() - s0:.2f} seconds")

s1 = time.perf_counter()
coastline = gpd.read_file("C:/Users/user/wd/RSpatialExs/lds-nz-coastlines-and-islands-polygons-topo-150k-SHP/nz-coastlines-and-islands-polygons-topo-150k.shp")
print(f"coastline loaded {time.perf_counter() - s1:.2f} seconds")   

s2= time.perf_counter()
coastline = coastline.to_crs(mbs_2013.crs)
print(f"coastline reprojected {time.perf_counter() - s2:.2f} seconds")

s3 = time.perf_counter()
clipped = gpd.overlay(mbs_2013, coastline, how='intersection')
print(f"clipped done {time.perf_counter() - s3:.2f} seconds")

s4 = time.perf_counter()
clipped.plot()
print

s5= time.perf_counter()
plt.show()
print(f"plot done {time.perf_counter() - s5:.2f} seconds")