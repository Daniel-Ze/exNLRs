#!/usr/bin/Rscript
library(ggplot2)

nlrs <- commandArgs()
nlrs_file <- nlrs[6]
nlrs_file_path <- dirname(nlrs_file)
nlrs_file_name <- basename(nlrs_file)

print(paste0("Plotting data from ", nlrs_file_name))

nlrs_tbl <- read.table(nlrs_file,
                       header=FALSE,
                       sep='\t')

nlrs_tbl$V2 <- factor(nlrs_tbl$V2,
                      levels = c("complete NLRs",
                                 "complete CNLs",
                                 "complete TNLs",
                                 "partial NLRs",
                                 "partial CNLs",
                                 "partial TNLs",
                                 "total"))

ggplot(nlrs_tbl,
       aes(nlrs_tbl$V2,
           nlrs_tbl$V1,
           fill=nlrs_tbl$V2))+
  geom_bar(stat="identity")+
  ylab("# NLR")+
  theme_bw()+
  theme(axis.title.x=element_blank(),
        axis.text.x=element_text(angle=45,
                                 hjust=1),
        legend.title=element_blank())+
  ggtitle("NLRparser results")

ggsave(paste0(nlrs_file_name, ".pdf"),
       path=nlrs_file_path,
       dpi=300,
       width=7,
       height=5)

print(paste0("Plot saved as pdf in ", nlrs_file_path, "/nlrparser.stats.pdf"))
