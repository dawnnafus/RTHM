# Set-up

# List of R packages
required_pkg <- c("tidyverse","maptools", "rgdal", 
                  "spatstat", "ggmap", "geosphere", 
                  "leaflet", "spdep", "sp", "shinydashboard")
#pkgs_not_installed <- required_pkg[!sapply(required_pkg, function(p) require(p, character.only=T))]
#install.packages(pkgs_not_installed, dependencies=TRUE)

# Load all libraries at once.
lapply(required_pkg, library, character.only = TRUE)

# Load data
individual_data <- read_csv("../../refinery_data/data/individual_data.csv")
air_quality <- read_csv("../../refinery_data/data/air_quality.csv")

### Data manipulation
# Merged dataframe 
total_df <- individual_data %>%
  #filter(sex == "male" & age > 50) %>% # TO DO: select demographic filters
  bind_rows(air_quality, .id = NULL) %>%
  mutate(id = as.factor(id),
         methane = as.numeric(methane),
         sex = as.factor(sex),
         day = as.POSIXct(day),
         blood_oxygen = as.numeric(blood_oxygen),
         sym_factor = as.factor(symptoms),
         doctor = as.factor(doctor),
         medicine = as.factor(medicine),
         symptoms = ifelse(sym_factor %in% c(1:9), 1,
                           ifelse(is.na(sym_factor), NA, 0)),
         benzene = as.numeric(benzene),
         nitrous_oxide = as.numeric(nitrous_oxide),
         xylene = as.numeric(xylene)
  )

# Remove intermediate dataframe
rm(binding_df)

# Create plotting theme
theme_fair_tech <- theme(
  legend.position = "bottom",
  panel.background = element_rect(fill = NA),
  # panel.border = element_rect(fill = NA, color = "grey75"),
  axis.ticks = element_line(color = "grey95", size = 0.3),
  panel.grid.major = element_line(color = "grey95", size = 0.3),
  panel.grid.minor = element_line(color = "grey95", size = 0.3),
  legend.key = element_blank(),
  plot.title = element_text(size=20, face="bold", color = "maroon", 
                            margin = margin(10, 0, 10, 0))
)

### Load Spatial Data
# Load contra costa county shapefile
cc <- readOGR(dsn ="../data/location/BaseMapGrid", 
              layer = "GRD_PWD_BaseMap_0106", 
              verbose = F)

# Convert to longlat data
cc_wgs84 <- spTransform(cc, 
                        CRS("+proj=longlat +datum=WGS84"))

# Basic plot of contra costa county
cc_plot <- ggplot(cc_wgs84, aes(x=long, y=lat)) +
  geom_path(aes(group=group)) + 
  coord_map("mercator") + 
  geom_point(aes(x= air_quality$longitude[[1]], y= air_quality$latitude[[1]]))

### Shiny Code
function(input, output){
        datadata <- eventReactive(input$go, {
          
          individual_data %>%
            mutate(
              sex = as.factor(sex),
              blood_oxygen = as.numeric(blood_oxygen),
              sym_factor = as.factor(symptoms),
              doctor = as.factor(doctor),
              medicine = as.factor(medicine),
              symptoms = ifelse(sym_factor %in% c(1:9), 1,
                                ifelse(is.na(sym_factor), NA, 0))) %>%
            filter(age > input$age_range[1] & age < input$age_range[2]) %>%
            filter(time_in_area > input$time_in_area[1] & 
                     time_in_area < input$time_in_area[2]) %>%
            filter(sex %in% input$gender) %>%
            bind_rows(air_quality, .id = NULL) %>%
            mutate(id = as.factor(id),
                   day = as.POSIXct(day),
                   benzene = as.numeric(benzene),
                   methane = as.numeric(methane),
                   nitrous_oxide = as.numeric(nitrous_oxide),
                   xylene = as.numeric(xylene))%>%
            group_by(day) %>%
            summarize(
              # Pollutants
              methane = mean(methane, na.rm=T),
              sulfur_dioxide = mean(sulfur_dioxide_exposure_window, na.rm=T),
              ozone = mean(ozone, na.rm=T),
              benzene = mean(benzene, na.rm=T),
              pm_2.5 = mean(pm_2.5, na.rm=T),
              carbon_monoxide = mean(carbon_monoxide, na.rm=T),
              so2_not_window = mean(sulfur_dioxide, na.rm=T),
              xylene = mean(xylene, na.rm=T),
              nitrous_oxide = mean(nitrous_oxide, na.rm=T),
              # Health indicators
              heart_rate = mean(heart_rate, na.rm=T),
              blood_oxygen = mean(blood_oxygen, na.rm=T),
              symptoms = mean(symptoms, na.rm=T),
              text_entry = first(text_entry),
              # Summary demographics
              time_in_area = mean(time_in_area, na.rm=T),
              age = mean(age, na.rm=T),
              home_dist_to_refinery = mean(home_dist_to_refinery, na.rm=T)
            ) %>%
            ungroup
        })
        
        data2 <- eventReactive(input$go, {
          # Merged dataframe 
          individual_data %>%
            mutate(
              sex = as.factor(sex),
              blood_oxygen = as.numeric(blood_oxygen),
              sym_factor = as.factor(symptoms),
              doctor = as.factor(doctor),
              medicine = as.factor(medicine),
              symptoms = ifelse(sym_factor %in% c(1:9), 1,
                                ifelse(is.na(sym_factor), NA, 0))) %>%
            filter(age > input$age_range[1] & age < input$age_range[2]) %>%
            filter(time_in_area > input$time_in_area[1] & 
                     time_in_area < input$time_in_area[2]) %>%
            filter(sex %in% input$gender) %>%
            bind_rows(air_quality, .id = NULL) %>%
            mutate(id = as.factor(id))
        })
        
        data_binding <- reactive({
          data2() %>%
            select(-c(methane, sulfur_dioxide, ozone,
                      benzene, pm_2.5, carbon_monoxide,
                      sulfur_dioxide_exposure_window, xylene,
                      nitrous_oxide))
          
        })
        
        data_spatial <- reactive({
          data2() %>%
            group_by(day) %>%
            summarize(
              methane = mean(methane, na.rm=T),
              sulfur_dioxide = mean(sulfur_dioxide_exposure_window, na.rm=T),
              ozone = mean(ozone, na.rm=T),
              benzene = mean(benzene, na.rm=T),
              pm_2.5 = mean(pm_2.5, na.rm=T),
              carbon_monoxide = mean(carbon_monoxide, na.rm=T),
              so2_not_window = mean(sulfur_dioxide, na.rm=T),
              xylene = mean(xylene, na.rm=T),
              nitrous_oxide = mean(nitrous_oxide, na.rm=T)
            ) %>%
            ungroup %>%
            right_join(data_binding(), by = "day") %>%
            filter(!is.na(id)) %>%
            arrange(day)
        })
        
        output$healthSelect <- renderUI({
          selectInput("health_var", "Health Indicator", 
                      choices = c("heart_rate", "blood_oxygen", 
                                  "symptoms"), 
                      selected = "heart_rate")
        })
        
        output$pollutantSelect <- renderUI({
          selectInput("pollutant_var", "Pollutant", 
                      choices = c("sulfur_dioxide",
                                  "methane", "ozone", "benzene",
                                  "pm_2.5", "carbon_monoxide",
                                  "xylene", "nitrous_oxide"),
                      selected = "methane")
        })
        
        output$spatialSelect <- renderUI({
          selectInput("spatial_var", "Variable of interest", 
                      choices = c("blood_oxygen",
                                  "sex", "time_in_area", "symptoms",
                                  "heart_rate", "age",
                                  "doctor", "id"),
                      selected = "heart_rate")
          
        })
        
        output$enviroscreen <- renderUI({
          HTML('<iframe width="800" height="600" frameborder="0" 
               scrolling="no" allowfullscreen 
               src="https://arcg.is/0KTvm1"></iframe>')
          
        })
        
        #output$view <- renderTable({ datadata() })
        
        output$plot1 <- renderPlot({
          new_data <- datadata()
          
          #new_data %>%
          #  select(matches(input$health_var), matches(input$pollutant_var)) %>% 
          #  boot::corr() %>%
          #  round(3) -> correlation
          
          ggplot(new_data) +
            geom_point(aes_string(x = input$pollutant_var, y = input$health_var))+
            scale_x_continuous() + 
            scale_y_continuous() + 
            theme_fair_tech + 
            geom_smooth(aes_string(x= input$pollutant_var, y= input$health_var), 
                        method = "lm", se=F) 
          #ggtitle(paste0("r = ",correlation))
        })
        
        output$plotLeaf <- renderLeaflet({
          some_data <- data_spatial()
          
          leaflet(some_data) %>% 
            addTiles() %>% 
            addCircleMarkers(
              lng = ~home_long,
              lat = ~home_lat,
              radius = 4,
              stroke = FALSE,
              fillOpacity = 1,
              label = ~paste("ID: ", id, 
                             "Age: ", age,
                             "Years in area: ", time_in_area,
                             "Gender: ", sex))
        })
        
        output$plot_spatial <- renderPlot({
          the_data <- data_spatial()
          cc_plot + 
            geom_point(data=the_data,
                       aes_string(
                         x="longitude",
                         y="latitude",
                         color = input$spatial_var),
                       na.rm = T) + 
            ggtitle("Plotting the Variable by Location:
                    Magnitude and Location in Contra Costa County")
        })
}