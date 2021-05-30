#!/usr/bin/env Rscript

# name: splitpools.R
# author: Daniel R. Williams
# date: 30 May 2021

# Description:
# This script 
# 
# input: directory to search for .pim.csv files with coverage data.
# output: a directory with fasta files of new pools
# 
# example command:  Rscript splitpools.R -d <in_dir> -o <out_dir>
# for help:         Rscript splitpools.R -h

if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, magrittr, fs, optparse)

# Argument options
option_list = list(
  make_option(c("-d", "--dir"), type="character", default=NULL, 
              help="input directory to search for pim.csv files", metavar="character"),
  make_option(c("-o", "--out"), type="character", default="pairwise", 
              help="output directory [default= %default]", metavar="character")
); 
opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

# errormessages for arguments
if (is.null(opt$dir)){
  print_help(opt_parser)
  stop("At least one argument must be supplied (input directory).n", call.=FALSE)
}

inpath <- path(opt$dir)
outpath <- path(opt$out)
pimcsvfilelist <- path("pimcsvfilelist.txt")

system(paste("ls", paste0(inpath, "/*.pim.csv"), ">", pimcsvfilelist))
pimcsvfiles <- read_csv(pimcsvfilelist, col_names = FALSE) %>% .$X1
file_delete(pimcsvfilelist)

dir_create(outpath)

for (i in 1:length(pimcsvfiles)) {
  # read ith file
  edgeweights_i <- read_csv(path(pimcsvfiles[i]), col_names = TRUE, col_types = "ccd")
  
  
}
