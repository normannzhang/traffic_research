library(shiny)
library(bs4Dash)
library(leaflet)
library(leaflet.extras)
library(dplyr)
library(sf)
library(ggplot2)
library(stringr)
library(lemon)
library(packcircles)
library(tidyr)
library(shinyWidgets)
library(xgboost)
library(glue)
library(reticulate)

source('init.R')
source('visualizations.R')

ui <- dashboardPage(
  dashboardHeader(
    title = tagList(
      icon('city'), 
      span('Chicago Crash Dashboard', style = 'font-size: 18px;')
    )
  ),
  dashboardSidebar(
    sidebarMenu(
      menuItem('Background', tabName = 'background', icon = icon('home')),
      menuItem('Risk Model', tabName = 'risk_model', icon = icon('car-crash')),
      menuItem('ZIP-Level Risk', tabName = 'zip_risk', icon = icon('map-pin')),
      menuItem('Help/About', tabName = 'help', icon = icon('info-circle'))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = 'background',
              fluidRow(
                column(
                  width = 12,
                  div(
                    style = 'text-align: center; background-color: #87CEEB; color: white; padding: 20px; border-radius: 10px;',
                    h1('Mapping and Modeling Severe Crash Risk in Chicago'),
                    h4('Using Historical Crash Data to Identify Dangerous Conditions and Inform Targeted Policy Action')
                  )
                )
              ),
              br(),
              fluidRow(
                bs4ValueBox(
                  value = 'Total Crashes',
                  subtitle = HTML("<span style='font-size: 1.3rem; font-weight: 500;'>199731</span>"),
                  icon = icon('car-crash'),
                  color = 'primary',
                  width = 3
                ),
                bs4ValueBox(
                  value = 'Fatal and Incapacitating Crashes',
                  subtitle = HTML("<span style='font-size: 1.3rem; font-weight: 500;'>5056</span>"),
                  icon = icon('exclamation-triangle'),
                  color = 'danger',
                  width = 3
                ),
                bs4ValueBox(
                  value = 'Severe Crash Rate',
                  subtitle = HTML("<span style='font-size: 1.3rem; font-weight: 500;'>2.53%</span>"),
                  icon = icon('percent'),
                  color = 'warning',
                  width = 3
                ),
                bs4ValueBox(
                  value = 'Top At-Risk ZIP Code',
                  subtitle = HTML("<span style='font-size: 1.3rem; font-weight: 500;'>60619</span>"),
                  icon = icon('map-marker-alt'),
                  color = 'info',
                  width = 3
                )
              ),
              fluidRow(
                bs4Card(
                  width = 4,
                  status = 'primary',
                  solidHeader = TRUE,
                  closable = FALSE,
                  maximizable = FALSE,
                  title = 'Certain Areas Carry a Disproportionate Risk',
                  style = "height: 540px; display: flex; align-items: center; justify-content: center;",
                  div(style = "height: 100%; width: 100%; display: flex; align-items: center; justify-content: center;",
                      tags$img(src = 'home_page1.png', style = "width: 100%; height: auto; object-fit: contain;")
                  )
                ),
                bs4Card(
                  width = 8,
                  status = 'danger',
                  solidHeader = TRUE,
                  title = 'Total Severe Accidents in Chicago by ZIP (2019-2024)',
                  leafletOutput('choropleth_map', height = '500px')
                )
              ),
              br(),
              fluidRow(
                bs4Card(
                  width = 6,
                  status = 'primary',
                  solidHeader = TRUE,
                  closable = FALSE,
                  maximizable = FALSE,
                  title = 'Severity Has Stayed High, Even as Crashes Rise',
                  style = "height: 540px; display: flex; align-items: center; justify-content: center; overflow: hidden;",
                  div(style = "height: 50%; width: 100%; display: flex; align-items: center; justify-content: center;",
                      tags$img(src = "home_page2.png", style = "width: 110%; height: 100%; object-fit: contain;")
                  )
                ),
                bs4Card(
                  width = 6,
                  status = 'primary',
                  solidHeader = TRUE,
                  closable = FALSE,
                  maximizable = FALSE,
                  title = 'Trend of Crash Severity in Chicago (2019-2024)',
                  plotOutput('combo_plot', height = '500px')
                )
              ),
              fluidRow(
                bs4Card(
                  width = 12,
                  status = 'danger',
                  solidHeader = TRUE,
                  closable = FALSE,
                  maximizable = FALSE,
                  title = 'Identifying High-Risk Crash Conditions',
                  style = "height: 300px; display: flex; align-items: center; justify-content: center; overflow: hidden;",
                  div(style = "height: 100%; width: 200%; display: flex; align-items: center; justify-content: center;",
                      tags$img(src = "home_page3.png", style = "width: 200%; height: 100%; object-fit: contain;")
                  )
                )
              ),
              br(),
              fluidRow(
                bs4Card(
                  width = 9,
                  status = 'primary',
                  solidHeader = TRUE,
                  closable = FALSE,
                  maximizable = FALSE,
                  title = 'Crash Severity Rate by Condition Category',
                  plotOutput('lollipop_plot', height = '1200px')
                ),
                bs4Card(
                  width = 3,
                  status = 'primary',
                  solidHeader = TRUE,
                  closable = FALSE,
                  maximizable = FALSE,
                  title = 'Conditions Most Associated with Severity',
                  style = "height: 1240px; display: flex; align-items: center; justify-content: center; overflow: hidden;",
                  div(style = "height: 100%; width: 100%; display: flex; align-items: center; justify-content: center;",
                      tags$img(src = "home_page4.png", style = "width: 110%; height: 100%; object-fit: contain;")
                  )
                )
              ),
              fluidRow(
                bs4Card(
                  width = 12,
                  status = 'primary',
                  solidHeader = TRUE,
                  closable = FALSE,
                  maximizable = FALSE,
                  title = 'Conditions Most Associated with Severity',
                  style = "height: 300px; display: flex; align-items: center; justify-content: center; overflow: hidden;",
                  div(style = "height: 100%; width: 100%; display: flex; align-items: center; justify-content: center;",
                      tags$img(src = "home_page5.png", style = "width: 110%; height: 100%; object-fit: contain;")
                  )
                )
              )
      ),
      tabItem(tabName = "risk_model",
              fluidRow(
                column(
                  width = 12,
                  div(
                    style = 'text-align: center; background-color: #87CEEB; color: white; padding: 20px; border-radius: 10px;',
                    h1("Crash Severity Risk Model"),
                    h4("Predicting Likelihood of Severe Crashes Based on Road, Environmental, and Infrastructure Conditions")
                  )
                )
              ),
              br(),
              fluidRow(
                bs4Card(
                  width = 12,
                  status = 'primary',
                  solidHeader = TRUE,
                  closable = FALSE,
                  maximizable = FALSE,
                  title = 'Traffic Accidents in Chicago',
                  style = "height: 100px; display: flex; align-items: center; justify-content: center; overflow: hidden;",
                  div(style = "height: 100%; width: 200%; display: flex; align-items: center; justify-content: center;",
                      tags$img(src = "risk_model1.png", style = "width: 110%; height: 100%; object-fit: contain;")
                  )
                )
              ),
              fluidRow(
                bs4Card(
                  title = 'Select Crash Conditions',
                  width = 6,
                  solidHeader = TRUE,
                  style = "background-color: #B3DDF2; color: black;",
                  selectInput('TRAFFIC_CONTROL_DEVICE', 'Traffic Control Device:',
                              choices = levels(smote_data$TRAFFIC_CONTROL_DEVICE)),
                  selectInput('DEVICE_CONDITION', 'Device Condition:',
                              choices = levels(smote_data$DEVICE_CONDITION)),
                  selectInput('WEATHER_CONDITION', 'Weather Condition:',
                              choices = levels(smote_data$WEATHER_CONDITION)),
                  selectInput('LIGHTING_CONDITION', 'Lighting Condition:',
                              choices = levels(smote_data$LIGHTING_CONDITION)),
                  selectInput('FIRST_CRASH_TYPE', 'First Crash Type:',
                              choices = levels(smote_data$FIRST_CRASH_TYPE)),
                  selectInput('TRAFFICWAY_TYPE', 'Trafficway Type:',
                              choices = levels(smote_data$TRAFFICWAY_TYPE)),
                  selectInput('ROADWAY_SURFACE_COND', 'Roadway Surface Condition:',
                              choices = levels(smote_data$ROADWAY_SURFACE_COND)),
                  selectInput('zip', 'ZIP Code:',
                              choices = levels(smote_data$zip)),
                  selectInput('POSTED_SPEED_LIMIT', ' Speed Limit Range:',
                              choices = levels(smote_data$POSTED_SPEED_LIMIT))
                ),
                bs4Card(
                  title = 'Prediction Result',
                  width = 6,
                  status = 'warning',
                  solidHeader = TRUE,
                  background = 'orange',
                  uiOutput('prediction')
                )
              )
      ),
      tabItem(tabName = "zip_risk",
              fluidRow(
                column(
                  width = 12,
                  div(
                    style = 'text-align: center; background-color: #87CEEB; color: white; padding: 20px; border-radius: 10px;',
                    h1('ZIP-Level Crash Severity Mapping'),
                    h4('Visualizing Predicted Crash Risk Across Chicago ZIP Codes Based on Selected Conditions'),
                    br()
                  )
                )
              ),
              fluidRow(
                bs4Card(
                  title = 'Select Crash Conditions (Excludes ZIP)',
                  width = 4,
                  solidHeader = TRUE,
                  style = "background-color: #B3DDF2; color: black;",
                  selectInput('RM_TRAFFIC_CONTROL_DEVICE', 'Traffic Control Device:',
                              choices = levels(smote_data$TRAFFIC_CONTROL_DEVICE)),
                  selectInput('RM_DEVICE_CONDITION', 'Device Condition:',
                              choices = levels(smote_data$DEVICE_CONDITION)),
                  selectInput('RM_WEATHER_CONDITION', 'Weather Condition:',
                              choices = levels(smote_data$WEATHER_CONDITION)),
                  selectInput('RM_LIGHTING_CONDITION', 'Lighting Condition:',
                              choices = levels(smote_data$LIGHTING_CONDITION)),
                  selectInput('RM_FIRST_CRASH_TYPE', 'First Crash Type:',
                              choices = levels(smote_data$FIRST_CRASH_TYPE)),
                  selectInput('RM_TRAFFICWAY_TYPE', 'Trafficway Type:',
                              choices = levels(smote_data$TRAFFICWAY_TYPE)),
                  selectInput('RM_ROADWAY_SURFACE_COND', 'Roadway Surface Condition:',
                              choices = levels(smote_data$ROADWAY_SURFACE_COND)),
                  selectInput('RM_POSTED_SPEED_LIMIT', 'Posted Speed Limit:',
                              choices = levels(smote_data$POSTED_SPEED_LIMIT)),
                  actionButton('predict_zip_map', 'Predict ZIP Risk', class = 'btn btn-danger')
                ),
                bs4Card(
                  title = 'Predicted Crash Severity Risk by ZIP',
                  width = 8,
                  status = 'danger',
                  solidHeader = TRUE,
                  leafletOutput('zip_risk_map', height = '900px')
                )
              )
      ),
      tabItem(
        tabName = 'help',
        tags$div(
          style = 'text-align:center; padding:0; margin:0;',
          tags$img(
            src = 'about_page.png',
            style = 'width:100%; height:2000; max-width:100%;'
          )
        )
      )
    )
  )
)

server <- function(input, output) {
  
  # Predict severity risks for specific zip and conditions
  make_prediction <- function() {
    input_vector <- c(
      enc$TRAFFIC_CONTROL_DEVICE[[input$TRAFFIC_CONTROL_DEVICE]],
      enc$DEVICE_CONDITION[[input$DEVICE_CONDITION]],
      enc$WEATHER_CONDITION[[input$WEATHER_CONDITION]],
      enc$LIGHTING_CONDITION[[input$LIGHTING_CONDITION]],
      enc$FIRST_CRASH_TYPE[[input$FIRST_CRASH_TYPE]],
      enc$TRAFFICWAY_TYPE[[input$TRAFFICWAY_TYPE]],
      enc$ROADWAY_SURFACE_COND[[input$ROADWAY_SURFACE_COND]],
      zip_map[[input$zip]],
      enc$POSTED_SPEED_LIMIT[[input$POSTED_SPEED_LIMIT]]
    )
    
    py_run_string(glue::glue("
import pandas as pd

columns = [
    'TRAFFIC_CONTROL_DEVICE', 'DEVICE_CONDITION', 'WEATHER_CONDITION',
    'LIGHTING_CONDITION', 'FIRST_CRASH_TYPE', 'TRAFFICWAY_TYPE',
    'ROADWAY_SURFACE_COND', 'zip', 'POSTED_SPEED_LIMIT'
]

data = [[{paste(input_vector, collapse = ', ')}]]
df = pd.DataFrame(data, columns=columns)
pred_prob = rf_model.predict_proba(df)[0][1]
"))
    
    prob <- py$pred_prob
    severity <- if (prob < 0.05) 'Low Risk' else if (prob < 0.15) 'Moderate Risk' else 'High Risk'
    
    output$prediction <- renderUI({
      tagList(
        h4(paste0('Estimated Risk: ', round(prob * 100, 2), '%')),
        h5(paste('Severity Category:', severity)),
        br()
      )
    })
  }
  
  # Predict all zip codes for choropleth for given conditions
  generate_zip_map <- function(input_values) {
    all_zips <- sort(unique(model_df$zip))
    
    input_matrix <- lapply(all_zips, function(z) {
      c(
        enc$TRAFFIC_CONTROL_DEVICE[[trimws(input_values$TRAFFIC_CONTROL_DEVICE)]],
        enc$DEVICE_CONDITION[[trimws(input_values$DEVICE_CONDITION)]],
        enc$WEATHER_CONDITION[[trimws(input_values$WEATHER_CONDITION)]],
        enc$LIGHTING_CONDITION[[trimws(input_values$LIGHTING_CONDITION)]],
        enc$FIRST_CRASH_TYPE[[trimws(input_values$FIRST_CRASH_TYPE)]],
        enc$TRAFFICWAY_TYPE[[trimws(input_values$TRAFFICWAY_TYPE)]],
        enc$ROADWAY_SURFACE_COND[[trimws(input_values$ROADWAY_SURFACE_COND)]],
        zip_map[[as.character(z)]],
        enc$POSTED_SPEED_LIMIT[[trimws(input_values$POSTED_SPEED_LIMIT)]]
      )
    })
    
    zip_df <- do.call(rbind, input_matrix)
    zip_list_str <- apply(zip_df, 1, function(row) paste(row, collapse = ", "))
    zip_str <- paste0("[", paste0("[" , zip_list_str, "]", collapse = ", "), "]")
    
    py_run_string(glue::glue("
import pandas as pd

columns = [
    'TRAFFIC_CONTROL_DEVICE', 'DEVICE_CONDITION', 'WEATHER_CONDITION',
    'LIGHTING_CONDITION', 'FIRST_CRASH_TYPE', 'TRAFFICWAY_TYPE',
    'ROADWAY_SURFACE_COND', 'zip', 'POSTED_SPEED_LIMIT'
]

data = {zip_str}
df = pd.DataFrame(data, columns=columns)
probs = rf_model.predict_proba(df)[:, 1].tolist()
"))
    
    pred_results <- data.frame(zip = all_zips, prob = unlist(py$probs))
    pred_results$zip <- as.character(pred_results$zip)
    
    zip_map_data <- left_join(zip_codes, pred_results, by = 'zip')
    
    leaflet(zip_map_data) |>
      addProviderTiles('CartoDB.Positron') |>
      addPolygons(
        fillColor = ~colorNumeric('YlOrRd', domain = c(0, 100))(prob * 100),
        color = '#444444',
        weight = 1,
        fillOpacity = 0.75,
        popup = ~paste0('<b>ZIP: </b>', zip, '<br>',
                        '<b>Risk: </b>', round(prob * 100, 2), '%'),
        highlightOptions = highlightOptions(color = 'white', weight = 2, bringToFront = TRUE)
      ) |>
      addLegend(
        pal = colorNumeric('YlOrRd', domain = c(0, 100)),
        values = zip_map_data$prob * 100,
        title = 'Severe Crash Risk (%)',
        labFormat = labelFormat(suffix = '%'),
        opacity = 1
      )
  }
  
  observe({
    make_prediction()
  })
  
  observe({
    default_inputs <- list(
      TRAFFIC_CONTROL_DEVICE = levels(smote_data$TRAFFIC_CONTROL_DEVICE)[1],
      DEVICE_CONDITION = levels(smote_data$DEVICE_CONDITION)[1],
      WEATHER_CONDITION = levels(smote_data$WEATHER_CONDITION)[1],
      LIGHTING_CONDITION = levels(smote_data$LIGHTING_CONDITION)[1],
      FIRST_CRASH_TYPE = levels(smote_data$FIRST_CRASH_TYPE)[1],
      TRAFFICWAY_TYPE = levels(smote_data$TRAFFICWAY_TYPE)[1],
      ROADWAY_SURFACE_COND = levels(smote_data$ROADWAY_SURFACE_COND)[1],
      POSTED_SPEED_LIMIT = levels(smote_data$POSTED_SPEED_LIMIT)[1]
    )
    
    output$zip_risk_map <- renderLeaflet({
      generate_zip_map(default_inputs)
    })
  })
  
  observeEvent(input$predict_zip_map, {
    selected_inputs <- list(
      TRAFFIC_CONTROL_DEVICE = input$RM_TRAFFIC_CONTROL_DEVICE,
      DEVICE_CONDITION = input$RM_DEVICE_CONDITION,
      WEATHER_CONDITION = input$RM_WEATHER_CONDITION,
      LIGHTING_CONDITION = input$RM_LIGHTING_CONDITION,
      FIRST_CRASH_TYPE = input$RM_FIRST_CRASH_TYPE,
      TRAFFICWAY_TYPE = input$RM_TRAFFICWAY_TYPE,
      ROADWAY_SURFACE_COND = input$RM_ROADWAY_SURFACE_COND,
      POSTED_SPEED_LIMIT = input$RM_POSTED_SPEED_LIMIT
    )
    
    output$zip_risk_map <- renderLeaflet({
      generate_zip_map(selected_inputs)
    })
  })
  
  output$choropleth_map <- renderLeaflet({
    leaflet_plot(model_df, zip_codes)
  })
  
  output$combo_plot <- renderPlot({
    bar_circle_plot(model_df)
  })
  
  output$lollipop_plot <- renderPlot({
    req(model_df)
    facet_lollipop_plot(model_df)
  })
  
}

shinyApp(ui, server)