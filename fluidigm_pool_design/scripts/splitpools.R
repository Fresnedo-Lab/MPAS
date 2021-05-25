
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, magrittr, fs)

path <- path("../out/pools/clustalout")
files <- c("pool1.pim.csv", "pool2.pim.csv")


for (i in 1:length(files)) {
  # read ith file
  edgeweights_i <- read_csv(path(path, files[i]), col_names = TRUE, col_types = "ccd")
  
  
}
