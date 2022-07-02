PROJECT_ID=`gcloud projects list  --format='value(project_id)'| grep qwiklabs-gcp | head -1`
gcloud config set project $PROJECT_ID

curl -o default.sh https://raw.githubusercontent.com/user9-21/LearnToEarn-June-2022/main/files/default.sh
source default.sh

echo "${BOLD}${CYAN}$PROJECT_ID ${RESET}"

#gsutil mb gs://$PROJECT_ID

BUCKET=$PROJECT_ID
gsutil mb -p $PROJECT_ID \
    -c standard    \
    -l us-central1 \
    gs://${BUCKET}
	
gsutil -m cp -r gs://car_damage_lab_images/* gs://${BUCKET}
completed "Task 1"

gsutil cp gs://car_damage_lab_metadata/data.csv .
sed -i -e "s/car_damage_lab_images/${BUCKET}/g" ./data.csv
cat ./data.csv
gsutil cp ./data.csv gs://${BUCKET}

gcloud services enable aiplatform.googleapis.com

cat > request.json <<EOF
{
  "display_name": "damaged_car_parts",
  "metadata_schema_uri": "gs://google-cloud-aiplatform/schema/dataset/metadata/image_1.0.0.yaml"
}
EOF
LOCATION=us-central1
#curl -X POST -H "Authorization: Bearer "$(gcloud auth application-default print-access-token) -H "Content-Type: application/json; charset=utf-8" -d @request.json "https://$LOCATION-aiplatform.googleapis.com/v1/projects/$PROJECT_ID/locations/$LOCATION/datasets"

IMPORT_FILE_URI=gs://${BUCKET}/data.csv
cat > request.json <<EOF
{
  "import_configs": [
    {
      "gcs_source": {
        "uris": "$IMPORT_FILE_URI"
      },
     "import_schema_uri" : "gs://google-cloud-aiplatform/schema/dataset/ioformat/image_classification_single_label_io_format_1.0.0.yaml"
    }
  ]
}
EOF


warning "
	Visit - ${CYAN}https://console.cloud.google.com/vertex-ai/?project=$PROJECT_ID
	and Do manually as instructed on lab page"

sleep 200
completed "Lab"

remove_files