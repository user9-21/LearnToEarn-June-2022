PROJECT_ID=`gcloud projects list  --format='value(project_id)'| grep qwiklabs-gcp | head -1`
gcloud config set project $PROJECT_ID

curl -o default.sh https://raw.githubusercontent.com/user9-21/GCRF/main/files/default.sh
source default.sh
echo "${BOLD}${CYAN}$PROJECT_ID${RESET}"

git clone https://github.com/GoogleCloudPlatform/data-science-on-gcp/
cd ~/data-science-on-gcp/04_streaming/transform
ls
./install_packages.sh
./df05.py
head -3 all_events-00000*
cd ~/data-science-on-gcp/04_streaming/transform
export PROJECT_ID=$(gcloud info --format='value(config.project)')
export BUCKET=${PROJECT_ID}-ml
echo "${BOLD}${MAGENTA}
$PROJECT_ID
$BUCKET
${RESET}"

./stage_airports_file.sh $BUCKET
./df06.py --project $PROJECT_ID --bucket $BUCKET
completed "Task 1"

bq query --use_legacy_sql=false \
'SELECT
  ORIGIN,
  DEP_TIME,
  DEST,
  ARR_TIME,
  ARR_DELAY,
  EVENT_TIME,
  EVENT_TYPE
FROM
  dsongcp.flights_simevents
WHERE
  (DEP_DELAY > 15 and ORIGIN = "SEA") or
  (ARR_DELAY > 15 and DEST = "SEA")
ORDER BY EVENT_TIME ASC
LIMIT
  5'
./df07.py -p $PROJECT_ID -b $BUCKET -r us-central1
completed "Task 2"

bq query --use_legacy_sql=false \
'SELECT
  ORIGIN,
  DEP_TIME,
  DEST,
  ARR_TIME,
  ARR_DELAY,
  EVENT_TIME,
  EVENT_TYPE
FROM
  dsongcp.flights_simevents
WHERE
  (DEP_DELAY > 15 and ORIGIN = "SEA") or
  (ARR_DELAY > 15 and DEST = "SEA")
ORDER BY EVENT_TIME ASC
LIMIT
  5'
completed "Task 3"

completed "Lab"

remove_files