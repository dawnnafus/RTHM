library(shiny)
library(rsconnect)


# Use Shiny Library for inputs and outputs
# shinyapps.io - a free server
ui <- fluidPage(
  sliderInput(inputId = "num", label= "Choose a number",
              value=25, min =1, max = 1000),
  plotOutput(outputId = "hist")
)

server <- function(input, output){
  # 1. Save output you build to output$
  # 2. Build the output with a render*() function
  # 3. Access input values with input$
  output$hist <- renderPlot({ hist(rnorm(input$num))
    
  # can put an entire R code in these braces
    })
  
}
# Can a user input data for use on Shiny?
# rhandsontable package or shinyTable
shinyApp(ui = ui, server = server)