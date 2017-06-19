Refinery Analysis
================
Niklas Lollo

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
    day = as.POSIXct(cut(t, breaks='hour'))) %>%
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
    # Creates new variables
    day = as.POSIXct(cut(t, breaks='hour'))) %>%
  summarise(
    # Averages
    methane = mean(Methane, na.rm=T),
    benzene = mean(Benzene, na.rm=T),
    nitrous_oxide = mean(`Nitrous Oxide`, na.rm=T)) %>%
  # Arrange the columns by day
  arrange(day)

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
  # Arrange the columns by person
  arrange(id)
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
    day = as.POSIXct(cut(t, breaks='hour'))) %>%
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
  group_by(id) %>% 
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
  arrange(id, day)
```

``` r
# 5/13 0:00 - 7/14 0:00

full_time <- data_frame(time = seq(1463090400, 1468447200, by = 3600)) %>%
  mutate(
    day = as.POSIXct(time, origin = "1970-01-01")
  ) %>% select(-time)
```

``` r
df <- full_join(full_time, air_qual_4901, by = "day") %>%
  full_join(air_qual_4902, by = c("day", "id", "sulfur_dioxide","carbon_monoxide", "ozone")) %>%
  bind_rows(fb_intraday, .id = NULL) %>%
  bind_rows(paco_hourly, .id = NULL) %>%
  select(day, id, everything(), -lag_1, -lag_2, -lag_3, -lag_4) %>%
  mutate(id = as.factor(id)) %>%
  arrange(day)
```

``` r
correlation_fun <- function(initial_df, var_1, var_2, var_time) {
  require(dplyr)
  ## Make dataframe
  initial_df %>%
    select(!!var_1, !!var_2, !!var_time) %>%
    filter(!is.na(!!var_1) | !is.na(!!var_2))%>% 
    group_by(!!var_time) %>%
    summarize(mean_var1 = mean(!!var_1, na.rm=T),
               mean_var2 = mean(!!var_2, na.rm=T)) %>% 
    ungroup %>% 
    filter(!is.na(mean_var1) & !is.na(mean_var2)) %>%
    select(mean_var1,mean_var2) %>% 
    boot::corr() %>% 
    print()
}
# https://rpubs.com/hadley/dplyr-programming 
# See this for quosures and programming with dplyr

## Blood Oxygen and Sulfur Dioxide
correlation_fun(df, quo(blood_oxygen),quo(sulfur_dioxide),quo(day))
```

    ## [1] -0.1374617

``` r
## Heart Rate and Sulfur Dioxide
correlation_fun(df, quo(heart_rate),quo(sulfur_dioxide),quo(day))
```

    ## [1] -0.0760685

``` r
## Heart Rate and Methane
correlation_fun(df, quo(heart_rate),quo(methane),quo(day))
```

    ## [1] -0.3205606

``` r
# Only problem here is need to filter for low heart rate
```
