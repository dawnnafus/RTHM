user_id <- round(runif(100, 1, 100))
latitude <- runif(100, 0.0, 90.0)
longitude <- runif(100, 0.0, 180.0)
dates <- rep(c("2014-07-01", "2014-07-02"), each = 50, length = 100)

foo <- data.frame(cbind(user_id, latitude, longitude, dates), stringsAsFactors = FALSE)

# https://stackoverflow.com/questions/25215581/why-is-renderui-necessary-when-you-allow-users-to-upload-a-file-and-filter-data

library(shiny)
library(data.table)
library(plyr)
library(dplyr)
library(ggplot2)

server <- shinyServer(function(input,output) {
  
  ### Let users to choose and upload a file.
  
  dataSet <- reactive({
    if (is.null(input$file1)) {
      return(NULL)
    }
    
    fread(input$file1$datapath)
  })
  
  
  ### Now I want to create a chunk of code which filters a date set using date information
  
  ana <- reactive({
    if (is.null(dataSet)){
      return(NULL)
    }
    
    dataSet() %>%
      filter(dates >= input$inVar2[1], dates <= input$inVar2[2]) %>%
      group_by(user_id, dates) %>%
      summarize(count = n())
    
  })
  
  
  output$theGraph <- renderPlot ({
    
    theGraph <- ggplot(ana(), aes(factor(format(dates, format = "%m%d")), count)) +
      geom_boxplot() +
      xlab("Dates") +
      ylab("Appliacation usage (times)") +
      ggtitle("How many times did each user use the app each day?")
    
    print(theGraph)  
    
    
  })
})

ui <- shinyUI(fluidPage(
  
  titlePanel("Test"),
  
  sidebarLayout(
    sidebarPanel(
      fileInput("file1", "Choose file to upload",
                accept = c(
                  "text/csv",
                  "text/comma-separated-values",
                  "text/tab-separated-values",
                  "text/plain",
                  ".csv",
                  ".tsv"
                )),
      
      dateRangeInput("inVar2", label = "Date range",
                     start = "2014-07-01", end = "2014-07-10")
      
    ),
    
    mainPanel(plotOutput("theGraph"))  
  )
))

shinyApp(ui = ui, server = server)
