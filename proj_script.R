# THIS IS NOT A FULL CODE FROM THE PROJECT, AND COMPRISE THE FOLLOWING STEPS:
  # 
  # 1. LOAD LIBRARY
  # 2. DOWNLOAD THE DATASET FROM OSF
  # 3. GET 56 DATASETS OUT OF 107, THERE ARE NECESSARY FOR THE ANALYSIS
  # 4. COMBINE THE 56 DATASETS IN ONLY ONE FILE
  # 5. SELECT A FEW IMPORTATNT FEATURES OUT OF 350 AVAILABLE IN THE ORIGINAL data
  # 6. DROP DUPLICATE USERS
  # 7. SPLIT DATE IN DAY, MONTH, AND YEAR
  # 8. SAVE THE FINAL DATASET
  # 9. DELETE THE ORIGINAL FILES FROM DISK(+/- 2.6GB)



# LOAD LIBRARY
library(tidyverse)
library(tidymodels)
library(forcats)
library(olsrr)
library(skimr)
library(viridis)
library(srvyr)
library(scales)
library(osfr) #from osf website
library(zoo)
library(DT)
library(HH)

# DOWNLOAD DATASETS FROM OSF
if(!file.exists("data/mental_health_.rda")) {
  cidr <- getwd()
  mkfldr <- "data/"
  dir.create(file.path(cidr, mkfldr), recursive = TRUE)
  osf_retrieve_file("https://osf.io/7peyq/data/input/5efd0743af1156008d3b5532") |>
    osf_download("data/")
  
  # GET RELATED MENTAL FILES
  mental_files = "anxiety|autism|adhd|ptsd|lonely|depression|suicidewatch|bipolarreddit|bpd|addiction|alcoholism|schizophrenia"
  
  data <- list.files(recursive = TRUE,
                     path = "data/reddit_mental_health_dataset",
                     pattern = mental_files,
                     full.names = TRUE) |>
    purrr::map(~read_csv(.))
  
  # COMBINE DATASETS
  red_mh <- data |>
    map_df(bind_rows)
  
  # SELECT IMPORTANT FEATURES FROM DATASET
  features <- c("subreddit", "author",	"date", "post", "n_words", "sent_neg", "sent_neu", "sent_pos", "isolation_total", "economic_stress_total", "domestic_stress_total", "liwc_anger", "liwc_anxiety", "liwc_negative_emotion", "liwc_positive_emotion", "liwc_sadness")
  
  red_mh <- red_mh |>
    select(all_of(features))
  
  # DROP DUPLICATE USER
  red_mh <- unique(red_mh)
  
  # SPLIT DATE IN YEAR MONTH AND DAY
  red_mh <- red_mh |>
    separate(date, c("year", "month", "day"), remove = TRUE)
  
  # SAVE THE FINAL DATASET
  save(red_mh, file="data/mental_health.rda")
  
  # DELETE RAW DATA: 107 FILES, +/- 2.5GB
  unlink("data/reddit_mental_health_dataset", recursive = TRUE)
  
}

# LOAD THE DATASET
load("data/mental_health.rda")



