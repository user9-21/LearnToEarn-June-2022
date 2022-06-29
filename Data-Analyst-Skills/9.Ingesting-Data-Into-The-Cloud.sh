PROJECT_ID=`gcloud projects list  --format='value(project_id)'| grep qwiklabs-gcp | head -1`
gcloud config set project $PROJECT_ID

curl -o default.sh https://raw.githubusercontent.com/user9-21/GCRF/main/files/default.sh
source default.sh
echo "${BOLD}${CYAN}$PROJECT_ID${RESET}"

git clone https://github.com/GoogleCloudPlatform/data-science-on-gcp/
cd data-science-on-gcp
mkdir data
cd data
curl https://www.bts.dot.gov/sites/bts.dot.gov/files/docs/legacy/additional-attachment-files/ONTIME.TD.201501.REL02.04APR2015.zip --output data.zip
unzip data.zip
head ontime.td.201501.asc
cat ../02_ingest/ingest_from_crsbucket.sh
gsutil mb -l us-central1 gs://${PROJECT_ID}-ml
bash ../02_ingest/ingest_from_crsbucket.sh ${PROJECT_ID}-ml
completed "Task 1"
completed "Task 2"

cat ../02_ingest/bqload.sh
bash ../02_ingest/bqload.sh ${PROJECT_ID}-ml 2015
completed "Task 3"

completed "Lab"

remove_files