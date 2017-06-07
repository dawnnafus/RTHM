Refinery\_Analysis
================
Niklas Lollo
6/3/2017

### Key websites:

-   <http://www.fenceline.org/rodeo/data.php>
-   <https://esdr.cmucreatelab.org/home>
-   <http://airwatchbayarea.org/>
-   <https://makesenseofdata.com/#!/experiments/my> For R:
-   <http://r4ds.had.co.nz/introduction.html>

``` r
# load air quality data
air_qual <- read_csv("../refinery_data/airQuality_feedChannelData_data.csv")

# load paco data
paco <- read_csv("../refinery_data/full_paco_download.csv")
pacomfm3 <- read_csv("../refinery_data/PacoMFM3.csv")
# to-do: merge paco datasets

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
# Recreate correlations
air_qual %>% ggplot() + geom_point(aes(x = t, y = carbonMonoxide))
```

![](refinery_analysis_files/figure-markdown_github/might%20be%20interesting-1.png)

``` r
# Chi-square test


# FB_daily is an aggregate


### Fuse together


### Mess around
# Moving window of blood oxygen (3 or 5 hr)
# Mess around with exposure levels


# Need to do exploration, make it functional. Maybe don't use moving windows. 

# Light check-in
```
