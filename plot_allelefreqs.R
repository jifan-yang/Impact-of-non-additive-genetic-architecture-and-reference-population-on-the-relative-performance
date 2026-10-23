# plot allele frequency distributions of all breeds together #
options(stringsAsFactors = FALSE)
require(tidyr)
require(dplyr)
require(ggplot2)
require(gridExtra)
pdf(NULL)

ARGS<-commandArgs(trailingOnly=T)

repl<-ARGS[1]
breed <- ARGS[2]
gen <- ARGS[3]
loctype<-ARGS[4]

locfile <- ifelse(loctype == "qtl", paste0("qtlloci_", repl, ".dat"), 
  paste0("markerloci_", breed, "_", repl, ".dat"))

# read allele frequencies
af <- read.table(paste0(repl,"/allelefreq_",breed,"_",gen,".dat"), header=FALSE)[,1]

# filter relevant loci (markers or qtl)
locs <- read.table(locfile, header=FALSE)[,1]
af <- af[locs]
nloc <- length(af)

# compute number of segregating loci 
nseg <- length(af[af > 0.00 & af < 1.00])

# plot distribution of allele frequencies
af_df <- data.frame(af = af)
p <- ggplot(af_df, aes(x=af))+
  geom_histogram(binwidth = 0.02, fill="white", color="black", linewidth=0.1)+
  ggtitle(paste0(breed,", N segregating = ", nseg))+
  labs(x="allele frequency", y="Percentage")+
  theme_classic()
  ggsave(paste0(repl, "/af_",breed,"_", loctype,"_", repl, ".png"), width=85, height=85, units="mm", scale = 1.3)
  