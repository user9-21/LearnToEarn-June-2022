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

STATE=$(gcloud notebooks instances list --location=us-central1-a --format='value(STATE)')
echo $STATE
sleep 10
while [ $STATE = PROVISIONING ]; 
do echo "PROVISIONING" && sleep 2 && STATE=$(gcloud notebooks instances list --location=us-central1-a --format='value(STATE)') ; 
done

if [ $STATE = 'ACTIVE' ]
then
echo "${BOLD}${GREEN}$STATE${RESET}" 
warning "preview on port 80 to open jupyterlab" 
fi

PROJECT=0
BUCKET=0
completed "Task 2"
echo "${BOLD}${YELLOW}Run below command in Jupyterlab Terminal:${MAGENTA}"

echo '
git clone https://github.com/GoogleCloudPlatform/training-data-analyst
PROJECT=$(gcloud config get-value core/project)
BUCKET=$(gsutil ls)
cd training-data-analyst/quests/dei
echo $PROJECT
echo $BUCKET
sed -i s/YOUR_GCP_PROJECT/$PROJECT/g xgboost_caip_e2e.ipynb
sed -i s/your_storage_bucket/$PROJECT/g xgboost_caip_e2e.ipynb
sed -i "s/your_model_name/newModel/g" xgboost_caip_e2e.ipynb'

echo "${RESET}${YELLOW}
	NAvigate to - training-data-analyst/quests/dei

	Copy PROJECT_ID = ${CYAN}$PROJECT_ID${YELLOW} & 
	Bucket = ${CYAN}`gsutil ls`${YELLOW}
	and paste in the xgboost_caip_e2e.ipynb file 
	and run all command"

gcloud compute ssh --project $PROJECT_ID --quiet  --zone us-central1-a   tensorflow-2-6 -- -L 8080:localhost:8080

completed "Task 4"

completed "Lab"

remove_files 