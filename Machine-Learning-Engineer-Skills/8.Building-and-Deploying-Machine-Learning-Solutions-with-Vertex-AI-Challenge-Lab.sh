PROJECT_ID=`gcloud projects list  --format='value(project_id)'| grep qwiklabs-gcp | head -1`
gcloud config set project $PROJECT_ID

curl -o default.sh https://raw.githubusercontent.com/user9-21/LearnToEarn-June-2022/main/files/default.sh
source default.sh

echo "${BOLD}${CYAN}$PROJECT_ID${RESET}"

gsutil mb gs://$PROJECT_ID

gcloud services enable notebooks.googleapis.com
#gcloud compute images describe-from-family tf2-ent-2-6-cpu --project deeplearning-platform-release

gcloud notebooks instances create vertex-ai-challenge \
  --vm-image-project=deeplearning-platform-release \
  --vm-image-family=tf2-ent-2-6-cpu \
  --machine-type=n1-standard-4 \
  --location=us-central1-a
gcloud notebooks instances list --location=us-central1-a

warning "https://console.cloud.google.com/vertex-ai/workbench/list/instances?project=$PROJECT_ID"
sleep 10
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

JUPYTERLAB_URL=`gcloud notebooks instances describe vertex-ai-challenge --location=us-central1-a --format='value(proxyUri)'`
warning "Visit ${CYAN}https://$JUPYTERLAB_URL ${YELLOW}to open Jupyterlab"

echo '
curl -o default.sh https://raw.githubusercontent.com/user9-21/LearnToEarn-June-2022/main/files/default.sh
source default.sh
git clone https://github.com/GoogleCloudPlatform/training-data-analyst
cd training-data-analyst/quests/vertex-ai/vertex-challenge-lab

curl -o Vertex-AI-Challenge-Lab.ipynb  https://raw.githubusercontent.com/user9-21/LearnToEarn-June-2022/main/Machine-Learning-Engineer-Skills/Vertex-AI-Challenge-Lab.ipynb
pip install -U -r requirements.txt
PROJECT=$(gcloud config get-value core/project)
echo $PROJECT
sed -i s/YOUR_GCP_PROJECT/$PROJECT/g Vertex-AI-Challenge-Lab.ipynb

JUPYTERLAB_URL=`gcloud notebooks instances describe vertex-ai-challenge --location=us-central1-a --format="value(proxyUri)"`
warning "${MAGENTA}Visit ${CYAN}https://$JUPYTERLAB_URL/lab/tree/training-data-analyst/quests/vertex-ai/vertex-challenge-lab/Vertex-AI-Challenge-Lab.ipynb ${MAGENTA}to open Vertex-AI-Challenge-Lab.ipynb file"
echo "${YELLOW}	
Open ${CYAN}Vertex-AI-Challenge-Lab.ipynb ${YELLOW}file and run all command"
sleep 100' > jupyter.sh
gsutil cp jupyter.sh gs://$PROJECT_ID/jupyter.sh

JUPYTERLAB_URL=`gcloud notebooks instances describe vertex-ai-challenge --location=us-central1-a --format='value(proxyUri)'`
warning "Visit ${CYAN}https://$JUPYTERLAB_URL ${YELLOW}to open Jupyterlab"


warning "Run below command in Jupyterlab Terminal:
	${MAGENTA}				
	gsutil cp gs://$PROJECT_ID/jupyter.sh .
	source jupyter.sh"

sleep 2
echo "${YELLOW}
	NAvigate to -${CYAN} training-data-analyst/quests/vertex-ai/vertex-challenge-lab ${YELLOW}
	
	Open ${CYAN}Vertex-AI-Challenge-Lab.ipynb ${YELLOW}file 

	Replace YOUR_GCP_PROJECT with ${CYAN}$PROJECT_ID${YELLOW} 
	in the ${CYAN}Vertex-AI-Challenge-Lab.ipynb ${YELLOW}file 
	and run all command"

sleep 400

completed "Lab"

remove_files