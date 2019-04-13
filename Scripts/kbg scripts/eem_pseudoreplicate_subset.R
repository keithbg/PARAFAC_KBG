## This script randomly selects the filename of 1 of the 2
## sample replicates collected at each sampling event. These replicates
## are actually pseudoreplicates, so only 1 of them should be used for the model
## No end member's are pseudoreplicates.

## Script outputs the file: eem_sample_list_subset.txt

## Script created April 2018 by KBG


#### LIBRARIES ################################################################
library(tidyverse)
library(stringr)
###############################################################################


#### FILEPATHS ################################################################
dir_input <- file.path("/Users", "kbg", "Documents", "UC_Berkeley", "EEA_DOC", "Aqualog_EEMs", "PARAFAC_KBG")
#dir_input_eems <- file.path("/Users", "kbg", "Documents", "UC_Berkeley", "EEA_DOC", "Aqualog_EEMs", "PARAFAC_KBG", "EEMs_EX_3nm")
dir_output <- file.path("/Users", "kbg", "Documents", "UC_Berkeley", "EEA_DOC", "Aqualog_EEMs", "PARAFAC_KBG")
###############################################################################


#### GET FILENAMES OF ALL PROCESSED CONTOUR .DAT FILES
#file.names <- list.files(pattern="*-ProcessedContour_IFE_RM_NRM.dat", path= dir_input_eems, full.names= TRUE)
#sampleID <- str_replace(list.files(pattern="*-ProcessedContour_IFE_RM_NRM.dat", path= dir_input_eems)[1], "-.+$", "")


#### READ IN SAMPLE LIST AND GAIN RATIO INFORMATION
sample.list <- read_tsv(file.path(dir_input, "eem_sample_info.txt")) %>%
                mutate(replicate= as.numeric(str_extract(.$base_name, "[0-9]$")),
                       type= str_replace(.$base_name, "[^_]*_[^_]*_([^_]*)_[^-]", "\\1"),
                       sample= str_replace(.$base_name, "([^_]*_[^_]*_[^_]*)_[^-]", "\\1")) %>%
               group_by(sample) %>%
            # Use "sample" command to randomly select rep 1 or 2
              mutate(select= sample(1:2, 1),
                      count= n()) %>%
               ungroup()

## Randomly select 1 of the 2 water sample replicates
subset.pseudoreplicates <- sample.list %>%
                             filter(count == 2 & type == "SMP") %>%
                             filter(select == replicate)

## Combine the data sets together
subset.sample.list <- sample.list %>%
                       filter(!(count == 2 & type == "SMP")) %>%
                       rbind(., subset.pseudoreplicates) %>%
                       select(-type, -select, -replicate, -sample, -count)

write_tsv(subset.sample.list, path= file.path(dir_output, "eem_sample_list_subset.txt"))

