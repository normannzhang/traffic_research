library(ggplot2)
library(dplyr)
library(stringr)

# Generate summary statistics for crashes in general
total_crashes_df <- function(data) {
  total_crashes <- nrow(data)
  severe_crashes <- sum(data$MOST_SEVERE_INJURY %in% c("FATAL", "INCAPACITATING INJURY"))
  fatalities <- sum(data$INJURIES_FATAL, na.rm = TRUE)
  
  return(list(total = total_crashes, severe = severe_crashes, fatalities = fatalities))
}

# Generate summary statistics for crashes per year
year_crashes_df <- function(data) {
  data |>
    group_by(YEAR) |>
    summarize(
      total_crashes = n(),
      severe_crashes = sum(MOST_SEVERE_INJURY %in% c("FATAL", "INCAPACITATING INJURY"), na.rm = TRUE),
      total_fatalities = sum(as.numeric(INJURIES_FATAL), na.rm = TRUE)
    )
}

# Generate summary statistics for crashes based on road conditions
road_condition_df <- function(data){
  data |>
    group_by(ROADWAY_SURFACE_COND) |>
    summarize(
      total_crashes = n(),
      severe_crashes = sum(MOST_SEVERE_INJURY %in% c("FATAL", "INCAPACITATING INJURY"), na.rm = TRUE),
      total_fatalities = sum(as.numeric(INJURIES_FATAL), na.rm = TRUE)
    )
}

# Generate summary statistics for crashes based on traffic controls
traffic_control_df <- function(data){
  data |>
    group_by(TRAFFIC_CONTROL_DEVICE) |>
    summarize(
      total_crashes = n(),
      severe_crashes = sum(MOST_SEVERE_INJURY %in% c("FATAL", "INCAPACITATING INJURY"), na.rm = TRUE),
      total_fatalities = sum(as.numeric(INJURIES_FATAL), na.rm = TRUE)
    )
}

facet_crash_data <- function(data) {
  
  yearly_data <- year_crashes_df(data) |> 
    mutate(category = "Yearly Crashes", variable = as.character(YEAR)) |> 
    rename(value = total_crashes) |> 
    select(category, variable, value)
  
  road_data <- road_condition_df(data) |> 
    mutate(category = "Road Conditions", variable = as.character(ROADWAY_SURFACE_COND)) |> 
    rename(value = total_crashes) |> 
    select(category, variable, value)
  
  control_data <- traffic_control_df(data) |> 
    mutate(category = "Traffic Control", variable = as.character(TRAFFIC_CONTROL_DEVICE)) |> 
    rename(value = total_crashes) |> 
    select(category, variable, value)
  
  combined <- bind_rows(yearly_data, road_data, control_data)
  
  return(combined)
}

