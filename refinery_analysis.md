Refinery Analysis
================
Niklas Lollo
6/3/2017

### Content websites:

-   <http://www.fenceline.org/rodeo/data.php>
-   <https://esdr.cmucreatelab.org/home>
-   <http://airwatchbayarea.org/>
-   <https://makesenseofdata.com/#!/experiments/my>

### For R:

-   <http://r4ds.had.co.nz/introduction.html>
-   Rstudio version 1.0.143
-   R version 3.4.0
-   tidyverse version 1.1.1

``` r
# load air quality data
feed_4902 <- read_csv("../refinery_data/airQuality_feed4902_data.csv")
feed_4901 <- read_csv("../refinery_data/airQuality_feed4901_data.csv")
feed_4902_methane <- read_csv("../refinery_data/airQuality_N20_methane_4902_data.csv")

# Make hourly averages
## Set zero's to NA to not "mess up" average
feed_4902[feed_4902 == 0] <- NA
## Create new dataframe
hourly_4902 <- feed_4902 %>%
  # Select the day and hour of interest (get rid of minute and seconds)
  group_by(
    # Creates new variables
    day=format(as.POSIXct(cut(t, breaks='day')), '%y%m%d'),
    hour=format(as.POSIXct(cut(t, breaks='hour')), '%H')) %>%
  summarise(
    # Averages
    sulfur_dioxide = mean(sulfurDioxide, na.rm=T),
    carbon_monoxide = mean(carbonMonoxide, na.rm=T),
    ozone = mean(ozone, na.rm=T)) %>%
  # Arrange the columns by day
  arrange(day)

# Do the same for the other feed4902 dataframe
feed_4902_methane[feed_4902_methane == 0] <- NA
hourly_4902_methane <- feed_4902_methane %>%
  group_by(
    day=format(as.POSIXct(cut(t, breaks='day')), '%y%m%d'),
    hour=format(as.POSIXct(cut(t, breaks='hour')), '%H')) %>%
  summarise(
    # Averages
    methane = mean(Methane, na.rm=T),
    benzene = mean(Benzene, na.rm=T),
    nitrous_oxide = mean(`Nitrous Oxide`, na.rm=T)) %>%
  # Arrange the columns by day
  arrange(day)

air_qual_4902 <- right_join(hourly_4902, hourly_4902_methane, 
                               by = c("day", "hour"))

# Do the same for feed 4901
feed_4901[feed_4901 == 0] <- NA
air_qual_4901 <- feed_4901 %>%
  # Select the day and hour of interest (get rid of minute and seconds)
  group_by(
    # Creates new variables
    day=format(as.POSIXct(cut(t, breaks='day')), '%y%m%d'),
    hour=format(as.POSIXct(cut(t, breaks='hour')), '%H')
    ) %>%
    # Averages
  summarise(
    sulfur_dioxide = mean(sulfurDioxide, na.rm=T),
    carbon_monoxide = mean(carbonMonoxide, na.rm=T),
    ozone = mean(ozone, na.rm=T)) %>%
  # Arrange the columns by day
  arrange(day)

# Remove intermediate dataframes
rm(hourly_4902, hourly_4902_methane)
# Remove original dataframes
rm(feed_4901, feed_4902,feed_4902_methane)
```

``` r
# load paco data
paco <- read_csv("../refinery_data/paco_all.csv")

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
    person = as.factor(who),
    # Convert date column to datetime
    t = as.POSIXct(when, tz="GMT", format="%Y-%m-%d %H:%M:%S")) %>%
  # Remove columns not of interest
  select(-c(who, when, appId, pacoVersion, experimentId,
            experimentName, experimentVersion, experimentGroupName,
            actionTriggerId, actionId, actionSpecId, responseTime,
            scheduledTime, timeZone)) %>%
  # Select persons of interest 
  filter(person == "m3" | person == "m5" | person == "m7" |
      person == "m9" | person == "m10" | person == "m11" |
      person == "m16") %>% 
  arrange(t)
# Remove incorrect values
paco$SPO2[paco$SPO2 == 0 | paco$SPO2 > 100 | paco$SPO2 < 80] <- NA
# Make hourly dataframe
paco_hourly <- paco %>%
  # Select the person, day and hour of interest
  group_by(person,
    # Creates new variables
    day = as.POSIXct(cut(t, breaks='hour'))) %>%
    # Average
  summarise(blood_oxygen = mean(SPO2, na.rm=T)) %>%
  filter(is.na(blood_oxygen) == F) %>%
  # Arrange the columns by person
  arrange(person)
```

``` r
# Load fitbit data
fb_body <- read_csv("../refinery_data/fitbit_body_data.csv")
fb_activities <- read_csv("../refinery_data/fitbit_activities_data.csv")
fb_sleep <- read_csv("../refinery_data/fitbit_sleep_data.csv")

# Merge daily fitbit data
fb_daily <- inner_join(fb_body, fb_activities, fb_sleep, by = "t")
rm(fb_body, fb_activities, fb_sleep)

# Load intraday activity
fb_intraday <- read_csv("../refinery_data/fitbit_intradayactivities_data.csv")
fb_intraday <- fb_intraday %>%
  # Select the day and hour of interest (get rid of minute and seconds)
  group_by(
    # Creates new variables
    day=format(as.POSIXct(cut(t, breaks='day')), '%y%m%d'),
    hour=format(as.POSIXct(cut(t, breaks='hour')), '%H')) %>%
  summarise(
    # Averages
    calories = sum(calories, na.rm=T),
    distance = sum(distance, na.rm=T),
    steps = sum(steps, na.rm=T),
    heart_rate = mean(heart, na.rm=T),
    floors = sum(floors, na.rm=T),
    elevation = sum(elevation, na.rm=T)) %>%
  # Arrange the columns by day
  arrange(day)
```

``` r
# Set hours of interest
hours = 5
# Make window average of blood oxygen data
paco_hourly <- paco_hourly %>%
  group_by(person) %>% 
  arrange(day) %>%
  mutate(
    lag_1 = day-lag(day),
    lag_2 = (day-lag(day,2))/3600,
    lag_3 = (day-lag(day,3))/3600,
    lag_4 = (day-lag(day,4))/3600,
    oxygen_window = ifelse(is.na(lag(day)), blood_oxygen,
                    ifelse(lag_1>hours, blood_oxygen,
                    ifelse(lag_2>hours, (blood_oxygen+lag(blood_oxygen))/2,
                    ifelse(lag_3>hours, (blood_oxygen+lag(blood_oxygen)+lag(blood_oxygen,2))/3,
                    ifelse(lag_4>hours, 
                        (blood_oxygen+lag(blood_oxygen)+lag(blood_oxygen,2)+lag(blood_oxygen,3))/4,
                 NA)))))) %>% 
  ungroup %>% 
  arrange(person, day)
```

``` r
# Recreate correlations

## Heart Rate and Sulfur Dioxide
## Heart Rate and Methane
## Blood Oxygen and Sulfur Dioxide

# Chi-square test


# FB_daily is an aggregate


### Fuse together


### Mess around
# Moving window of blood oxygen (3 or 5 hr)
# Mess around with exposure levels


# Need to do exploration, make it functional. Maybe don't use moving windows. 

# Light check-in
```
