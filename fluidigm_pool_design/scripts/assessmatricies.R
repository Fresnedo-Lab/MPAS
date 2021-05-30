#!/usr/bin/env Rscript

# name: assessmatricies.R
# author: Daniel R. Williams
# date: 30 May 2021

# Description:
# This script extracts coverage data from json log files.
# 
# input: directory to search for json files with coverage data.
# output: coverage data as a csv file.
# 
# example command:  Rscript assessmatricies.R -d <in_dir> -o <out_dir>
# for help:         Rscript assessmatricies.R -h

if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, magrittr, fs, reshape2, optparse)

# Argument options
option_list = list(
  make_option(c("-d", "--dir"), type="character", default=NULL, 
              help="input directory to search for pim files", metavar="character"),
  make_option(c("-o", "--out"), type="character", default="pools", 
              help="output directory [default= %default]", metavar="character")
); 
opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

# errormessages for arguments
if (is.null(opt$dir)){
  print_help(opt_parser)
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
}

# reqpacks <- c("tidyverse","stringr","magrittr","fs","reshape2")
# packstoinstall <- setdiff(reqpacks,installed.packages()[,1])
# if(length(packstoinstall) > 0) install.packages(packstoinstall)
# 
# library(tidyverse)
# library(stringr)
# library(magrittr)
# library(fs)
# library(reshape2)

# set working directory
# getwd()
#setwd("/fs/scratch/PAS1755/drw_wd/Primal-to-Fluidigm/fluidigm_pool_design/scripts")
setwd("/Users/aperium/Documents/GitHub/Primal-to-Fluidigm/fluidigm_pool_design/scripts")

path <- path("../out/pools/clustalout/")

files <- c("pool1.pim","pool2.pim")

# matrix1 <- read_table(files[1], col_names = FALSE, skip = 6) %>%
#   select(-X1) %>%
#   column_to_rownames("X2")
# names(matrix1) <- unlist(rownames(matrix1))
# matrix1[!lower.tri(matrix1)] <- NA
# 
# 
# melted1 <- matrix1 %>%  
#   as.matrix() %>%
#   melt()
# 
# dedupe1 <- melted1 %>%
#   filter(!is.na(value), Var1 != Var2)
# 
# dedupe1 %>% 
#   # filter(value <100 & value >= 80) %>% 
#   arrange(desc(value)) %>% 
#   write_csv()


for (i in 1:length(files)) {
  # read ith file
  matrix_i <- read_table(path(path, files[i]), col_names = FALSE, skip = 1, col_types = cols(.default = col_double(),X1 = col_character())) %>%
    column_to_rownames("X1")
  names(matrix_i) <- unlist(rownames(matrix_i))
  matrix_i[!lower.tri(matrix_i)] <- NA
  
  # melt ith file's data
  melted_i <- matrix_i %>%  
    as.matrix() %>%
    melt()
  
  # remove duplicates from ith data set
  dedupe_i <- melted_i %>%
    filter(!is.na(value), Var1 != Var2)
  
  # arrange and print to file
  dedupe_i %>% 
    # filter(value <100 & value >= 80) %>% 
    arrange(desc(value)) %>% 
    write_csv(file = path(path,paste0(files,".csv")[i]))
}
