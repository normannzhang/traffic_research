# traffic_df <- read.csv('data/traffic_crash.csv') |>
#   filter(LOCATION != '') |>
#   mutate(
#     YEAR = str_extract(DATE_POLICE_NOTIFIED, "\\d{4}"),
#     TIME_ONLY = str_extract(DATE_POLICE_NOTIFIED, "\\d{2}:\\d{2}:\\d{2} [APM]{2}")
#   )
# 
# zip_codes <- st_read('chicago_shapefile/chicago.shp')
# zip_codes <- st_transform(zip_codes, crs = 4326)
# crash_sf <- st_as_sf(traffic_df, coords = c('LONGITUDE', 'LATITUDE'), crs = 4326)
# 
# select_feats <- c('YEAR', 'TRAFFIC_CONTROL_DEVICE', 'DEVICE_CONDITION', 'WEATHER_CONDITION', 'LIGHTING_CONDITION', 'FIRST_CRASH_TYPE',
#                   'TRAFFICWAY_TYPE', 'ROADWAY_SURFACE_COND', 'zip', 'POSTED_SPEED_LIMIT', 'severe')
# 
# all_year_df <- crash_sf |>
#   filter(YEAR %in% c(2015:2025)) |>
#   mutate(
#     severe = ifelse(MOST_SEVERE_INJURY %in% c('FATAL', 'INCAPACITATING INJURY'), 1, 0)
#   ) |>
#   st_join(zip_codes, join = st_within) |>
#   filter(
#     POSTED_SPEED_LIMIT >= 5, POSTED_SPEED_LIMIT <= 70,
#     !TRAFFICWAY_TYPE %in% c('UNKNOWN INTERSECTION TYPE', 'NOT REPORTED'),
#     TRAFFIC_CONTROL_DEVICE %in% c('TRAFFIC SIGNAL', 'STOP SIGN/FLASHER', 'YIELD', 'NO CONTROLS'),
#     DEVICE_CONDITION %in% c('FUNCTIONING PROPERLY', 'FUNCTIONING IMPROPERLY', 'NOT FUNCTIONING'),
#     WEATHER_CONDITION %in% c('CLEAR', 'RAIN', 'CLOUDY/OVERCAST', 'SNOW'),
#     LIGHTING_CONDITION %in% c('DAYLIGHT', 'DARKNESS', 'DARKNESS, LIGHTED ROAD', 'DAWN', 'DUSK'),
#     ROADWAY_SURFACE_COND %in% c('DRY', 'WET', 'SNOW OR SLUSH', 'ICE')
#   ) |>
#   select(all_of(select_feats)) |>
#   filter(
#     if_all(all_of(select_feats), ~ !. %in% c('UNKNOWN', 'OTHER', 'OTHER REG. SIGN'))
#   ) |>
#   mutate(
#     POSTED_SPEED_LIMIT = case_when(
#       POSTED_SPEED_LIMIT <= 15 ~ '(0-15) VERY LOW',
#       POSTED_SPEED_LIMIT <= 25 ~ '(16-25) LOW',
#       POSTED_SPEED_LIMIT <= 35 ~ '(26-35) MODERATE',
#       POSTED_SPEED_LIMIT <= 45 ~ '(36-45) HIGH',
#       TRUE                     ~ '(46+) VERY HIGH'
#     ),
#     LIGHTING_CONDITION = case_when(
#       LIGHTING_CONDITION %in% c('DAWN', 'DUSK') ~ 'LOW LIGHT',
#       TRUE ~ toupper(LIGHTING_CONDITION)
#     ),
#     FIRST_CRASH_TYPE = case_when(
#       FIRST_CRASH_TYPE %in% c('REAR END', 'REAR TO SIDE', 'REAR TO FRONT', 'REAR TO REAR') ~ 'REAR IMPACT',
#       FIRST_CRASH_TYPE %in% c('SIDESWIPE SAME DIRECTION', 'SIDESWIPE OPPOSITE DIRECTION') ~ 'SIDESWIPE',
#       FIRST_CRASH_TYPE %in% c('ANGLE', 'TURNING') ~ 'INTERSECTION',
#       FIRST_CRASH_TYPE %in% c('PEDESTRIAN', 'PEDALCYCLIST') ~ 'PEDESTRIAN/BIKE',
#       FIRST_CRASH_TYPE %in% c('PARKED MOTOR VEHICLE', 'FIXED OBJECT', 'OTHER OBJECT') ~ 'STATIONARY/FIXED',
#       FIRST_CRASH_TYPE %in% c('HEAD ON', 'OVERTURNED') ~ 'HIGH IMPACT',
#       TRUE ~ 'OTHER'
#     ),
#     TRAFFICWAY_TYPE = case_when(
#       TRAFFICWAY_TYPE %in% c('DIVIDED - W/MEDIAN (NOT RAISED)', 'DIVIDED - W/MEDIAN BARRIER') ~ 'DIVIDED ROAD',
#       TRAFFICWAY_TYPE %in% c('NOT DIVIDED') ~ 'UNDIVIDED ROAD',
#       TRAFFICWAY_TYPE %in% c('FOUR WAY', 'T-INTERSECTION', 'FIVE POINT, OR MORE', 'Y-INTERSECTION', 'L-INTERSECTION', 'ROUNDABOUT') ~ 'INTERSECTION',
#       TRAFFICWAY_TYPE %in% c('ALLEY', 'PARKING LOT', 'DRIVEWAY', 'RAMP') ~ 'ACCESS AREA',
#       TRAFFICWAY_TYPE %in% c('ONE-WAY', 'TRAFFIC ROUTE', 'CENTER TURN LANE') ~ 'STANDARD ROAD',
#       TRUE ~ 'OTHER'
#     )
#   ) |>
#   filter(!is.na(zip)) |>
#   st_drop_geometry() |>
#   filter(if_all(everything(), ~ !is.na(.)))
# 
# model_df <- all_year_df |>
#   filter(YEAR %in% c(2019:2024))

#write.csv(model_df, 'data/model_df.csv', row.names = FALSE)


