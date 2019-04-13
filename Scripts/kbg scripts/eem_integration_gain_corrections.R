## Script to make corrections to Z values based on the gain ratio
## I collected EEMs with medium and low gain, so Z values need to be
## adjusted depending on the gain settings.
## All samples will be standardized to low gain

## This script implements the gain ratio calcuated in the
## eem_gain_ratio.R script

## Also corrects for dilutions in the end member samples

## Script writes new EEM files to the <dir_output_eems> folder

## Script created Apr 2018 by KBG

#### LIBRARIES ################################################################
library(tidyverse)
library(stringr)
###############################################################################


#### FILEPATHS ################################################################
dir_input <- file.path("/Users", "kbg", "Documents", "UC_Berkeley", "EEA_DOC", "Aqualog_EEMs", "PARAFAC_KBG")
dir_input_eems <- file.path("/Users", "kbg", "Documents", "UC_Berkeley", "EEA_DOC", "Aqualog_EEMs", "PARAFAC_KBG", "EEMs_EX_3nm")
dir_output_eems <- file.path("/Users", "kbg", "Documents", "UC_Berkeley", "EEA_DOC", "Aqualog_EEMs", "PARAFAC_KBG", "EEMS_EX_3nm_corrected")
###############################################################################


#### GET FILENAMES OF ALL PROCESSED CONTOUR .DAT FILES
  file.names <- list.files(pattern="*-ProcessedContour_IFE_RM_NRM.dat", path= dir_input_eems, full.names= TRUE)
#sampleID <- str_replace(list.files(pattern="*-ProcessedContour_IFE_RM_NRM.dat", path= dir_input_eems)[1], "-.+$", "")


#### READ IN SAMPLE LIST, GAIN RATIO INFORMATION, AND DILUTION INFORMATION
sample.list <- read_tsv(file.path(dir_input, "eem_sample_info.txt"))
source("/Users/kbg/Documents/UC_Berkeley/EEA_DOC/Aqualog_EEMs/PARAFAC_KBG/Scripts/eem_gain_ratio.R")
gain.med.low.ratio <- calculate.gain.ratio()
dilute.df <- read_tsv(file.path(dir_input, "EM_dilutions.txt"))


#### LOOP TO CORRECT Z VALUES ACCORDING TO DILUTION AND GAIN SETTINGS
for(file in seq(1:length(file.names))){
  ## Read in file and extract gain setting information
  eem.df <-   read_tsv(file.names[file],
                          col_types = cols(
                            ex= col_double(),
                            em= col_double(),
                            z= col_double()))

  sampleID <- str_replace(list.files(pattern="*-ProcessedContour_IFE_RM_NRM.dat", path= dir_input_eems)[file], "-.+$", "")
  gain.info <- sample.list %>%
                 filter(base_name == sampleID)

  ## Calculate dilution factor
  if(sampleID %in% dilute.df$base_name){
    dilution.factor <- pull(dilute.df %>%
                        filter(base_name == sampleID) %>%
                        select(dilution))
    } else {
      dilution.factor <- 1
    }

  ## Divide by dilution factor
  eem.df$z <- eem.df$z / dilution.factor

  ## Sample gain= medium
  ## divide Z by ratio b/c medium gain is more sensitve, overestimating fluorescence
  if(gain.info$samp_gain == "med"){
    eem.df$z <- eem.df$z / gain.med.low.ratio
  }

  ## Int. gain= medium & sample gain= low
  ## multiply by ratio b/c divided Z values by too large a number
  if(gain.info$int_gain == "med" & gain.info$samp_gain == "low"){
    eem.df$z <- eem.df$z * gain.med.low.ratio
  }

  ## Write new .dat file
  file_name <- str_c(sampleID, "-ProcessedContour_IFE_RM_NRM.dat")
  write_tsv(eem.df, path= file.path(dir_output_eems, file_name))
}


