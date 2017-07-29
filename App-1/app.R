required_pkg <- c("tidyverse","maptools", "rgdal", "spatstat", "ggmap", "shiny")
lapply(required_pkg, library, character.only = TRUE) 
library(rsconnect)

# Inputs here are date_begin and date_end
timeframe <- function(date_begin = "2016-05-09 14:00", date_end = "2016-08-11 0:00"){
  exp_begin = as.POSIXct(date_begin, tz="GMT", format="%Y-%m-%d %H")
  exp_end = as.POSIXct(date_end, tz="GMT", format="%Y-%m-%d %H")
  out = data_frame(day = seq(exp_begin, exp_end, by = 3600))
  return(out)
}
full_time <- timeframe()
# Manual
date_begin = "2016-05-09 14:00"
date_end = "2016-08-11 0:00"
exp_begin = as.POSIXct(date_begin, tz="GMT", format="%Y-%m-%d %H")
exp_end = as.POSIXct(date_end, tz="GMT", format="%Y-%m-%d %H")

# load air quality data
feed_4902 <- read_csv("Documents/coding/refinery_data/airQuality_feed4902_data.csv")
feed_4901 <- read_csv("Documents/coding/refinery_data/airQuality_feed4901_data.csv")
feed_4902_methane <- read_csv("Documents/coding/refinery_data/airQuality_N20_methane_4902_data.csv")

# Make hourly averages
## Set zero's to NA to not "mess up" average
feed_4902[feed_4902 == 0] <- NA
## Create new dataframe
hourly_4902 <- feed_4902 %>%
  # Select the day and hour of interest (get rid of minute and seconds)
  group_by(
    # Creates new variables
    day = as.POSIXct(cut(t, breaks='hour'))) %>%
  summarise(
    # Averages
    sulfur_dioxide = mean(sulfurDioxide, na.rm=T),
    carbon_monoxide = mean(carbonMonoxide, na.rm=T),
    ozone = mean(ozone, na.rm=T)) %>%
  ungroup() %>%
  # Arrange the columns by day
  arrange(day) %>%
  full_join(full_time, by = "day")

# Do the same for the other feed4902 dataframe
feed_4902_methane[feed_4902_methane == 0] <- NA
hourly_4902_methane <- feed_4902_methane %>%
  group_by(
    # Creates new variables
    day = as.POSIXct(cut(t, breaks='hour'))) %>%
  summarise(
    # Averages
    methane = mean(Methane, na.rm=T),
    benzene = mean(Benzene, na.rm=T),
    nitrous_oxide = mean(`Nitrous Oxide`, na.rm=T)) %>%
  # Arrange the columns by day
  arrange(day) %>%
  full_join(full_time, by = "day")

air_qual_4902 <- right_join(hourly_4902, hourly_4902_methane, by = "day") %>%
  mutate(id = "feed_4902")

# Do the same for feed 4901
feed_4901[feed_4901 == 0] <- NA
air_qual_4901 <- feed_4901 %>%
  # Select the day and hour of interest (get rid of minute and seconds)
  group_by(
    # Creates new variables
    day = as.POSIXct(cut(t, breaks='hour'))) %>%
  # Averages
  summarise(
    sulfur_dioxide = mean(sulfurDioxide, na.rm=T),
    carbon_monoxide = mean(carbonMonoxide, na.rm=T),
    ozone = mean(ozone, na.rm=T)) %>%
  mutate(
    id = "feed_4901"
  ) %>%
  # Arrange the columns by day
  arrange(day) %>%
  full_join(full_time, by = "day")

# Remove intermediate dataframes
rm(hourly_4902, hourly_4902_methane)
# Remove original dataframes
rm(feed_4901, feed_4902,feed_4902_methane)

# load paco data
paco <- read_csv("Documents/coding/refinery_data/paco_all.csv")

# Creating new dataframe
paco <- paco %>%
  mutate(
    # Remove extra values (supposed to be a correction)
    when=gsub("\\+0000","",when),
    # Converting / to - part 1
    when=sub("[[:punct:]]","-",when),
    # Converting / to - part 2
    when=sub("\\/","-",when),
    # Rename persons of interest
    who = replace(who, who=="meaningfrommonitoring3@gmail.com", "m3"),
    who = replace(who, who=="meaningfrommonitoring5@gmail.com", "m5"),
    who = replace(who, who=="meaningfrommonitoring7@gmail.com", "m7"),
    who = replace(who, who=="meaningfrommonitoring9@gmail.com", "m9"),
    who = replace(who, who=="meaningfrommonitoring10@gmail.com", "m10"),
    who = replace(who, who=="meaningfrommonitoring11@gmail.com", "m11"),
    who = replace(who, who=="meaningfrommonitoring16@gmail.com", "m16")
  ) %>%
  mutate(
    # Make person column as a factor
    id = as.factor(who),
    # Convert date column to datetime
    t = as.POSIXct(when, tz="GMT", format="%Y-%m-%d %H:%M:%S")) %>%
  # Remove columns not of interest
  select(-c(who, when, appId, pacoVersion, experimentId,
            experimentName, experimentVersion, experimentGroupName,
            actionTriggerId, actionId, actionSpecId, responseTime,
            scheduledTime, timeZone)) %>%
  # Select persons of interest 
  filter(id == "m3" | id == "m5" | id == "m7" |
           id == "m9" | id == "m10" | id == "m11" |
           id == "m16") %>%
  arrange(t)

# Remove incorrect values
paco$SPO2[paco$SPO2 == 0 | paco$SPO2 > 100 | paco$SPO2 < 80] <- NA
# Make hourly dataframe
paco_hourly <- paco %>%
  # Select the person, day and hour of interest
  group_by(id,
           # Creates new variables
           day = as.POSIXct(cut(t, breaks='hour'))) %>%
  # Average
  summarise(blood_oxygen = mean(SPO2, na.rm=T)) %>%
  filter(is.na(blood_oxygen) == F) %>% 
  complete(expand(nesting(id), day = seq(exp_begin, exp_end, by = 3600)),  
           #completing all levels of id:day
           fill = list(blood_oxygen = NA)) %>%
  # Select persons of interest 
  filter(id == "m3" | id == "m5" | id == "m7" |
           id == "m9" | id == "m10" | id == "m11" |
           id == "m16") %>%
  # Arrange the columns by person
  arrange(id)

rm(paco)

# Load fitbit data
fb_body <- read_csv("Documents/coding/refinery_data/fitbit_body_data.csv")
fb_activities <- read_csv("Documents/coding/refinery_data/fitbit_activities_data.csv")
fb_sleep <- read_csv("Documents/coding/refinery_data/fitbit_sleep_data.csv")

# Merge daily fitbit data
fb_daily <- inner_join(fb_body, fb_activities, fb_sleep, by = "t")
rm(fb_body, fb_activities, fb_sleep)

# Load intraday activity
fb_intraday_m3 <- read_csv("Documents/coding/refinery_data/fitbit_intradayactivities_m3.csv") %>%
  mutate(id = "m3")
fb_intraday_m5 <- read_csv("Documents/coding/refinery_data/fitbit_intradayactivities_m5.csv")%>%
  mutate(id = "m5")
fb_intraday_m7 <- read_csv("Documents/coding/refinery_data/fitbit_intradayactivities_m7.csv")%>%
  mutate(id = "m7")
fb_intraday_m9 <- read_csv("Documents/coding/refinery_data/fitbit_intradayactivities_m9.csv")%>%
  mutate(id = "m9")
fb_intraday_m11 <- read_csv("Documents/coding/refinery_data/fitbit_intradayactivities_m11.csv")%>%
  mutate(id = "m11")
fb_intraday_m16 <- read_csv("Documents/coding/refinery_data/fitbit_intradayactivities_m16.csv")%>%
  mutate(id = "m16")

# Combine dataframes
fb_intra <- bind_rows(fb_intraday_m3, fb_intraday_m5, .id = NULL) %>%
  bind_rows(fb_intraday_m7, .id = NULL) %>%
  bind_rows(fb_intraday_m9, .id = NULL) %>%
  bind_rows(fb_intraday_m11, .id = NULL) %>%
  bind_rows(fb_intraday_m16, .id = NULL) %>%
  mutate(id = as.factor(id))

# Remove intermediate columns
rm(fb_intraday_m3, fb_intraday_m5, fb_intraday_m7,
   fb_intraday_m9, fb_intraday_m11, fb_intraday_m16)

# Make hourly data
fb_intraday <- fb_intra %>% 
  group_by(id,
           # Creates new variables
           day = as.POSIXct(cut(t, breaks='hour'))) %>%
  summarise(
    # Averages
    calories = sum(calories, na.rm=T),
    distance = sum(distance, na.rm=T),
    steps = sum(steps, na.rm=T),
    heart_rate = mean(heart, na.rm=T),
    floors = sum(floors, na.rm=T),
    elevation = sum(elevation, na.rm=T)) %>%
  complete(expand(nesting(id), day = seq(exp_begin, exp_end, by = 3600)),  
           #completing all levels of id:day
           fill = list(calories = NA,distance = NA,
                       steps = NA, heart_rate = NA,
                       floors = NA, elevation = NA)) %>%
  # Select persons of interest 
  filter(id == "m3" | id == "m5" | id == "m7" |
           id == "m9" | id == "m10" | id == "m11" |
           id == "m16") %>%
  # Arrange the columns by day
  arrange(id, day)

# Remove original dataframes
rm(fb_intra, fb_daily)

# Make demographics dataframe
demographics <- data_frame(
  id =  c("m3","m5","m7","m9","m10","m11","m16"),
  age = c(21,34,45,33,56,67,51),
  sex = as.factor(c("male","female","male","female","female","male","female")))

# Merge with fb_intraday
fb_data <- left_join(fb_intraday, demographics, by = "id") %>%
  ungroup %>%
  mutate(
    id = as.factor(id)
  )
paco_data <- full_join(paco_hourly, demographics, by = "id") %>%
  ungroup %>%
  mutate(
    id = as.factor(id)
  )

# Individual data
individual_data <- fb_data %>%
  bind_rows(paco_data, .id = NULL)

# Remove unnecessary dataframes
rm(paco_hourly, fb_intraday)

# Air Quality data
air_quality <- full_join(full_time, air_qual_4901, by = "day") %>%
  full_join(air_qual_4902, 
            by = c("day", "id", "sulfur_dioxide",
                   "carbon_monoxide", "ozone")) %>%
  select(day, id, everything()) %>%
  mutate(id = as.factor(id)) %>%
  arrange(day)

# Set hours of interest
hours = 8
# Moving window average of sulfur dioxide
air_quality <- 
  air_quality %>% 
  group_by(id) %>% 
  arrange(day) %>%
  mutate(
    sulfur_dioxide_exposure_window = 
      zoo::rollapply(sulfur_dioxide,
                     width = hours, #how many data to include
                     FUN = mean, #function is mean
                     na.rm = T, #avoids NA
                     partial = T, #skips unnecessary datapoints
                     align = "right")) %>%
  ungroup %>%
  arrange(id, day)

ind_data_filtered <- individual_data %>%
  filter(heart_rate > 30 & heart_rate < 200 | is.na(heart_rate)) %>% # put bounds on heart rate
  filter(sex == "male" & age > 50) # Select demographic filters

# Make the final dataframe (do not change)
final_df <- ind_data_filtered %>%
  bind_rows(air_quality, .id = NULL) %>%
  mutate(id = as.factor(id))


server <- function(input, output) {
  
  output$healthSelect <- renderUI({
    selectInput("health_var", "Health Indicator", 
                choices = c("heart_rate", "blood_oxygen"), 
                selected = "heart_rate")
  })
  
  output$pollutantSelect <- renderUI({
    selectInput("pollutant_var", "Pollutant", 
                choices = c("sulfur_dioxide_exposure_window", "methane"),
                selected = "methane")
  })
  
  output$plot1 <- renderPlot({
    final_df %>%
      group_by(day) %>%
      filter(!is.na(UQ(input$health_var)) & !is.na(UQ(input$pollutant_var))) %>%
      ggplot() + 
        geom_point(aes_string(x = input$health_var, y = input$pollutant_var))
  })
  
}
final_df %>%
  group_by("day") %>%
  summarize(
    "methane" = mean("methane", na.rm=T),
    "heart_rate" = mean("heart_rate", na.rm=T)
  ) %>%
  filter(!is.na("methane") & !is.na("heart_rate")) %>%
  ungroup -> good
ggplot(good) + 
    geom_point(aes_string(x = "methane", y = "heart_rate"))


ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      h3('Indicators'),
      uiOutput('healthSelect'),
      uiOutput("pollutantSelect")
    ),
    mainPanel(
      plotOutput('plot')
    )
  )
)

shinyApp(ui = ui, server = server)
