PROJECT_ID=`gcloud projects list  --format='value(project_id)'| grep qwiklabs-gcp | head -1`
gcloud config set project $PROJECT_ID

curl -o default.sh https://raw.githubusercontent.com/user9-21/LearnToEarn-June-2022/main/files/default.sh
source default.sh

echo "${BOLD}${CYAN}$PROJECT_ID ${RESET}"
cat > flight-simulation-script.sh <<EOF
cd  ~/data-science-on-gcp/04_streaming/simulate
export PROJECT_ID=$(gcloud info --format='value(config.project)')
python3 ./simulate.py --startTime '2015-02-01 00:00:00 UTC' --endTime '2015-03-03 00:00:00 UTC' --speedFactor=30 --project $PROJECT_ID 
EOF
git clone https://github.com/GoogleCloudPlatform/data-science-on-gcp/
cd ~/data-science-on-gcp/11_realtime
pip3 install google-cloud-aiplatform cloudml-hypertune pyfarmhash tensorflow==2.8.0
pip3 install kfp 'apache-beam[gcp]'
export PROJECT_ID=$(gcloud info --format='value(config.project)')
export BUCKET=$PROJECT_ID-ml
warning "${CYAN}https://console.cloud.google.com/dataflow/jobs?project=$PROJECT_ID"
python3 create_traindata.py --input bigquery --project $PROJECT_ID --bucket $BUCKET --region us-central1
python3 change_ch10_files.py
warning "${CYAN}https://console.cloud.google.com/vertex-ai/training/training-pipelines?project=$PROJECT_ID"
python3 train_on_vertexai.py --project $PROJECT_ID  --bucket $BUCKET --region us-central1 --develop --cpuonly
completed "Task 1"

bq query --nouse_legacy_sql --format=sparse \
    "SELECT EVENT_DATA FROM dsongcp.flights_simevents WHERE EVENT_TYPE = 'wheelsoff' AND EVENT_TIME BETWEEN '2015-03-01' AND '2015-03-02'" \
    | grep FL_DATE \
    > simevents_sample.json
python3 make_predictions.py --input local -p $PROJECT_ID
cat /tmp/predictions*

warning "Run this in another window:
${MAGENTA}
	cd  ~/data-science-on-gcp/04_streaming/simulate
	export PROJECT_ID=$(gcloud info --format='value(config.project)')
	python3 ./simulate.py --startTime '2015-02-01 00:00:00 UTC' --endTime '2015-03-03 00:00:00 UTC' --speedFactor=30 --project $PROJECT_ID"
	
warning "if score is given on task 2, Press CTRL+C once to exit the dataflow task (as it will be running continuously) to proceed with lab"
read -p "${BOLD}${YELLOW}Ran flight simulation script? [ y/n ] : ${RESET}" PROCEED

while [ $PROCEED != 'y' ];
do echo "Run above displayed commands in another terminal" && read -p "${BOLD}${YELLOW}Ran flight simulation script? [ y/n ] : ${RESET}" PROCEED;
done
warning "${CYAN}https://console.cloud.google.com/dataflow/jobs?project=$PROJECT_ID"
warning "Check, if score is given on task 2, Press CTRL+C once to exit the dataflow task( as it will be running continuously) to proceed with Task 3"
python3 make_predictions.py --input pubsub --output bigquery --project $PROJECT_ID --bucket $BUCKET --region us-central1
completed "Task 2"

bq query --use_legacy_sql=false \
'SELECT * FROM dsongcp.streaming_preds ORDER BY event_time DESC LIMIT 10'

completed "Task 3"

completed "Lab"

remove_files