#!/usr/bin/env Rscript

# name: separatepools.R
# author: Daniel R. Williams
# date: 29 May 2021

# Description:
# This script extracts coverage data from json log files.
# 
# input: directory to search for json files with coverage data.
# output: coverage data as a csv file.
# 
# example command:  Rscript separatepools.R -d <dir> -o <file.csv>
# for help:         Rscript separatepools.R -h

if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, magrittr, fs, optparse)

# Argument options
option_list = list(
  make_option(c("-d", "--dir"), type="character", default=NULL, 
              help="directory name to search for json files", metavar="character"),
  make_option(c("-o", "--out"), type="character", default="coverage2.csv", 
              help="output file name [default= %default]", metavar="character")
); 
opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

# errormessages for arguments
if (is.null(opt$dir)){
  print_help(opt_parser)
  stop("At least one argument must be supplied (input directory).n", call.=FALSE)
}



outpath <- path("../out/pools")

# get arguments
args = commandArgs(trailingOnly = TRUE)
if (length(args) == 0) infile <- path("../out/allprimers.tsv") else infile <- args[1]

# read tsv file
data <- infile %>%
  read_tsv(col_names = TRUE) %>%
  # remove the clusters to prevent problems
  filter(!str_detect(name, "cluster"))
  
# produce a unique csv and fasta file for each pool
dir_create(outpath)
for (i in unique(data$pool)) {
  tmp_pool <- data %>%
    filter(pool == i)
  
  # make csv files
  tmp_pool %>% write_csv(paste0(outpath,"/pool",i,".csv"))
  
  # make fasta files
  fastapath <- path(paste0(outpath,"/pool",i,".fasta"))
  #file.remove(fastapath)
  file_create(fastapath)
  #printer <- file(fastapath,"w")
  # output <- paste0(">",tmp_pool$gene,"|",tmp_pool$name,"|pool_",tmp_pool$pool,"|size_",tmp_pool$size,"|%gc_",tmp_pool$`%gc`,"|tm_",tmp_pool$`tm (use 65)`,"\n",tmp_pool$seq)
  output <- paste0(">",tmp_pool$name,"\n",tmp_pool$seq)
  #write_lines(output, printer, sep = "\n")
  readr::write_lines(x = output, file = path(fastapath), sep = "\n")
  #close(printer)
  
}


