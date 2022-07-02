PROJECT_ID=`gcloud projects list  --format='value(project_id)'| grep qwiklabs-gcp | head -1`
gcloud config set project $PROJECT_ID

curl -o default.sh https://raw.githubusercontent.com/user9-21/LearnToEarn-June-2022/main/files/default.sh
source default.sh

echo "${BOLD}${CYAN}$PROJECT_ID ${RESET}"

gsutil mb gs://$PROJECT_ID
gcloud services enable notebooks.googleapis.com
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


echo '
curl -o default.sh https://raw.githubusercontent.com/user9-21/LearnToEarn-June-2022/main/files/default.sh
source default.sh
pip3 install --user google-cloud-aiplatform==1.0.0 --upgrade
pip3 install --user kfp google-cloud-pipeline-components==0.1.1 --upgrade
curl -o Vertex-Pipelines-Qwik-Start.ipynb https://raw.githubusercontent.com/user9-21/LearnToEarn-June-2022/main/Machine-Learning-Engineer-Skills/Vertex-Pipelines-Qwik-Start.ipynb
echo "	
Open ${CYAN}Vertex-Pipelines-Qwik-Start.ipynb ${YELLOW}file and run all command"
sleep 60' > jupyter.sh
gsutil cp jupyter.sh gs://$PROJECT_ID/jupyter.sh

JUPYTERLAB_URL=`gcloud notebooks instances describe ai-notebook --location=us-central1-a --format='value(proxyUri)'`
warning "Visit ${CYAN}https://$JUPYTERLAB_URL ${YELLOW}to open Jupyterlab"


warning "Run below command in Jupyterlab Terminal:
	${MAGENTA}				
	gsutil cp gs://$PROJECT_ID/jupyter.sh .
	source jupyter.sh"

echo "
	Open ${CYAN}Vertex-Pipelines-Qwik-Start.ipynb ${YELLOW}file and run all command"

sleep 400

completed "Lab"

remove_files