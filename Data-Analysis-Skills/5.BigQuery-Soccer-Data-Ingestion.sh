PROJECT_ID=`gcloud projects list  --format='value(project_id)'| grep qwiklabs-gcp | head -1`
gcloud config set project $PROJECT_ID

curl -o default.sh https://raw.githubusercontent.com/user9-21/LearnToEarn-June-2022/main/files/default.sh
source default.sh

echo "${BOLD}${CYAN}$PROJECT_ID ${RESET}"

bq --location=us mk soccer
completed "Task 1"

bq --location=us load --autodetect --source_format=NEWLINE_DELIMITED_JSON  soccer.competitions gs://spls/bq-soccer-analytics/competitions.json
bq --location=us load --autodetect --source_format=NEWLINE_DELIMITED_JSON  soccer.matches gs://spls/bq-soccer-analytics/matches.json
bq --location=us load --autodetect --source_format=NEWLINE_DELIMITED_JSON  soccer.teams gs://spls/bq-soccer-analytics/teams.json
bq --location=us load --autodetect --source_format=NEWLINE_DELIMITED_JSON  soccer.players gs://spls/bq-soccer-analytics/players.json
bq --location=us load --autodetect --source_format=NEWLINE_DELIMITED_JSON  soccer.events gs://spls/bq-soccer-analytics/events.json
completed "Task 2"

bq --location=us load --autodetect --source_format=CSV  soccer.tags2name gs://spls/bq-soccer-analytics/tags2name.csv
completed "Task 3"

bq query --use_legacy_sql=false \
'SELECT
  (firstName || " " || lastName) AS player,
  birthArea.name AS birthArea,
  height
FROM
  `soccer.players`
WHERE
  role.name = "Defender"
ORDER BY
  height DESC
LIMIT 5'
completed "Task 4"

#bq load --source_format=CSV --autodetect --noreplace  nyctaxi.2018trips gs://cloud-training/OCBL013/nyc_tlc_yellow_trips_2018_subset_2.csv

bq query --use_legacy_sql=false \
'SELECT
  eventId,
  eventName,
  COUNT(id) AS numEvents
FROM
  `soccer.events`
GROUP BY
  eventId, eventName
ORDER BY
  numEvents DESC'

completed "Task 5"

completed "Lab"

remove_files 