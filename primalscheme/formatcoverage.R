
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, magrittr, stringr, openxlsx, fs)

# reqpacks <- c("tidyverse","stringr","magrittr","openxlsx","fs")
# packstoinstall <- setdiff(reqpacks,installed.packages()[,1])
# if(length(packstoinstall) > 0) install.packages(packstoinstall)
# 
# library(tidyverse)
# library(stringr)
# library(magrittr)
# library(openxlsx)
# library(fs)

# set working directory
# getwd()
# setwd("/fs/scratch/PAS1755/drw_wd/reduced_primal_by_clustal/primalscheme")
setwd("/Users/aperium/Documents/GitHub/Primal-to-Fluidigm/primalscheme")

# get arguments
args = commandArgs(trailingOnly = TRUE)
if (length(args) == 0) {
  ampminarg <- NA
  ampmaxarg <- NA
  overlaparg <- NA 
} else {
    ampminarg <- args[1]
    ampmaxarg <- args[2]
    overlaparg <- args[3]
}

# read tsv file
coverage <- path("coverage.tsv") %>%
  read_tsv(col_names = FALSE) %>%
  select(short.name = X1,
         regions = X2,
         gaps = X4,
         coverage = X6,
         overlap = X8) #%>%
  #mutate (ampmin = as.double(ampminarg),
         #ampmax = as.double(ampmaxarg),
         #overlap = if(!is.na(overlaparg)) as.double(overlaparg) else overlap)

# join with existing data if availible.
#if(file_exists(path = "coverage.csv")) {
#  coverage <- read_csv("coverage.csv") %>%
#    full_join(coverage)
#}

# print csv file
coverage %>%
  write_csv("coverage.csv")

