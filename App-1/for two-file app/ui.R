library(shiny)
library(shinydashboard)
header <- dashboardHeader(
  title = "Linking health indicators to pollutants"
)
body <- dashboardBody(
  fluidRow(
    column(width = 9,
           box(width = NULL,
               uiOutput("plot"))),
    column(width = 3,
           box(width = NULL, status = "warning",
               uiOutput("health_var"),
               uiOutput("")
))))

dashboardPage(
  header,
  dashboardSidebar(disable = TRUE),
  body
)