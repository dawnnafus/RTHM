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
    hour=format(as.POSIXct(cut(t, breaks='hour')), '%H')
    ) %>%
  summarise(
    # Averages
    sulfur_dioxide = mean(sulfurDioxide, na.rm=T),
    carbon_monoxide = mean(carbonMonoxide, na.rm=T),
    ozone = mean(ozone, na.rm=T)
    ) %>%
  # Arrange the columns by day
  arrange(day)

# Do the same for the other feed4902 dataframe
feed_4902_methane[feed_4902_methane == 0] <- NA
hourly_4902_methane <- feed_4902_methane %>%
  group_by(
    day=format(as.POSIXct(cut(t, breaks='day')), '%y%m%d'),
    hour=format(as.POSIXct(cut(t, breaks='hour')), '%H')
    ) %>%
  summarise(
    # Averages
    methane = mean(Methane, na.rm=T),
    benzene = mean(Benzene, na.rm=T),
    nitrous_oxide = mean(`Nitrous Oxide`, na.rm=T)
    ) %>%
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
  summarise(
    # Averages
    sulfur_dioxide = mean(sulfurDioxide, na.rm=T),
    carbon_monoxide = mean(carbonMonoxide, na.rm=T),
    ozone = mean(ozone, na.rm=T)
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

# load fitbit data
fb_body <- read_csv("../refinery_data/fitbit_body_data.csv")
fb_activities <- read_csv("../refinery_data/fitbit_activities_data.csv")
fb_intraday <- read_csv("../refinery_data/fitbit_intradayactivities_data.csv")
fb_sleep <- read_csv("../refinery_data/fitbit_sleep_data.csv")

# merge daily fitbit data
fb_daily <- inner_join(fb_body, fb_activities, fb_sleep, by = "t")
rm(fb_body, fb_activities, fb_sleep)
```

``` r
# Right-aligned rolling average
movingavg <- function(the_data, n_years){
  result = rep(NA, length(the_data))
  for (i in 1:length(the_data)){
    if (i < n_years){
      next
     }
        result[i] = mean(the_data[(i - n_years + 1):i])
    }
  return(result)
}
```

``` r
# Recreate correlations
# Moving window of blood oxygen (3 or 5 hr)

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
