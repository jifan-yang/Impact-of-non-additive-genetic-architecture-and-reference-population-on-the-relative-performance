library(ggplot2)
library(dplyr)

ARGS<-commandArgs(trailingOnly=T)
ldfile <- ARGS[1]

# read ld file
ld <- read.table(ldfile)

# plot
ld %>%
  ggplot(aes(x = V1, y = V2), data = .) +
  geom_line()+
  theme_classic()
 ggsave(paste0(ldfile, ".png"), width = 80, height = 80, units = "mm")
 