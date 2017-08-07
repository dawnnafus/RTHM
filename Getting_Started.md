## How to use this code - Executive Summary

### R
First, you need to download R (https://cran.cnr.berkeley.edu/) and RStudio (https://www.rstudio.com/products/RStudio/#Desktop). Both are free. Make sure to download the correct R version for your operating system and the desktop version of RStudio.

The versions used to create the code are listed below. Other versions may or may not work with the code.

+ RStudio version 1.0.143
+ R version 3.4.0

This is the key package needed for the code. The code installs and/or loads it automatically, but just in case the version is listed below.

+ tidyverse version 1.1.1

And finally, this is a highly recommended tutorial for getting started with R, however the code does not require you to know the language. The analysis only requires following specified directions, but you may elect to tinker with the code. In the references document, you can find more assistance.

+ http://r4ds.had.co.nz/introduction.html

### Data
You need to collect your data, and make sure it is in the right location to be read by the code. The key datasets are: symptoms reporting (PACO), Fitbit, GPS, and refinery pollution data. The source of these data are listed in the references document.

### Manipulating the code
Throughout the code, there are various user inputs and selections. These are marked in the code, but will be noted below in the detailed instructions. For instance, you will be asked to make the timeframe, id's, and exposure windows relevant for your project.
Image.

### To print a report
Results will appear in-line (i.e. within RStudio), however if you want to print a report and share it as a PDF, click `Knit` in the icon bar right above the code window. This will generate a PDF which you can save to your desktop.
Image.

## Detailed instructions
### If you haven't used R before
Download R at this [webpage](r). Image.

Next, download RStudio [here](rstudio.com). RStudio is a user interface to easily work with R. Image.

Create two side-by-side folders. One is titled: "refinery-data" while the other is "refinery-stats." Image.

Download the analysis file (refinery-analysis.rmd), put it in "refinery-stats." Double-click on the file and RStudio should open. 

### Once you've installed and set-up R

Acquire the needed datasets:

  1. Paco
  2. Fitbit
    + For all users
    + Intraday
  3. Pollution data
    + Feed 4901
    + Feed 4901 Methane
    + Feed 4902
    + Feed 4902 Methane
  4. GPS data
  
Put these datasets side-by-side in the "refinery-data" folder.

### Data management
Here is how each dataset should look. Please make sure you follow this exactly.

+ Paco. Image.
+ Fitbit. Image.
+ Pollution. Image.
+ GPS. Data.

## Adjusting the code for your project

**1. Loading packages**

  + If this is your first time running the code, make sure these two lines do not have a `#` in front of them. This `#` "comments out" the code and it will not run. You need to install the packages the first time. Every other time, you only need to load the packages and can put a `#` in front of them.
    + `pkgs_not_installed <- required_pkg[!sapply(required_pkg, function(p) require(p, character.only=T))]`
    + `install.packages(pkgs_not_installed, dependencies=TRUE)`

**2. Timeframe**

  + What are the project start and end date? Select the very beginning of the data and the very end even if no individual dataset runs for the entire length.
  + Insert your dates in the exact same format given: e.g. `2016-05-09 14:00`. Replace the code given for start and end date.

**3. Loading pollution data**

  + General principle: `read_csv` simply reads the csv listed at the end of a given filepath. If you have followed my suggested folder structure, the code should simply work. However, a few things to note: `..` means go "up" one folder. You will start wherever you have saved refinery-analysis.rmd.
  + Pollution: Make sure to do this for all 4 datasets.

**4. Exposure window**

  + The next entry point is the exposure window. This is automatically set at `8` hours. If you would like to change that, in the `r exposure window` code chunk you will find a parameter called `width`. Feel free to use `cntl-F` to locate this. Change the number to change the exposure window.
  
**5. Paco data**

  + Load (`read_csv`) in the same way as pollution data above.
  + Change ID's in paco data.
    + `who = replace(who, who=="meaningfrommonitoring3@gmail.com", "m3")` - This code takes any entries listed as "meaningfrommonitoring3@gmail.com" and replaces it with "m3." You need to do this with all ID's of interest. You get to select your ID names. 
    + `filter(id == "m3" | id == "m5")` - Change the ID's here to match the ID's you entered above. Make sure to use `==` and `|` and `""` in this step.
    + You need to repeat step #2 (`filter`) in the next group of code, almost directly below.
  
**6. Fitbit data**

  + Load (`read_csv`) the user specified dataframes in the same way as above. This time, however, we use a `%>%` to move to the next function call that creates (`mutate`) a new column called id. The entry of this column should be equal to the `ID` of the user in question. These should match the paco data above.
  + Name the dataframes according to the ID's. e.g. for `fb_intraday_m16 <-` change the `m16` part.
    + e.g. `mutate(id = "m16")` - Note in this case we only use one `=`
  + After `# Combine dataframes` you need to make sure the datasets specified are the same names that you inputted above. Don't change the name of this dataframe.
  + After `rm(` input all the dataframes you just loaded, except for the merged data.
  + You will need to `filter` for your ID's of interest here as well.
  
**7. Demographic data**

!!

**8. Filters**

  + In the next code chunk `TO DO filter your data`, you will need to select the filters you would like to apply to the analysis. (Note, this is only needed for detailed statistics. You will be able to play with the interactive plots, but those will not provide statistics at this point.) In order to filter, you will need do two things:
  1. Get rid of the `#` at the front of the `filter` line under the `# Merged dataframe` header.
  2. Enter the filters in the parentheses.
    + For text-based filters, the formula to follow is `variable_name` `symbol` `"entry"`. The symbols you can use are `==` for matches exactly, `!=` for does not match or, slightly more advanced `%in%` followed by a grouping of entries like `c("black", "white")`. Note that each entry has "" around it.
    + For numbers-based filters, the same basic formula applies: `variable_name` `symbol` `number`. The symbols can be `==`, `!=`, `>`, `<`, `>=`, `=<`, or again `%in%` with a grouping such as `c(55:65)`.
  3. Combine filters
    + In order to apply more than one filter, you will need to decide how they should be combined. The choices are simple: `&` (and) or `|` (or). So if you want to only examine black females, you would enter `filter(race == "black" & sex == "female")` but if you wanted black or female, you would simply replace `&` with `|`. If you want to combine conditions, use parentheses. For example, if you want to examine white males and those over 50, you would write `filter((race =="white" & sex == "male") | age > 50)`.

**9. Making plots**

To make your plot, you will need to simply follow the format provided. For example: 
```
my_plot(health_var = heart_rate,
        health_var_name = "Heart Rate",
        health_var_units = "bpm",
        pollutant_var = methane,
        pollutant_var_name = "Methane",
        pollutant_var_units = "ppb")
```
In this case, if you want to change the health indicator, you would change the first three entries. So instead of `heart_rate`, you would write `blood_oxygen`. Never change the values before the `=`.

**10. Spatial analysis...**
  
    
  

