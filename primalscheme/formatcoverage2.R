#!/usr/bin/env Rscript

# name: formatcoverage2.R
# author: Daniel R. Williams
# date: 30 May 2021

# Description:
# This script extracts coverage data from json log files.
# 
# input: directory to search for json files with coverage data.
# output: coverage data as a csv file.
# 
# example command:  Rscript formatcoverage2.R -d <dir> -o <file.csv>
# for help:         Rscript formatcoverage2.R -h

if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, magrittr, fs, rjson, optparse)

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

# just tests
# fromJSON(file = "overlap_40/1_FEH_TK/1_FEH_TK.report.json")
# jsonfiles <- path("overlap_40/1_FEH_TK/1_FEH_TK.report.json")

# make a list of all relevant json files
jfilelist <- path("jsonlist.txt")
jsearchpath <- path(opt$dir,"overlap_*/*/*", ext = "json")
system(paste("for name in", gsub(" ", "\\\ ", jsearchpath, fixed = TRUE), "; do echo \"$name\" | sed -f / >>", jfilelist, "; done"))
jsonfiles <- read_csv(jfilelist, col_names = FALSE) %>% .$X1
file_delete(jfilelist)

# extract data from all the JSON files produced by PrimalScheme
JSONfromfile <- function(file) fromJSON(file = file)
jsondatalist <- lapply(jsonfiles, JSONfromfile)
names(jsondatalist) <- jsonfiles
# jsondata <- sapply(jsonfiles, JSONfromfile)


# extract coverage data
json_to_tibble <- function(tmpjson) {
  tmptib <- tibble(
    reference = tmpjson$references,
    regions = tmpjson$regions,
    percent_coverage = tmpjson$percent_coverage,
    gaps = tmpjson$gaps,
    config_step_distance = tmpjson$config$step_distance,
    config_target_overlap = tmpjson$config$target_overlap,
    config_amplicon_size_min = tmpjson$config$amplicon_size_min,
    config_amplicon_size_max = tmpjson$config$amplicon_size_max,
    config_high_gc = tmpjson$config$high_gc,
    config_primalscheme_version = tmpjson$config$primalscheme_version,
    config_primary_only = tmpjson$config$primary_only,
    config_primer_size_min = tmpjson$config$primer_size_range$min,
    config_primer_size_max = tmpjson$config$primer_size_range$max,
    config_primer_size_opt = tmpjson$config$primer_size_range$opt,
    config_primer_gc_min = tmpjson$config$primer_gc_range$min,
    config_primer_gc_max = tmpjson$config$primer_gc_range$max,
    config_primer_gc_opt = tmpjson$config$primer_gc_range$opt
  )
  return(tmptib)
}
jsondataflatterlist <- lapply(jsondatalist, json_to_tibble)
jsondatatibble <- tibble(
  reference = NA,
  regions = NA,
  percent_coverage = NA,
  gaps = NA,
  config_step_distance = NA,
  config_target_overlap = NA,
  config_amplicon_size_min = NA,
  config_amplicon_size_max = NA,
  config_high_gc = NA,
  config_primalscheme_version = NA,
  config_primary_only = NA,
  config_primer_size_min = NA,
  config_primer_size_max = NA,
  config_primer_size_opt = NA,
  config_primer_gc_min = NA,
  config_primer_gc_max = NA,
  config_primer_gc_opt = NA,
  name = NA
)
for (i in 1:length(jsondataflatterlist)) {
  jsondatatibble %<>% rbind(jsondataflatterlist[[i]] %>% mutate(name = jsonfiles[i] %>% str_split("/") %>% unlist() %>% .[2]) )
}
jsondatatibble %<>% na.omit()
# for (i in jsondataflatterlist) {
#   jsondatatibble %<>% full_join(i)
# }

# print csv file
jsondatatibble %>%
  write_csv(file = opt$out)

