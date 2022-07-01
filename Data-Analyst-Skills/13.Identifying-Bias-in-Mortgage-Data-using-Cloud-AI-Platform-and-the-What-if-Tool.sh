PROJECT_ID=`gcloud projects list  --format='value(project_id)'| grep qwiklabs-gcp | head -1`
gcloud config set project $PROJECT_ID

curl -o default.sh https://raw.githubusercontent.com/user9-21/LearnToEarn-June-2022/main/files/default.sh
source default.sh

echo "${BOLD}${CYAN}$PROJECT_ID${RESET}"

gsutil mb gs://$PROJECT_ID
completed "Task 1"

gcloud services enable notebooks.googleapis.com
#gcloud compute images describe-from-family tf2-ent-2-6-cpu --project deeplearning-platform-release

gcloud notebooks instances create tensorflow-2-6 \
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

completed "Task 2"

JUPYTERLAB_URL=`gcloud notebooks instances describe tensorflow-2-6 --location=us-central1-a --format='value(proxyUri)'`
warning "Visit ${CYAN}https://$JUPYTERLAB_URL ${YELLOW}to open Jupyterlab"

echo '
git clone https://github.com/GoogleCloudPlatform/training-data-analyst
PROJECT=$(gcloud config get-value core/project)
BUCKET=$(gsutil ls)
cd training-data-analyst/quests/dei
echo $PROJECT
echo $BUCKET
sed -i s/YOUR_GCP_PROJECT/$PROJECT/g xgboost_caip_e2e.ipynb
sed -i s/your_storage_bucket/$PROJECT/g xgboost_caip_e2e.ipynb
sed -i "s/your_model_name/newModel/g" xgboost_caip_e2e.ipynb' > jupyter.sh
gsutil cp jupyter.sh gs://$PROJECT_ID/jupyter.sh

JUPYTERLAB_URL=`gcloud notebooks instances describe tensorflow-2-6 --location=us-central1-a --format='value(proxyUri)'`
warning "Visit ${CYAN}https://$JUPYTERLAB_URL ${YELLOW}to open Jupyterlab"

echo "${BOLD}${YELLOW}
Run below command in Jupyterlab Terminal:${MAGENTA}"

cat jupyter.sh

warning "			OR	
	${MAGENTA}				
	gsutil cp gs://$PROJECT_ID/jupyter.sh .
	source jupyter.sh"

echo "${RESET}${YELLOW}
	NAvigate to -${CYAN} training-data-analyst/quests/dei ${YELLOW}

	Copy PROJECT_ID = ${CYAN}$PROJECT_ID${YELLOW} & 
	Bucket = ${CYAN}`gsutil ls`${YELLOW}
	and paste in the ${CYAN}xgboost_caip_e2e.ipynb ${YELLOW}file 
	and run all command"

sleep 100
completed "Task 4"

completed "Lab"

remove_files 