# Preprocess data to remove any cases without exact location coordinates
cleaned_traffic_df <- traffic_df |> 
  filter(LOCATION != "") |>
  select(MOST_SEVERE_INJURY, INJURIES_TOTAL, INJURIES_FATAL, INJURIES_INCAPACITATING, INJURIES_NON_INCAPACITATING,
         TRAFFIC_CONTROL_DEVICE, DEVICE_CONDITION, ROADWAY_SURFACE_COND, ALIGNMENT, TRAFFICWAY_TYPE,
         WEATHER_CONDITION, LIGHTING_CONDITION, POSTED_SPEED_LIMIT, PRIM_CONTRIBUTORY_CAUSE, SEC_CONTRIBUTORY_CAUSE,
         LATITUDE, LONGITUDE, CRASH_HOUR, CRASH_DAY_OF_WEEK, CRASH_MONTH)

summary(cleaned_traffic_df)
colSums(is.na(cleaned_traffic_df))
# Create line plot of total accidents of each year from 2015 to 2024
### FIX TOMORROW, MAKE ANOTHER PARAMETER INSIDE FUNCTION THAT ALLOWS USER TO JUST SEE HOW MANY FATAL AND TOTAL FATALITIES THERE ARE CAUSE SCALING ISSUE.
line_accidents <- function(data){
  df <- year_crashes_df(data) |>
    pivot_longer(cols = -YEAR, names_to = 'crash_type', values_to = 'count')
  
  pal <- c(
    "total_crashes" = "#003366",
    "severe_crashes" = "#B3DDF2",
    "total_fatalities" = "#FF0000"
  )
  
  ggplot(df, aes(x = YEAR, y = count, color = crash_type, group = crash_type)) +
    geom_line(size = 1.2) + 
    geom_point(size = 3) +
    scale_color_manual(values = pal) +
    labs(
      title = "Traffic Crashes in Chicago (2015-2024)",
      x = "Year",
      y = "Count of Crashes",
      color = "Crash Type"
    ) +
    theme_minimal() +  # Clean modern theme
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1),
      plot.title = element_text(size = 16, face = "bold"),
      legend.position = "top"
    )
  
}

line_accidents(traffic_df)
# Create Leaflet plot of total accidents of all years
leaflet_accidents <-  function(data, severity, traffic_control){
  filter_df <- data |>
    filter(MOST_SEVERE_INJURY == severity,
           TRAFFIC_CONTROL_DEVICE == traffic_control)
  
  leaflet(filter_df) |>
    setView(lng = -87.6298, lat = 41.8781, zoom = 11) |>
    addTiles() |>
    addCircleMarkers(
      ~LONGITUDE, ~LATITUDE,
      color = 'red',
      radius = 4,
      stroke = FALSE,
      fillOpacity = 0.7,
      popup = ~paste('<b>Crash Severity:</b>', MOST_SEVERE_INJURY, '<br>')
    )
}

leaflet_plot <- function(zip_data, crash_data){
  zip_data <- left_join(zip_data, crash_data, by = "zip")
  pal <- colorNumeric("YlOrRd", domain = zip_data$crash_count, na.color = "transparent")
  leaflet(zip_data) |>
    addTiles() |>
    addPolygons(
      fillColor = ~pal(crash_count),
      weight = 1,
      opacity = 1,
      color = "black",
      fillOpacity = 0.7,
      highlight = highlightOptions(
        weight = 3,
        color = "white",
        bringToFront = TRUE
      ),
      popup = ~paste0("<b>ZIP: </b>", zip, '<br>',
                      "<b>Crashes: </b>", crash_count, '<br>'),
      labelOptions = labelOptions(
        style = list('font-weight' = 'bold', 'color' = 'black')
      )
    ) |>
    addLegend(
      pal = pal,
      values = zip_data$crash_count,
      title = 'Crash Count',
      position = 'topright'
    )
}

leaflet_plot(zip_codes, crash_df)

