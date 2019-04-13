library(tidyverse)
library(staRdom)

### Import data

processed <- list.files("../EEMs_EX_3nm_corrected_subset")

data <- list()

for (i in 1:length(processed)) {
  data[[i]] <- read_tsv(paste0("../EEMS_EX_3nm_corrected_subset/", processed[i]), skip = 0, col_names = TRUE)
  names(data)[i] <- processed[i]
}

### trim data

trim <- lapply(data, function(x) filter(x, 
                                        em>.95*ex+50, 
                                        em<2*ex-30,
                                        ex>245,
                                        em<(-.5*ex)+750)) #remove component 6
                                                        #which had 0 openfluor
                                                        #matches



### sample names

names <- str_extract(processed, pattern = ".*\\-") %>%
  str_sub(end = -2)

### write to .csv (to appease staRdom)

temp <- trim[[1]] %>%
  spread(key = ex, value = z)

temp <- rbind(colnames(temp), temp)

temp[1,1] <- NA

for (i in 1:length(trim)) {
  
  temp <- trim[[i]] %>%
    spread(key = ex, value = z)
  
  temp <- rbind(colnames(temp), temp)
  
  temp[1,1] <- NA
  
  write_csv(temp, paste0("../Data/corrected csvs 190311/", names[i], ".csv"), col_names = FALSE, append = FALSE)
  
}  

