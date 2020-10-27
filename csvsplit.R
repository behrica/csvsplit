#!/usr/bin/env Rscript


library(readr)
library(dplyr)
library(purrr)
library(tidyr)
library(readr)
library(stringr)
library(optparse)

parser <- OptionParser()
parser <- add_option(parser, c("-i", "--input"), type="character", default="",
                help="Input CSV file")

parser <- add_option(parser, c("-o", "--output"), type="character", default="",
                     help="Output directory")

parser <- add_option(parser, c("-p", "--partitions"), type="character", default="",
                help="Partitions")


opt <- parse_args(parser)
opt

dir = opt$output
partitions = str_split(opt$partitions,",")[[1]]
infile=opt$input

f <- function(x,pos) {
#  print(x %>% colnames)
  x <- x %>% relocate(all_of(partitions))

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
                           append = T))

}
#infile="/home/carsten/tmp/data_100000.csv"

ncols <- read_csv(infile,n_max = 1) %>% ncol

read_csv_chunked(infile, col_types = paste0(rep("c",ncols),collapse = ""),
   SideEffectChunkCallback$new(f),progress = T)

#x = read_csv("/home/carsten/tmp/big.csv", n_max = 100000,col_types = "ccccccccccccccccccc")
#infile
