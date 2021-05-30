#!/usr/bin/env Rscript

# name: assessmatricies.R
# author: Daniel R. Williams
# date: 30 May 2021

# Description:
# This script turns the pim matricies into pairwise comparisons.
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
pimfilelist <- path("pimfilelist.txt")

# files <- c("pool1.pim","pool2.pim")
# inpath <- path("/Users/aperium/Dropbox/Projects/OSU-HCS/Taraxacum/HarnessingVLHSV/Primal-to-Fluidigm_Data/fluidigm_pool_design/out/pools/clustalout")
system(paste("ls", paste0(inpath, "/*.pim"), ">", pimfilelist))
pimfiles <- read_csv(pimfilelist, col_names = FALSE) %>% .$X1
file_delete(pimfilelist)


dir_create(outpath)

for (i in 1:length(pimfiles)) {
  # read ith file
  matrix_i <- read_table(path(pimfiles[i]), col_names = FALSE, skip = 1, col_types = cols(.default = col_double(),X1 = col_character())) %>%
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
    write_csv(file = path(outpath, paste0(basename(pimfiles),".csv")[i]))
}
