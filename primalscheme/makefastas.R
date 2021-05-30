#!/usr/bin/env Rscript

# author: Daniel R. Williams
# date: 29 May 2021

# Load packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, magrittr, stringr, openxlsx, fs, optparse)

# Argument optiosn
option_list = list(
  make_option(c("-f", "--file"), type="character", default=NULL, 
              help="dataset file name", metavar="character"),
  make_option(c("-o", "--out"), type="character", default="out", 
              help="output file directory [default= %default]", metavar="character"),
  make_option(c("-s", "--sheet"), type="character", default="1", 
              help="sheet in workbook [default= %default]", metavar="character")
); 
opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

# errormessages for arguments
if (is.null(opt$file)){
  print_help(opt_parser)
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
}



# pull commandline arguments
args = commandArgs(trailingOnly=TRUE)

# set file path
inpath <- path(args[1])

# set primal scheme parameters
if (length(args) == 0) {
  ampmin <- 180
  ampmax <- 500
  overlap <- 70 
  sheet <- 4
  name <- "Short.name"
  seq <- "seq"
} else {
    ampmin <- args[2]
    ampmax <- args[3]
    overlap <- args[4]
    sheet <- args[5]
    name <- args[6]
    seq <- args[7]
}

# read xlsx file
seqs <- inpath %>%
  read.xlsx(sheet = sheet) %>%
  select(all_of(name), all_of(seq))

# pull sequence short_name and sequence from file
# write unique fastas for each short_name and sequence
# and prepare shell file for execution of each file with named output
outfile <- "runprimalscheme.sh" # name of shell script
dir_create(paste0("overlap_",overlap))

command <- paste("primalscheme multiplex -a", ampmin, "-a", ampmax, "-t", overlap)
if(file_exists(path = outfile)) file_delete(path = outfile)
paste("#!/bin/bash", "\n") %>% write_file(file = outfile, append = TRUE)
for (i in 1:length(seqs$Short.name)) {
  fastapath <- path(paste0("fastas/",seqs$Short.name[i],".fasta"))
  outpath <- path(paste0("overlap_",overlap,"/",seqs$Short.name[i]))
  
  # make fastas
  file_create(fastapath)
  paste0(">",seqs$Short.name[i],"\n",seqs$seq[i]) %>% write_file(path = fastapath)
  
  # make/append shell file
  paste(command, "-n", seqs$Short.name[i], "-o", outpath, "-f", fastapath, "\n") %>%
    write_file(file = outfile, append = TRUE)
}
