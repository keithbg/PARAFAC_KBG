## Script to combine all the metadata on EEM measurements
## Script outputs the file: eem_sample_info.txt

## Script created April 2018 by KBG


#### LIBRARIES ################################################################
library(tidyverse)
library(stringr)
###############################################################################


#### FILEPATHS ################################################################
dir_input <- file.path("/Users", "kbg", "Documents", "UC_Berkeley", "EEA_DOC", "Aqualog_EEMs", "PARAFAC_KBG")
dir_output <- file.path("/Users", "kbg", "Documents", "UC_Berkeley", "EEA_DOC", "Aqualog_EEMs", "PARAFAC_KBG")
###############################################################################


#### CREATE VECTORS OF DIFFERENT COMBINATIONS OF INTEGRATION AND SAMPLE GAIN SETTINGS

## int_gain= medium and samp_gain= low (2016, March-Jul)
med.low <- c("1603", "1604", "1605", "1607")
match.med.low <- sample.list$yr_mo %in% med.low

## int_gain and samp_gain = low (2016, Aug-Oct and 2017, Apr-May)
low.low <- c("1608", "1609", "1610", "1704", "1705")
match.low.low <- sample.list$yr_mo %in% low.low

## int_gain and samp_gain = med (2017, Jun-Sep)
med.med <- c("1706", "1707", "1708", "1709")
match.med.med <- sample.list$yr_mo %in% med.med

#### READ IN SAMPLE DATA
sample.list <- read_tsv(file.path(dir_input, "eem_int_area.txt")) %>%
                 mutate(base_name= str_replace(.$file_name, "-.+$", ""),
                        yr_mo= str_extract(sample.list$base_name, "^[0-9]+"),
                        int_gain= as.numeric(NA),
                        samp_gain= as.numeric(NA)) %>%
                 select(file_name, base_name, yr_mo, int_area, int_gain, samp_gain) %>%
               ## Fill in the int_gain and samp_gain columns
                 mutate(int_gain= ifelse(match.med.low, "med", .$int_gain),
                        samp_gain= ifelse(match.med.low, "low", .$samp_gain)) %>%
                 mutate(int_gain= ifelse(match.low.low, "low", .$int_gain),
                        samp_gain= ifelse(match.low.low, "low", .$samp_gain)) %>%
                 mutate(int_gain= ifelse(match.med.med, "med", .$int_gain),
                        samp_gain= ifelse(match.med.med, "med", .$samp_gain))
write_tsv(sample.list, path= file.path(dir_output, "eem_sample_info.txt"))











