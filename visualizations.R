plot_facet_crashes <- function(data) {
  crash_data <- facet_crash_data(data)
  
  ggplot(crash_data, aes(x = variable, y = value, fill = category)) +
    geom_bar(stat = "identity") +
    facet_rep_wrap(~ category, scales = "free", ncol = 2) +
    theme_minimal() +
    theme(
      axis.text.x = element_blank(),
      axis.ticks.x = element_blank(),
      strip.text = element_text(size = 12, face = "bold")
    ) +
    labs(title = "Traffic Crash Breakdown Across Key Factors",
         y = "Total Crashes",
         x = NULL) +
    scale_fill_viridis_d()
}

plot_facet_crashes(traffic_df)

# Preprocess data to remove any cases without exact location coordinates
cleaned_traffic_df <- traffic_df |> 
  filter(LOCATION != "") |>
  select(MOST_SEVERE_INJURY, INJURIES_TOTAL, INJURIES_FATAL, INJURIES_INCAPACITATING, INJURIES_NON_INCAPACITATING,
         TRAFFIC_CONTROL_DEVICE, DEVICE_CONDITION, ROADWAY_SURFACE_COND, ALIGNMENT, TRAFFICWAY_TYPE,
         WEATHER_CONDITION, LIGHTING_CONDITION, POSTED_SPEED_LIMIT, PRIM_CONTRIBUTORY_CAUSE, SEC_CONTRIBUTORY_CAUSE,
         LATITUDE, LONGITUDE, CRASH_HOUR, CRASH_DAY_OF_WEEK, CRASH_MONTH)

summary(cleaned_traffic_df)
colSums(is.na(cleaned_traffic_df))

leaflet_plot <-  function(data, severity, traffic_control){
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