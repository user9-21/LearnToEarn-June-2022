PROJECT_ID=`gcloud projects list  --format='value(project_id)'| grep qwiklabs-gcp | head -1`
gcloud config set project $PROJECT_ID

curl -o default.sh https://raw.githubusercontent.com/user9-21/LearnToEarn-June-2022/main/files/default.sh
source default.sh

echo "${BOLD}${CYAN}$PROJECT_ID ${RESET}"

gsutil mb -l us-central1 gs://$PROJECT_ID

gcloud services enable notebooks.googleapis.com
#gcloud compute images describe-from-family tf-ent-2-6-cpu --project deeplearning-platform-release

gcloud notebooks instances create tensorflow-2-6 \
  --vm-image-project=deeplearning-platform-release \
  --vm-image-family=tf-ent-2-6-cpu \
  --machine-type=n1-standard-2 \
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

echo '
sudo apt-get install -y ffmpeg
gsutil cp gs://spls/aiforsports/Sports_AI_Analysis.ipynb .
PROJECT=`gcloud config get-value core/project`
echo $PROJECT
sed -i s/YOUR_PROJECT_ID/$PROJECT/g Sports_AI_Analysis.ipynb' > jupyter.sh
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
	Open - Sports_AI_Analysis.ipynb

	Replace YOUR_PROJECT_ID = ${CYAN}$PROJECT_ID${YELLOW} 
	in the Sports_AI_Analysis.ipynb.ipynb file 
	and run all command"
sleep 60

completed "Lab"

remove_files