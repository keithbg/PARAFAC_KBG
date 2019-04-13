## Script to subset the 3rd nm from excitation wavelengths of aqualog EEMs
## I switched Aqualog parameters from 3nm to 1nm in June 2016,
## so all EEms after this date need to be subset to every 3nm in order to combine
## with the EEMs collected before this date.

## Script writes new eems to the <dir_output> folder

## Script created March 2018 by KBG

#### LIBRARIES ################################################################
library(tidyverse)
library(stringr)
###############################################################################


eems.ex.3nm <- function(){

#### FILEPATHS ################################################################
dir_input_eems <- file.path("/Users", "kbg", "Documents", "UC_Berkeley", "EEA_DOC", "Aqualog_EEMs", "PARAFAC_KBG", "EEMs_Raw")
dir_output <- file.path("/Users", "kbg", "Documents", "UC_Berkeley", "EEA_DOC", "Aqualog_EEMs", "PARAFAC_KBG", "EEMs_EX_3nm")
###############################################################################


#### GET FILENAMES OF ALL PROCESSED CONTOUR .DAT FILES
# Initialize empty vectors
dirs.sample <- list.dirs(dir_input_eems, recursive = FALSE)
file.names <- as.character(NULL)

for(folder in seq(1:length(dirs.sample))){
  file_path <- file.path(dirs.sample[folder], "data_export")
  file.names <- c(file.names, list.files(pattern="*Processed Contour_ IFE_RM_NRM.dat", path= file_path, full.names= TRUE))
}

#### LIST OF WAVELENGTHS EVERY 3nm FROM 240-600nm
ex.wavelengths <- seq(240, 600, by= 3)

#### LOOP TO EXTRACT EVERY 3RD EX WAVELENGTH FROM EACH EEM
for(f in seq(1:length(file.names))){
  # Read in each file and round the emission wavelengths
  eem.df <-   read_table2(file.names[f], skip= 3, col_names = FALSE,
                          col_types = cols(
                            X1= col_double(),
                            X2= col_double(),
                            X3= col_double())) %>%
              rename(ex= X1, em= X2, z= X3)

  # Extract unique sampleID from file path and make new file name
  sampleID <- gsub("(^.*/)|( .*$)", "", file.names[f])
  file_name <- str_c(sampleID, "-ProcessedContour_IFE_RM_NRM.dat")

  # Write error if a sample fails to be read in correctly
  if(any(is.na(eem.df) == TRUE)){
    stop(paste("sample:", sampleID, "failed to load, check NAs"))
  }

  # Extract every 3rd nm from excitation wavelengths
  eem.3nm <- eem.df %>%
    filter(ex %in% ex.wavelengths) %>%
    arrange(-ex, em)

  # Write new .dat file
  write_tsv(eem.3nm, path= file.path(dir_output, file_name))
}

}

# Run function
eems.ex.3nm()
