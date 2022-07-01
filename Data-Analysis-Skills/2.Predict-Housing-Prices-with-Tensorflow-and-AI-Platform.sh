PROJECT_ID=`gcloud projects list  --format='value(project_id)'| grep qwiklabs-gcp | head -1`
gcloud config set project $PROJECT_ID

curl -o default.sh https://raw.githubusercontent.com/user9-21/LearnToEarn-June-2022/main/files/default.sh
source default.sh

echo "${BOLD}${CYAN}$PROJECT_ID ${RESET}"

gsutil mb -l us-central1 gs://$PROJECT_ID
completed "Task 1"

gcloud services enable notebooks.googleapis.com
#gcloud compute images describe-from-family tf-ent-1-15-cpu --project deeplearning-platform-release

gcloud notebooks instances create tensorflow-1-15 \
  --vm-image-project=deeplearning-platform-release \
  --vm-image-family=tf-ent-1-15-cpu \
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

echo '
git clone https://github.com/GoogleCloudPlatform/training-data-analyst
PROJECT=`gcloud config get-value core/project`
BUCKET=`gsutil ls`
cd training-data-analyst/blogs/housing_prices
echo $PROJECT
echo $BUCKET
sed -i s/PROJECT_ID/$PROJECT/g cloud-ml-housing-prices.ipynb
sed -i s/BUCKET_NAME/$PROJECT/g cloud-ml-housing-prices.ipynb' > jupyter.sh
gsutil cp jupyter.sh gs://$PROJECT_ID/jupyter.sh

JUPYTERLAB_URL=`gcloud notebooks instances describe tensorflow-1-15 --location=us-central1-a --format='value(proxyUri)'`
warning "Visit ${CYAN}https://$JUPYTERLAB_URL ${YELLOW}to open Jupyterlab"


echo "${BOLD}${YELLOW}Run below command in Jupyterlab Terminal:${MAGENTA}"

cat jupyter.sh

warning "				OR	
	${MAGENTA}				
	gsutil cp gs://$PROJECT_ID/jupyter.sh jupyter.sh
	source jupyter.sh"

echo "${RESET}${YELLOW}
	NAvigate to -${CYAN} training-data-analyst/blogs/housing_prices ${YELLOW}

	Copy PROJECT = ${CYAN}$PROJECT_ID${YELLOW} & 
	GCS_Bucket = ${CYAN}`gsutil ls`${YELLOW}
	and paste in the cloud-ml-housing-prices.ipynb file 
	and run all command"
	
sleep 60
completed "Task 2"
sleep 300

gcloud ai-platform jobs list --sort-by=STATUS

gcloud ai-platform jobs list --sort-by=STATUS --format="value(STATUS)"

STATUS=`gcloud ai-platform jobs list --sort-by=STATUS --format="value(STATUS)" | head -1`
echo $STATUS

while [ $STATUS != 'SUCCEEDED' ]; 
do echo "wait" && sleep 10 && STATUS=`gcloud ai-platform jobs list --sort-by=STATUS --format="value(STATUS)" | head -1` ; 
done

gcloud ai-platform jobs list --sort-by=STATUS

if [ $STATUS = 'SUCCEEDED' ]
then
STATUS=`gcloud ai-platform jobs list --sort-by=STATUS --format="value(STATUS)" | tail -1`
fi

while [ $STATUS != 'SUCCEEDED' ]; 
do echo "wait" && sleep 10 && STATUS=`gcloud ai-platform jobs list --sort-by=STATUS --format="value(STATUS)" | tail -1` ; 
done

gcloud ai-platform jobs list --sort-by=STATUS

completed "Lab"

remove_files