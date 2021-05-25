if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, magrittr, fs)

# set working directory
#setwd("/fs/scratch/PAS1755/drw_wd/Primal-to-Fluidigm/fluidigm_pool_design/scripts")
setwd("/Users/aperium/Documents/GitHub/Primal-to-Fluidigm/fluidigm_pool_design/scripts")

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


