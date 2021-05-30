#!/usr/bin/env Rscript

# name: analyzecoverage2.R
# author: Daniel R. Williams
# date: 30 May 2021

# Description:
# This script extracts coverage data from json log files.
# 
# input: directory to search for json files with coverage data.
# output: coverage data as a csv file.
# 
# example command:  Rscript analyzecoverage2.R -f <file.csv> -o <file.png>
# for help:         Rscript analyzecoverage2.R -h

if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, magrittr, fs, optparse)

# Argument options
option_list = list(
  make_option(c("-f", "--file"), type="character", default=NULL, 
              help="input file path", metavar="character"),
  make_option(c("-o", "--out"), type="character", default="coverage_by_overlap.png", 
              help="output file path [default= %default]", metavar="character")
); 
opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

# errormessages for arguments
if (is.null(opt$file)){
  print_help(opt_parser)
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
}

# reqpacks <- c("tidyverse","magrittr","openxlsx","fs")
# packstoinstall <- setdiff(reqpacks,installed.packages()[,1])
# if(length(packstoinstall) > 0) install.packages(packstoinstall)
# 
# library(tidyverse)
# library(magrittr)
# library(openxlsx)
# library(fs)

# read csv file
coverage <- path(opt$file) %>%
  read_csv(col_names = TRUE) %>%
  mutate(reference = as.factor(reference),
         percent_coverage = percent_coverage / 100)


plots <- coverage %>%
  ggplot(aes(config_target_overlap, percent_coverage)) +
  geom_smooth() +
  geom_point() + 
  facet_wrap(vars(name)) +
  theme_minimal()

png(file = opt$out, width = 1000, height = 1000)
plots
dev.off()




