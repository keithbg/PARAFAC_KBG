#!/bin/bash


## Script to rename aqualog eem files
## Run from /Users/kbg/Documents/UC_Berkeley/EEA_DOC/Aqualog_EEMs/PARAFAC_KBG folder

## Change linux defaults to not treat spaces in filenames as line breaks
## https://unix.stackexchange.com/questions/9496/looping-through-files-with-spaces-in-the-names
OIFS="$IFS"
IFS=$'\n'

for sample in $(ls -1)
  do
  ## Get number of rows in each sample_names file
  cd "$sample"/
  nrow="$(wc -l < sample_names.txt)"

  ## Loop through each unique sample name
  for i in $(seq 1 "$nrow")
    do
    old_name="$(awk "FNR == "$i" {print \$1}" sample_names.txt)"
    new_name="$(awk "FNR == "$i" {print \$2}" sample_names.txt)"

    cd data_export/
    ## For each old_name replace it with the new_name
    for filename in $(ls -1 "$old_name"*)
      do
      mv "$filename" "$(echo $filename | sed "s/"$old_name"/"$new_name"/")"
    done
    cd ../
  done
  cd ../
done

## Return linux to default line breaks
IFS="$OIFS"
