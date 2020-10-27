#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(readr,quietly = T)
  library(dplyr,quietly = T)
  library(purrr)
  library(tidyr)
  library(readr)
  library(stringr)
  library(optparse)
})

parser <- OptionParser()
parser <- add_option(parser, c("-i", "--input"), type="character", default="",
                help="Input CSV file")

parser <- add_option(parser, c("-o", "--output"), type="character", default="",
                     help="Output directory")

parser <- add_option(parser, c("-p", "--partitions"), type="character", default="",
                help="Partitions")


opt <- parse_args(parser)
#opt

dir = opt$output
partitions = str_split(opt$partitions,",")[[1]]
infile=opt$input


if (dir.exists(dir)) {
  stop(paste0("Target dir exists already: ",dir))
}

f <- function(x,pos) {
                                        #  print(x %>% colnames)
  x <- x %>%
    relocate(all_of(partitions))

  x %>% distinct_at(all_of(partitions)) %>%
    tidyr::unite(dirs,sep="/") %>%
    pull(dirs)  %>%
    walk(~ dir.create(paste0(dir,"/",.x),recursive = T,showWarnings = F))

  x %>%
    group_by_at(all_of(partitions))  %>%
    group_walk(~ write_csv(.x,
                           path=paste0(dir,"/",
                                       .y %>% tidyr::unite(dirs,sep="/") %>% pull(dirs) %>% magrittr::extract(1),
                                       "/",
                                       "data.csv"),
                           append = (pos==1)))

}

col_names <-  suppressMessages(names(spec_csv(infile)$cols))

#ncols <- suppressMessages(read_csv(infile,n_max = 1)) %>% ncol
ncols <- length(col_names)
dummy  <-  read_csv_chunked(infile, col_types = paste0(rep("c",ncols),collapse = ""),
   SideEffectChunkCallback$new(f),progress = T)

