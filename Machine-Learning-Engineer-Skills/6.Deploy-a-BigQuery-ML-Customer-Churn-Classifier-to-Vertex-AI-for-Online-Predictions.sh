PROJECT_ID=`gcloud projects list  --format='value(project_id)'| grep qwiklabs-gcp | head -1`
gcloud config set project $PROJECT_ID

curl -o default.sh https://raw.githubusercontent.com/user9-21/LearnToEarn-June-2022/main/files/default.sh
source default.sh

echo "${BOLD}${CYAN}$PROJECT_ID${RESET}"

gcloud services enable \
  compute.googleapis.com \
  iam.googleapis.com \
  iamcredentials.googleapis.com \
  monitoring.googleapis.com \
  logging.googleapis.com \
  notebooks.googleapis.com \
  aiplatform.googleapis.com \
  bigquery.googleapis.com

gcloud services enable notebooks.googleapis.com
#gcloud compute images describe-from-family tf2-ent-2-3-cpu --project deeplearning-platform-release

gcloud notebooks instances create instance-without-gpu \
  --vm-image-project=deeplearning-platform-release \
  --vm-image-family=tf2-ent-2-3-cpu \
  --machine-type=n1-standard-4 \
  --location=us-central1-a
  
gcloud notebooks instances list --location=us-central1-a

warning "https://console.cloud.google.com/vertex-ai/workbench/list/instances?project=$PROJECT_ID"
STATE=$(gcloud notebooks instances list --location=us-central1-a --format='value(STATE)')
echo $STATE
while [ $STATE = PROVISIONING ]; 
do echo "PROVISIONING" && sleep 2 && STATE=$(gcloud notebooks instances list --location=us-central1-a --format='value(STATE)') ; 
done

if [ $STATE = 'ACTIVE' ]
then
echo "${BOLD}${GREEN}$STATE ${RESET}"
fi

completed "Task 1"
JUPYTERLAB_URL=`gcloud notebooks instances describe instance-without-gpu --location=us-central1-a --format='value(proxyUri)'`
warning "Visit ${CYAN}https://$JUPYTERLAB_URL ${YELLOW}to open Jupyterlab"

warning "Run below command in Jupyterlab Terminal:
${MAGENTA}
	git clone https://github.com/GoogleCloudPlatform/training-data-analyst
	
	${YELLOW}
	Navigate to ${CYAN}training-data-analyst/quests/vertex-ai/vertex-bqml${YELLOW}
	and execute ${CYAN}lab_exercise.ipynb"


sleep 200
completed "Task 2"

completed "Lab"

remove_files