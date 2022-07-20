#!/bin/bash

BILLING_ACC_ID=$1
max_results=100000
ftdt=`date +"%Y-%m-%d"`
yesterdt=$(date  --date="yesterday" +"%Y-%m-%d")

OUTPUT_FILE=./get_buckets_size-info_all.csv
PROJECT_NAME="GCPADMIN"
DATASET_NAME="GCSMetaInfo"
if [ -f "$OUTPUT_FILE" ]; then
    echo "$OUTPUT_FILE exists."
   rm -f  $OUTPUT_FILE
fi

printf "\nProcessing Started------------\n" 
for project in  $(gcloud beta billing projects list  --billing-account=$BILLING_ACC_ID --format="value(projectId)")
#for project in  ${projectsArray[@]};
    do
    # Get the Projects sh get_buckets_info.sh "XXXX-XXXXX-XXXXX"
    #printf "\n\nProjectId:  $project \n" 
    val=`gsutil -o GSUtil:default_project_id=$project du -sc |sed '$d'|awk '{print $2 "," $1}'`
    for i in $val
    do
    echo "$ftdt,$project,$i" >> $OUTPUT_FILE
    done   
    
done
if [ -f "$OUTPUT_FILE" ]; then
    echo "$FILE exists."
    bq load \
    --source_format=CSV \
    $PROJECT_NAME:$DATASET_NAME.all_projects_buckets_size_info \
    $OUTPUT_FILE \
    load_date:date,project_name:string,bucket_name:string,bucket_size:INTEGER
fi


printf "Processing Complete------------\n" 