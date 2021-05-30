#!/usr/bin/env Rscript

# name: makefastas.R
# author: Daniel R. Williams
# date: 29 May 2021

# Description:
# This script produces a set of fasta files, each constaining a single nucleotide sequence.
# 
# input: an xlsx workbook containing the list of sequences.
# output: a directory containing fasta files of each sequence.
# 
# example command:  Rscript makefastas.R -f <file.xlsx> -o <fasta_dir> -s 4
# for help:         Rscript makefastas.R -h


# Load packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, magrittr, stringr, openxlsx, fs, optparse)

# Argument optiosn
option_list = list(
  make_option(c("-f", "--file"), type="character", default=NULL, 
              help="dataset file name", metavar="character"),
  make_option(c("-o", "--out"), type="character", default="out", 
              help="output file directory [default= %default]", metavar="character"),
  make_option(c("-s", "--sheet"), type="numeric", default="1", 
              help="sheet in workbook [default= %default]", metavar="numeric")
); 
opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

# errormessages for arguments
if (is.null(opt$file)){
  print_help(opt_parser)
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
}



# pull commandline arguments
# args = commandArgs(trailingOnly=TRUE)


# set primal scheme parameters
# if (length(args) == 0) {
#   ampmin <- 180
#   ampmax <- 500
#   overlap <- 70 
#   sheet <- 4
#   name <- "Short.name"
#   seq <- "seq"
# } else {
#     ampmin <- args[2]
#     ampmax <- args[3]
#     overlap <- args[4]
#     sheet <- args[5]
#     name <- args[6]
#     seq <- args[7]
# }

name <- "Short.name"
seq <- "seq"

# read xlsx file
inpath <- path(opt$file)
sheet <- opt$sheet
seqs <- inpath %>%
  read.xlsx(sheet = sheet) %>%
  select(all_of(name), all_of(seq))




# pull sequence short_name and sequence from file
# write unique fastas for each short_name and sequence
# and prepare shell file for execution of each file with named output
# outfile <- "runprimalscheme.sh" # name of shell script
# dir_create(paste0("overlap_",overlap))

#command <- paste("primalscheme multiplex -a", ampmin, "-a", ampmax, "-t", overlap)

# if(file_exists(path = outfile)) file_delete(path = outfile)
# paste("#!/bin/bash", "\n") %>% write_file(file = outfile, append = TRUE)

dir_create(path(opt$out))
for (i in 1:length(seqs$Short.name)) {
  fastapath <- path(opt$out,paste0(seqs$Short.name[i],".fasta"))
  # outpath <- path(paste0("overlap_",overlap,"/",seqs$Short.name[i]))
  
  # make fastas
  file_create(fastapath)
  paste0(">",seqs$Short.name[i],"\n",seqs$seq[i]) %>% write_file(file = fastapath)
  
  # make/append shell file
  # paste(command, "-n", seqs$Short.name[i], "-o", outpath, "-f", fastapath, "\n") %>%
  #   write_file(file = outfile, append = TRUE)
}
