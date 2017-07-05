# Meaning from Monitoring
This is a project to examine the public health impacts of emissions from oil refineries in the Bay Area. It is a project of the Fair Tech Collective, led by Gwen Ottinger, Associate Professor, Drexel University and Dawn Nafus, Intel.

This open-source code allows citizen scientists and community health advocates to gather statistical evidence of personal and public health impacts from refinery pollution. The code is entirely modifiable, requiring only knowledge of the R programming language. However, knowledge of R is not needed to gather statistics from your data. We have clearly marked a few areas that require input, but it is like filling out a document. Not fun, but easy, and gives meaning to your monitoring.

## How to use this code - Executive Summary
First, you must download R and Rstudio.

Second, you must load the package tidyverse.

Third, you must gather your data, and make sure it is in the right location to be read by the code.

Fourth, you need to change a few lines in the code to make it relevant for your project, i.e. id names, exposure windows, timeframe.

## To print a report
Results will appear in-line, however if you want to print a report and share it as a PDF, click "Knit" in the top bar. This will generate a PDF and you can save it to your desktop.

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
