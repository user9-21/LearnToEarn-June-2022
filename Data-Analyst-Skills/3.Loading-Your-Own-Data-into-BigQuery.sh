PROJECT_ID=`gcloud projects list  --format='value(project_id)'| grep qwiklabs-gcp | head -1`
gcloud config set project $PROJECT_ID

curl -o default.sh https://raw.githubusercontent.com/user9-21/LearnToEarn-June-2022/main/files/default.sh
source default.sh

echo "${BOLD}${CYAN}$PROJECT_ID ${RESET}"

bq mk nyctaxi
completed "Task 1"

#wget --output-file 2018trips.csv https://storage.googleapis.com/cloud-training/OCBL013/nyc_tlc_yellow_trips_2018_subset_1.csv
#bq --location=LOCATION load --source_format=CSV $PROJECT_ID:nyctaxi.2018trips 2018trips.csv
#gsutil mb gs://$PROJECT_ID
#gsutil cp 2018trips.csv gs://$PROJECT_ID/2018trips.csv
#bq --location=us load --autodetect --source_format=CSV nyctaxi.2018trips gs://$PROJECT_ID/2018trips.csv
#bq --location=us load --autodetect --source_format=CSV nyctaxi.2018trips 2018trips.csv 2.json

curl -o 2018trips.csv https://storage.googleapis.com/cloud-training/OCBL013/nyc_tlc_yellow_trips_2018_subset_1.csv

bq --location=us load --autodetect --source_format=CSV nyctaxi.2018trips 2018trips.csv

bq show --format=prettyjson nyctaxi.2018trips

bq query  \
'#standardSQL
SELECT
  *
FROM
  nyctaxi.2018trips
ORDER BY
  fare_amount DESC
LIMIT  5'
completed "Task 2"

bq load \
--source_format=CSV \
--autodetect \
--noreplace  \
nyctaxi.2018trips \
gs://cloud-training/OCBL013/nyc_tlc_yellow_trips_2018_subset_2.csv

completed "Task 3"
bq query  \
'#standardSQL
CREATE TABLE
  nyctaxi.january_trips AS
SELECT
  *
FROM
  nyctaxi.2018trips
WHERE
  EXTRACT(Month
  FROM
    pickup_datetime)=1;'

bq query  \
'#standardSQL
SELECT
  *
FROM
  nyctaxi.january_trips
ORDER BY
  trip_distance DESC
LIMIT
  1'

completed "Task 4"

completed "Lab"

remove_files 