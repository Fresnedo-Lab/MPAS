
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, magrittr, openxlsx, fs)

# reqpacks <- c("tidyverse","magrittr","openxlsx","fs")
# packstoinstall <- setdiff(reqpacks,installed.packages()[,1])
# if(length(packstoinstall) > 0) install.packages(packstoinstall)
# 
# library(tidyverse)
# library(magrittr)
# library(openxlsx)
# library(fs)

# set working directory
# getwd()
# setwd("/fs/scratch/PAS1755/drw_wd/reduced_primal_by_clustal/primalscheme")
setwd("/Users/aperium/Documents/GitHub/Primal-to-Fluidigm/primalscheme")

# read xlsx file
coverage <- path("coverage.csv") %>%
  read_csv(col_names = TRUE) %>%
  mutate(short.name = as.factor(short.name),
    coverage = parse_number(coverage) / 100)


plots <- coverage %>%
  ggplot(aes(overlap, coverage)) +
  geom_smooth() +
  geom_point() + 
  facet_wrap(vars(short.name)) +
  theme_minimal()

png(file = "coverage_by_overlap.png", width = 1000, height = 1000)
plots
dev.off()




