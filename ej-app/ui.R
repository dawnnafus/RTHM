# Set-up

# List of R packages
required_pkg <- c("tidyverse","maptools", "rgdal", 
                  "spatstat", "ggmap", "geosphere", 
                  "leaflet", "spdep", "sp", "shinydashboard")
#pkgs_not_installed <- required_pkg[!sapply(required_pkg, function(p) require(p, character.only=T))]
#install.packages(pkgs_not_installed, dependencies=TRUE)

# Load all libraries at once.
lapply(required_pkg, library, character.only = TRUE)

## Shiny Code

header <- dashboardHeader(
    title = "Fair Tech Collective Dashboard"
  )
  
sidebar <-  dashboardSidebar(
    sidebarMenu(
      menuItem("ID Map", tabName = "Leafer", icon = icon("map-o")),
      menuItem("Correlation Plot", tabName = "Correlation", icon = icon("dashboard")),
      menuItem("Spatial Plot", tabName = "Spatial", icon = icon("map"),
               badgeLabel = "new"),
      menuItem("Cal Enviro Screen", tabName = "ces", icon = icon("map-marker"))
    )
  )
body <- dashboardBody(
    tabItems(
      # First tab content
      tabItem(tabName = "Correlation",
              fluidRow(
                box(
                  plotOutput('plot1', height = 250)
                ),
                box(
                  h3('Selections'),
                  uiOutput('healthSelect'),
                  uiOutput("pollutantSelect")
                ))),
      tabItem(
        tabName = "Spatial",
        fluidRow(
          box(plotOutput('plot_spatial', height = 250)),
          box(h3('Selections'),
              uiOutput('spatialSelect')
          ))),
      tabItem(
        tabName = "ces",
        fluidRow(
          htmlOutput("enviroscreen")
        )),
      tabItem(
        tabName = "Leafer",
        fluidRow(
          box(width = NULL,
              leafletOutput(
                "plotLeaf", width = "75%", height = "500px")),
          box(h3('Filters'),
              sliderInput(
                inputId = "age_range",
                label = "Age Range", min= 0 , max = 100,
                value = c(20,80),
                step = 5),
              sliderInput(
                inputId = "time_in_area",
                label = "Time in Area", min= 0 , max = 100,
                value = c(5,50),
                step = 5),
              checkboxGroupInput(
                inputId = "gender",
                label= "Gender",
                choices = c("male" = "male","female"= "female"),
                selected = c("male", "female")
              ),
              uiOutput('genderSelect'))
        ))
    )
  )

dashboardPage(
  header,
  sidebar,
  body
)