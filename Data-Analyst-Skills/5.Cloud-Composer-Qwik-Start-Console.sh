PROJECT_ID=`gcloud projects list  --format='value(project_id)'| grep qwiklabs-gcp | head -1`
gcloud config set project $PROJECT_ID

curl -o default.sh https://raw.githubusercontent.com/user9-21/LearnToEarn-June-2022/main/files/default.sh
source default.sh

echo "${BOLD}${CYAN}$PROJECT_ID${RESET}"

gsutil mb gs://$PROJECT_ID

completed "Task 1"

gcloud composer environments create highcpu --machine-type n1-highcpu-4 --image-version composer-1.19.0-airflow-2.2.5 --python-version 3 --location us-central1 --zone us-central1-a 
gcloud composer environments describe highcpu --location us-central1 --format="value(state)"
completed "Task 2"


DAGS_FOLDER_PATH=`gcloud composer environments describe highcpu --location us-central1 --format="value(config.dagGcsPrefix)"`
gsutil cp gs://cloud-training/datawarehousing/lab_assets/hadoop_tutorial.py $DAGS_FOLDER_PATH
completed "Task 3"

completed "Lab"

remove_files