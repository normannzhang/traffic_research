library(shiny)
library(leaflet)
library(leaflet.extras)
library(dplyr)
library(sf)
library(ggplot2)
library(stringr)
library(lemon)
library(tidyverse)


setwd('/Users/normanzhang/Desktop/traffic_research')

# Load traffic/crash data
traffic_df <- read.csv('/Users/normanzhang/Desktop/traffic_crash.csv') |>
  filter(LOCATION != '') |>
  mutate(
    YEAR = str_extract(DATE_POLICE_NOTIFIED, "\\d{4}"),
    TIME_ONLY = str_extract(DATE_POLICE_NOTIFIED, "\\d{2}:\\d{2}:\\d{2} [APM]{2}")
  ) |>
  filter(!YEAR  %in% c('2013', '2025'))

# Load Chicago ZIP Code .shp file
zip_codes <- st_read('chicago_shapefile/chicago.shp')
zip_codes <- st_transform(zip_codes, crs = 4326)
crash_sf <- st_as_sf(traffic_df, coords = c('LONGITUDE', 'LATITUDE'), crs = 4326)

# Create dataframe to assign spatial points and count total number of crashes
crash_df <- st_join(crash_sf, zip_codes, join = st_within) |>
  group_by(zip) |>
  summarise(
    crash_count = n(),
    severe_crash_count = sum(MOST_SEVERE_INJURY %in% c("FATAL", "INCAPACITATING INJURY"))
  ) |>
  st_drop_geometry(crash_df)

# Save cleaned data
#write.csv(crash_df, 'data/cleaned_traffic_data.csv', row.names = FALSE)
