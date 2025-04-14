# Leaflet plot of all severe crash accidents
leaflet_plot <- function(model_data, spatial_data){
  
  df <- model_data |>
    group_by(zip, severe) |>
    summarize(
      severe_count = n()
    ) |>
    filter(severe == 1) |>
    ungroup()
  df$zip <- as.character(df$zip)
  spatial_data$zip <- as.character(spatial_data$zip)
  df <- left_join(spatial_data, df, by = 'zip')
  
  
  pal <- colorNumeric('YlOrRd', domain = df$severe_count, na.color = 'transparent')
  leaflet(df) |>
    addTiles() |>
    addPolygons(
      fillColor = ~pal(severe_count),
      weight = 1,
      opacity = 1,
      color = 'black',
      fillOpacity = 0.7,
      highlight = highlightOptions(
        weight = 3,
        color = 'white',
        bringToFront = TRUE
      ),
      popup = ~paste0('<b>ZIP: </b>', zip, '<br>',
                      '<b>Crashes: </b>', severe_count, '<br>'),
      labelOptions = labelOptions(
        style = list('font-weight' = 'bold', 'color' = 'black')
      )
    ) |>
    addLegend(
      pal = pal,
      values = df$severe_count,
      title = 'Severe Crashes',
      position = 'topright'
    )
}

# Plot total number of accidents vs percentage of severe crashes
bar_circle_plot <- function(data) {
  
  df <- data |> 
    group_by(YEAR) |> 
    summarise(
      total_crashes = n(), 
      severe_crashes = sum(severe == 1)) |> 
    mutate(pct_change = severe_crashes / total_crashes)
  
  ggplot(df, aes(x = YEAR)) +
    geom_col(aes(y = total_crashes), fill = '#56A0D3') +
    geom_point(aes(y = pct_change * max(total_crashes)), color = 'firebrick', size = 3.5) +
    scale_y_continuous(
      name = 'Total Crashes',
      sec.axis = sec_axis(~ . / max(df$total_crashes), name = '% of Crashes That Were Severe', labels = scales::percent_format(accuracy = 0.1))
    ) +
    labs(
      x = 'Year',
      caption = 'Shaded bars = total crashes | Red line = % of crashes that were severe'
    ) +
    theme_minimal() +
    theme(
      axis.title.y.right = element_text(color = 'firebrick'),
      axis.text.y.right = element_text(color = 'firebrick', face = 'bold'),
      axis.title.y.left = element_text(color = '#56A0D3', face = 'bold')
    )
}

facet_lollipop_plot <- function(data) {
  
  condition_vars <- c('TRAFFIC_CONTROL_DEVICE', 'DEVICE_CONDITION', 'WEATHER_CONDITION', 
                      'LIGHTING_CONDITION', 'ROADWAY_SURFACE_COND', 'TRAFFICWAY_TYPE')
  
  long_df <- data |>
    select(all_of(c('severe', condition_vars))) |>
    pivot_longer(cols = -severe, names_to = 'condition_type', values_to = 'condition_value') |>
    filter(!is.na(condition_value))
  
  
  plot_df <- long_df |>
    group_by(condition_type, condition_value) |>
    summarise(
      total = n(),
      severe_sum = sum(as.numeric(severe) == 1),
      .groups = 'drop'
    ) |>
    mutate(
      percent_severe = round((severe_sum / total) * 100, 2),
      condition_type = recode(condition_type,
                              'TRAFFIC_CONTROL_DEVICE' = 'Traffic Control',
                              'DEVICE_CONDITION' = 'Device Status',
                              'WEATHER_CONDITION' = 'Weather',
                              'LIGHTING_CONDITION' = 'Lighting',
                              'ROADWAY_SURFACE_COND' = 'Road Surface',
                              'TRAFFICWAY_TYPE' = 'Road Type'
      )
    )
  
  ggplot(plot_df, aes(x = reorder(condition_value, percent_severe), y = percent_severe)) +
    geom_col(fill = '#1D7DBD') +
    facet_wrap(~ condition_type, scales = 'free_x', strip.position = 'top') +
    geom_hline(yintercept = 2.67, linetype = 'dashed', color = 'black') +
    scale_y_continuous(labels = scales::label_percent(scale = 1)) +
    labs(
      title = 'Crash Severity Rate by Condition Category',
      y = '% of Crashes That Were Severe',
      x = 'Condition Type'
    ) +
    theme_minimal(base_size = 13) +
    # theme(
    #   strip.background = element_rect(fill = 'gray85', color = 'gray80'),
    #   strip.text = element_text(face = 'bold', size = 13),
    #   axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
    #   panel.spacing = unit(1, 'lines'),
    #   plot.title = element_text(face = 'bold', hjust = 0.5)
    # )
    theme(
      strip.background = element_rect(fill = 'gray85', color = 'gray80'),
      strip.text = element_text(face = 'bold', size = 13),
      axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
      panel.spacing = unit(2, 'lines'),
      plot.margin = margin(20, 20, 40, 20),
      plot.title = element_text(face = 'bold', hjust = 0.5)
    )
}

facet_lollipop_plot(model_df)

