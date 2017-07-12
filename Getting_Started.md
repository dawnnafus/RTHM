## How to use this code - Executive Summary

### R
First, you need to download R (https://cran.cnr.berkeley.edu/) and RStudio (https://www.rstudio.com/products/RStudio/#Desktop). Both are free. Make sure to download the correct version for your system and the desktop version of RStudio.

The versions used to create the code are listed below. Other versions may or may not work with the code.
+ Rstudio version 1.0.143
+ R version 3.4.0

This is the key package needed for the code. The code installs and/or loads it automatically, but just in case the version is listed below.
+ tidyverse version 1.1.1

And finally, this is a highly recommended tutorial for getting started with R, however the code does not require you to know the language. You only need to follow the directions given below, but if you would like to tinker. 
+ http://r4ds.had.co.nz/introduction.html

### Data
Now, you must gather your data, and make sure it is in the right location to be read by the code. The key datasets are: symptoms reporting (PACO), Fitbit, and refinery pollution data.

### Manipulating the code
Fourth, throughout the code, there are various user inputs and selections. These are marked in the code, but will be noted below in the detailed instructions. For instance, you will be asked to make the timeframe, ids, and exposure windows relevant for your project.

### To print a report
Results will appear in-line (i.e. within RStudio), however if you want to print a report and share it as a PDF, click "Knit" in the top bar. This will generate a PDF which you can save to your desktop.

## Detailed instructions
### If you haven't used R before
First, download R at this webpage. (insert photo)

Second, download RStudio here. RStudio is an IDE that allows you to run R code and manage other parts. (insert photo)

Download the file (.Rmd), put it in a folder that is side-by-side with "refinery-data." Double-click and RStudio should open. 

Go to the bottom right pane, click on "packages", then "install" and type in "tidyverse." (should put in code that installs if not installed)

### Once you've installed and set-up R

Third, acquire the needed datasets:
  1. Paco - i.e. blood oxygen
  2. Fitbit
  3. Diary
  4. Refinery data (this might be provided)
  
Put these datasets in a folder titled "refinery-data" located one folder up from your current folder. (insert photo)

How your data should look