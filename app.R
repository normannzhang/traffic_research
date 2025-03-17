library(shiny)
library(bs4Dash)

ui <- dashboardPage(
  dashboardHeader(
    title = tagList(
      icon("car-crash"), 
      span("Chicago Crash Dashboard", style = "font-size: 18px;")
    )
  ),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Welcome", tabName = "welcome", icon = icon("home")),
      menuItem("Analysis", tabName = "analysis", icon = icon("chart-bar")),  # Fixed
      menuItem("Map", tabName = "map", icon = icon("map-marker-alt")),
      menuItem("Help", tabName = "help", icon = icon("info-circle"))
    )
  ),
  dashboardBody(
    tabItems(  # This was missing, it's required to match `tabName`
      tabItem(tabName = "welcome",
              h2("Welcome to the Chicago Crash Dashboard"),
              p("This dashboard provides insights into traffic accidents in Chicago.")
      ),
      tabItem(tabName = "analysis",
              fluidRow(
                box(
                  title = "Traffic Accident Histogram", 
                  width = 12,
                  plotOutput("plot1", height = "70vh")
                )
              ),
              fluidRow(
                box(
                  title = "Controls",
                  width = 12,
                  sliderInput("slider", "Number of observations:", 1, 100, 50)
                )
              )
      ),
      tabItem(tabName = "map",
              h2("Traffic Accident Map"),
              p("A map visualization will go here.")
      ),
      tabItem(tabName = "help",
              h2("How to Use This Dashboard"),
              p("1. Go to 'Analysis' for data visualizations."),
              p("2. Use the 'Map' tab to explore crash locations."),
              p("3. Adjust filters to refine your analysis.")
      )
    )
  )
)

server <- function(input, output) {
  set.seed(122)
  histdata <- rnorm(500)
  
  output$plot1 <- renderPlot({
    data <- histdata[seq_len(input$slider)]
    hist(data)
  })
}

shinyApp(ui, server)