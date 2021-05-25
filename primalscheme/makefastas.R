if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, magrittr, stringr, openxlsx, fs)

# set working directory
# getwd()
# setwd("/fs/scratch/PAS1755/drw_wd/Primal-to-Fluidigm/primalscheme/")
setwd("/Users/aperium/Documents/GitHub/Primal-to-Fluidigm/primalscheme")

# set primal scheme parameters
args = commandArgs(trailingOnly = TRUE)
if (length(args) == 0) {
  ampmin <- 180
  ampmax <- 500
  overlap <- 70 
  inpath <- path("TK_Amplicons_090319.xlsx")
  sheet <- 4
  name <- "Short.name"
  seq <- "seq"
} else {
    ampmin <- args[1]
    ampmax <- args[2]
    overlap <- args[3]
    inpath <- path(args[4])
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
