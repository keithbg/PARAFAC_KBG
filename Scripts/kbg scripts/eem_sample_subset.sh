#!/bin/bash


## Script to move the files randomly chosen to be subset into their own folder
## Script to randomly choose files is: eem_pseudoreplicate_subset.R


cd "/Users/kbg/Documents/UC_Berkeley/EEA_DOC/Aqualog_EEMs/PARAFAC_KBG"

## Number of rows in file
nrow="$(wc -l < eem_sample_list_subset.txt)"

## Loop to move files into the subset folder
for f in $(seq 2 "$nrow")
  do
  file_to_copy="$(awk "FNR == "$f" {print \$1}" eem_sample_list_subset.txt)"

  cp -v EEMS_EX_3nm_corrected/"$file_to_copy" EEMS_EX_3nm_corrected_subset/
done
