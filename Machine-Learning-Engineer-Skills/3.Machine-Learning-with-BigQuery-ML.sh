PROJECT_ID=`gcloud projects list  --format='value(project_id)'| grep qwiklabs-gcp | head -1`
gcloud config set project $PROJECT_ID

curl -o default.sh https://raw.githubusercontent.com/user9-21/LearnToEarn-June-2022/main/files/default.sh
source default.sh

echo "${BOLD}${CYAN}$PROJECT_ID${RESET}"

gsutil mb gs://$PROJECT_ID

gcloud services enable notebooks.googleapis.com
#gcloud compute images describe-from-family tf2-ent-2-6-cpu --project deeplearning-platform-release

gcloud notebooks instances create bqml-notebook \
  --vm-image-project=deeplearning-platform-release \
  --vm-image-family=tf2-ent-2-6-cpu \
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
echo "${BOLD}${GREEN}$STATE${RESET}" 
fi

completed "Task 1"

JUPYTERLAB_URL=`gcloud notebooks instances describe bqml-notebook --location=us-central1-a --format='value(proxyUri)'`
warning "Visit ${CYAN}https://$JUPYTERLAB_URL ${YELLOW}to open Jupyterlab"

echo '
curl -o default.sh https://raw.githubusercontent.com/user9-21/LearnToEarn-June-2022/main/files/default.sh
source default.sh
curl -o Machine-Learning-with-BigQuery-ML.ipynb  https://raw.githubusercontent.com/user9-21/LearnToEarn-June-2022/main/Machine-Learning-Engineer-Skills/Machine-Learning-with-BigQuery-ML.ipynb
echo "	
Open ${CYAN}Machine-Learning-with-BigQuery-ML.ipynb ${YELLOW}file and run all command"
sleep 60' > jupyter.sh
gsutil cp jupyter.sh gs://$PROJECT_ID/jupyter.sh

JUPYTERLAB_URL=`gcloud notebooks instances describe bqml-notebook --location=us-central1-a --format='value(proxyUri)'`
warning "Visit ${CYAN}https://$JUPYTERLAB_URL ${YELLOW}to open Jupyterlab"


warning "Run below command in Jupyterlab Terminal:
	${MAGENTA}				
	gsutil cp gs://$PROJECT_ID/jupyter.sh .
	source jupyter.sh"

echo "
	Open ${CYAN}Machine-Learning-with-BigQuery-ML.ipynb ${YELLOW}file and run all command"

sleep 400

completed "Lab"

remove_files