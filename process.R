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

# Get data, rename cols
# Split out gene symbol so it can be merged with existing table
# Some duplicates for unknown reason - resolve with slice
proteinData <- fread(file.path(inputDir, 'protein_brick_20160906_200338_human.txt'), 
                     data.table=FALSE,
                     select=keepCols.protein) %>% 
  filter(!(protein %in% c("not_available", "not_yet_specified"))) %>% 
  separate(protein, into=c('gene_symbol', 'other_identifier'), sep="_", 
           remove=FALSE, extra="merge") %>% 
  rename(ID=lincs_identifier, Definition=lincs_name) %>% 
  distinct() %>% 
  group_by(gene_symbol) %>%
  slice(n=1) %>%
  ungroup()

resProtein <- synTableQuery("SELECT * FROM syn5662377 where Category in ('Ligand', 'ECM Protein')")

qProtein <- resProtein@values %>% 
  dplyr::add_rownames(var="row_id_version") %>% 
  select(-ID, -Definition) %>% 
  separate("row_id_version", c("ROW_ID", "ROW_VERSION")) %>% 
  filter(MetadataTerm %in% proteinData$gene_symbol) %>% 
  left_join(proteinData[, c("gene_symbol", "Definition", "ID")], 
            by=c("MetadataTerm"="gene_symbol"))

rownames(qProtein) <- paste(qProtein$ROW_ID, qProtein$ROW_VERSION, sep="_")
qProtein <- qProtein %>% select(-ROW_ID, -ROW_VERSION)

resProtein@values <- qProtein
synStore(resProtein)
