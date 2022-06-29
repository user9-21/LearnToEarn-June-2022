PROJECT_ID=`gcloud projects list  --format='value(project_id)'| grep qwiklabs-gcp | head -1`
gcloud config set project $PROJECT_ID

curl -o default.sh https://raw.githubusercontent.com/user9-21/LearnToEarn-June-2022/main/files/default.sh
source default.sh

echo "${BOLD}${CYAN}$PROJECT_ID${RESET}"

bq query --use_legacy_sql=false  \
'SELECT
  *
FROM
  `bigquery-public-data.new_york_citibike.citibike_stations`
LIMIT
  10'

completed "Task 1"

bq query --use_legacy_sql=false \
'SELECT
  ST_GeogPoint(longitude, latitude)  AS WKT,
  num_bikes_available
FROM
  `bigquery-public-data.new_york.citibike_stations`
WHERE num_bikes_available > 30'


warning "
Open https://bigquerygeoviz.appspot.com/

	- Under Query click Authorize
	- After authrnticatin, enter your Project ID in the Project ID field.
	- query = -- 
'SELECT
  ST_GeogPoint(longitude, latitude)  AS WKT,
  num_bikes_available
FROM
  `bigquery-public-data.new_york.citibike_stations`
WHERE num_bikes_available > 30'

	- Click the Run button.
	
NOTE: If you are unable to perform the task in an Incognito window then please perform this step in a normal window.
"

completed "Task 2"

completed "Lab"

remove_files