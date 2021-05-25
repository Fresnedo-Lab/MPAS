
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, magrittr, fs)

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

# read csv file
coverage <- path("coverage2.csv") %>%
  read_csv(col_names = TRUE) %>%
  mutate(reference = as.factor(reference),
         percent_coverage = percent_coverage / 100)


plots <- coverage %>%
  ggplot(aes(config_target_overlap, percent_coverage)) +
  geom_smooth() +
  geom_point() + 
  facet_wrap(vars(name)) +
  theme_minimal()

png(file = "coverage_by_overlap2.png", width = 1000, height = 1000)
plots
dev.off()




