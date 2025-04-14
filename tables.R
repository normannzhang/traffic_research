# Generate summary statistics of most of the different types of crash conditions
summary_statistics <- function(data) {
  specific_df <- data |> 
    st_drop_geometry() |> 
    select(ROADWAY_SURFACE_COND, PRIM_CONTRIBUTORY_CAUSE, WEATHER_CONDITION, 
           ROAD_DEFECT, TRAFFIC_CONTROL_DEVICE, DEVICE_CONDITION, 
           INTERSECTION_RELATED_I, LIGHTING_CONDITION, POSTED_SPEED_LIMIT)
  proportion_list <- lapply(specific_df, function(x) {
    prop_table <- prop.table(table(x)) * 100  
    df <- data.frame(Value = names(prop_table), Proportion = as.numeric(prop_table))
    other_sum <- sum(df$Proportion[df$Proportion < 2])
    df <- df |> filter(Proportion >= 2)  
    if (other_sum > 0) {
      df <- bind_rows(df, data.frame(Value = "Other", Proportion = other_sum))
    }
    return(df)
  })
  proportion_df <- bind_rows(proportion_list, .id = "Category")
  
  return(proportion_df)
  
}

# Generate Relative Risk ratio table of values for severe vs non-severe crashes
severity_data <- function(data){
  relevant_vars <- c(
    'TRAFFIC_CONTROL_DEVICE', 'ROADWAY_SURFACE_COND',
    'LIGHTING_CONDITION', 'WEATHER_CONDITION'
  )
  
  severity_df <- data |> 
    mutate(
      severity = case_when(
        MOST_SEVERE_INJURY %in% c('FATAL', 'INCAPACITATING INJURY') ~ 'Severe',
        TRUE ~ 'Non-Severe'
      )
    )
  
  long_df <- lapply(relevant_vars, function(var){
    severity_df |> 
      filter(!is.na(.data[[var]]), .data[[var]] != '') |>
      group_by(Category = var, severity, Condition = .data[[var]]) |> 
      summarise(Count = n(), .groups = 'drop') |> 
      group_by(Category, severity) |> 
      mutate(Proportion = Count / sum(Count))
  }) |> bind_rows()
  
  long_df <- long_df |> 
    mutate(
      Proportion = round(Proportion, 4)
    ) |>
    filter(Count >= 100)
  
  wide_df <-  long_df |> 
    select(-Count) |> 
    distinct() |> 
    pivot_wider(names_from = severity, 
                values_from = Proportion) |> 
    mutate(
      ratio = round(Severe/`Non-Severe`, digits = 4)
    ) |>
    arrange(desc(ratio)) |>
    filter(!(Condition %in% c('UNKNOWN', 'OTHER')))
  
  return(wide_df)
  
}

