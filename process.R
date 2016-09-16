library(data.table)
library(plyr)
library(dplyr)
library(reshape2)
library(stringr)
library(tidyr)

library(synapseClient)
synapseLogin()

keepCols.protein <- c("protein", "lincs_name", "lincs_identifier")
  
inputDir <- '/home/kdaily/Projects/LINCS/data/AnnotMetadata/20160906_annot_brick_txt_download'

proteinData <- fread(file.path(inputDir, 'protein_brick_20160906_200338_human.txt'), 
                     data.table=FALSE,
                     select=keepCols.protein) %>% 
  rename()
  
