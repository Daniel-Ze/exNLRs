#!/usr/bin/Rscript
library(ggplot2)

# Saving data from bash script to nlrs
nlrs <- commandArgs( )

# Extracting the file path
nlrs_file <- nlrs[6]

# Extracting directory and file name from path
nlrs_file_path <- dirname( nlrs_file )
nlrs_file_name <- basename( nlrs_file )

print( paste0( "Plotting data from ", nlrs_file_name ) )

# Reading the data as table with tab stop as delimiter
nlrs_tbl <- read.table( nlrs_file,
                        header = FALSE,
                        sep = "\t" )

# Sorting the levels of the file
nlrs_tbl$V2 <- factor( nlrs_tbl$V2,
                       levels = c( "complete NLRs",
                                   "complete CNLs",
                                   "complete TNLs",
                                   "complete NA",
                                   "partial NLRs",
                                   "partial CNLs",
                                   "partial TNLs",
                                   "partial NA",
                                   "total"
                                 )
                      )

# Generating bar plot of data from NLR-parser
ggplot( nlrs_tbl,
        aes( nlrs_tbl$V2,
             nlrs_tbl$V1,
             fill = nlrs_tbl$V2
            )
      )+
  geom_bar( stat = "identity" )+
  ylab( "# NLR" )+
  theme_bw()+
  theme( axis.title.x = element_blank(),
         axis.text.x = element_text( angle = 45,
                                     hjust = 1
                                    ),
         legend.title = element_blank()
        )+
  ggtitle( "NLRparser results" )

# Saving the ploted data as pdf in the directory with NLR results
ggsave( paste0( nlrs_file_name, ".pdf" ),
        path = nlrs_file_path,
        dpi = 300,
        width = 7,
        height = 5
      )

print( paste0( "Plot saved as pdf with 300 dpi (7 x 5 in) in ", nlrs_file_path, "/nlrparser.stats.pdf" ) )
