### ------------------------------- ###

## Data Mangement - Workshop 5 ##

### ------------------------------- ###

## Install packages

install.packages("tidyverse")
library(tidyverse)

install.packages("terra")
library(terra)

install.packages("leaflet")
library(leaflet)

install.packages("tmap") # The package tmap is one of many packages for making more sophisticated maps
library(tmap)

install.packages("sf") # This stands for simple features
library(sf)

install.packages("mgcv")
library(mgcv)

### ------------------------------- ###

## Upload the data ##

library(readr)
data <- read_csv("copepods_raw.csv")
View(data)

### ------------------------------- ###

## Visual data ## 

library(ggplot2)

ggplot(data) + 
  aes(x = longitude, y = latitude, color = richness_raw) +
  geom_point()

### ------------------------------- ###

## Plotting richness ##


ggplot(data, aes(x = latitude, y = richness_raw)) + 
  stat_smooth() + 
  geom_point()

### ------------------------------- ###

## Introduction to maps ##

sdata <- st_as_sf(data, coords = c("longitude", "latitude"), # Turning our data into a simple features collection

                 crs = 4326) # crs stands for Coordinate Reference System.

### ------------------------------- ###

## Simple feature points collection ##

view(sdata)

# This shows sf also adds geometric operations, like st_join which do joins based on the coordinates.


### ------------------------------- ###


## Basic cartography ##

plot(sdata["richness_raw"]) # just an example variable

### ------------------------------- ###

## Thematic maps ##

tm_shape(sdata) + 
  tm_dots(col = "richness_raw")

# You can customize the plot

tm1 <- tm_shape(sdata) + 
  tm_dots(col = "richness_raw", 
          palette = "Blues", 
          title = "Species #")
tm1

### ------------------------------- ###

## Saving tmap ##

tmap_save(tm1, filename = "Richness-map.png", 
          width = 600, height = 600)

### ------------------------------- ###

## Mapping spatial polygons as layers ##

aus <- st_read("Aussie.shp") # Reading the shape file (Note I changed the working directory for this)

shelf <- st_read("aus_shelf.shp")


### ------------------------------- ###

## Mapping polygons ##

tm_shape(shelf) + 
  tm_polygons()

tm_shape(shelf) + # Adding layers 
  tm_polygons(col = 'lightblue') + #We’ve made the shelf ‘lightblue’ to differentiate it from the land.
  tm_shape(aus) + 
  tm_polygons() + 
  tm_shape(sdata) + 
  tm_dots()

# But we are missing the samples in the southern ocean. This is because the extent for a tmap is set by the first tm_shape. We can fix this by setting the bbox (bounding box):


tm_shape(shelf, bbox = sdata) +
  tm_polygons()+#col = 'lightblue') +
  tm_shape(aus) + 
  tm_polygons() + 
  tm_shape(sdata) +
  tm_dots()


tm_shape(shelf, bbox = sdata) +
  tm_polygons()+#col = 'lightblue', legend.title = "Happy Planet Index" +
  tm_shape(aus) + 
  tm_polygons() + 
  tm_shape(sdata) +
  tm_dots(col = "richness_raw",
            palette = "Blues", 
            title = "Species Richness") +
tmap_style("classic")


### ------------------------------- ###

## Introduction to dplyr package for spatial data wrangling ##

routes <- read_csv("~/data-for-course/Route-data.csv")
View(routes)

### ------------------------------- ###

## Table joins with spatial data ##

sdata_std <- inner_join(sdata, routes, by = "route")
nrow(sdata)

# Then check the data


### ------------------------------- ###

## Adding new variables ##


sdata_std <-  mutate(sdata_std,
                    richness = richness_raw/silk_area) # Once we have a matching silk_area value for each sample, it is easy to add a new variable that is standardised richness. To do this we use mutate which just takes exisiting variables and calculates a new variable

# plot standardized richness against latitude 
# First extract the latitude, since it is now stored in the geometry

sdata_std$Lat <- st_coordinates(sdata_std)[,2]

# Then plot 

ggplot(sdata_std) +
  aes(x = Lat, y = richness, color = richness) + 
  geom_point() +
  stat_smooth() + 
  theme_bw()

### ------------------------------- ###

##  GIS and spatial analysis ##


load("data-for-course/spatial-data/copepods_standardised.rda")
aus <- st_read("data-for-course/spatial-data/Aussie/Aussie.shp")
shelf <- st_read("aus_shelf.shp")


shelf$shelf <- "Shelf"

st_crs(shelf) # Look at the co ords for the shelf 

st_crs(sdata_std) # Look at the cords for the sdata


# st_transform to put both data sets into the same forum

shelf <- st_transform(shelf, crs = st_crs(sdata_std))

# Then join (Note you can only join when they are both in the same co-ord system)

sdata_shelf <- st_join(sdata_std, shelf, join = st_intersects)
names(sdata_shelf)

unique(sdata_shelf$shelf)

# Let’s rename those NA values to ‘Offshore’ so that is clear:

sdata_shelf <- mutate(sdata_shelf, 
                     shelf = replace_na(shelf, "Offshore"))
table(sdata_shelf$shelf)

#Map it 

tm_shape(shelf, bbox = sdata_shelf) + 
  tm_polygons(col = "grey10") + 
  tm_shape(sdata_shelf) + 
  tm_dots(col = "Shelf", palette = "RdBu") +
  tm_graticules()


# Analysis of richness by continential shelf/offshore


ggplot(sdata_shelf) + 
  aes(x = Lat, y = richness, color = shelf) +
  geom_point(alpha = 0.5, size = 0.2) + 
  stat_smooth() + 
  theme_bw()


### ------------------------------- ###

## Introducing raster data ##

rsst <- rast('MeanAVHRRSST.grd') # rast will read the raster data in as a SpatRaster object.
plot(rsst)

# We can use tmap for SpatRasters too.

tm_shape(rsst) + 
  tm_raster(palette = "-RdBu", title = "SST")


### ------------------------------- ###

## Layering rasters and points in tmap ##

# Add on our samples as points over the raster with a tmap

tm_shape(rsst) + 
  tm_raster(palette = "-RdBu", title = "SST") + 
  tm_shape(sdat_std) + 
  tm_dots(col = "richness_raw", 
          palette = "Greys", 
          title = "Species #") + 
  tm_compass() 


### ------------------------------- ###

## Extracting temperatures at the sampling sites ##

# We have overlaid our copepod sampling points on the map of temperature, now let’s extract the temperature values at those sampling sites.

sdat_std$sst <- terra::extract(rsst, vect(sdat_std))[,2]

# Plot the correlation between richness and SST. 

ggplot(sdat_std, aes(sst, richness)) + 
  geom_point() + 
  theme_minimal()

with(sdat_std, cor.test(sst, richness))






