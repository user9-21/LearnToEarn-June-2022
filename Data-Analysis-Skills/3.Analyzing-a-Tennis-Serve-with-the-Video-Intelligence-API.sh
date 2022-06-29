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

completed "Task 1"
echo '
sudo apt-get install -y ffmpeg
gsutil cp gs://spls/aiforsports/Sports_AI_Analysis.ipynb .
PROJECT=`gcloud config get-value core/project`
echo $PROJECT
sed -i s/YOUR_PROJECT_ID/$PROJECT/g Sports_AI_Analysis.ipynb' > jupyter.sh
gsutil cp jupyter.sh gs://$PROJECT_ID/jupyter.sh

echo "${BOLD}${YELLOW}
Run below command in Jupyterlab Terminal:${MAGENTA}"

cat jupyter.sh

warning "
				OR	
					
	gsutil cp gs://$PROJECT_ID/jupyter.sh .
	source jupyter.sh"
echo "${RESET}${YELLOW}
	NAvigate to - Sports_AI_Analysis.ipynb

	Replace YOUR_PROJECT_ID = ${CYAN}$PROJECT_ID${YELLOW} 
	in the Sports_AI_Analysis.ipynb.ipynb file 
	and run all command"
	
gcloud compute ssh --project $PROJECT_ID --quiet  --zone us-central1-a   tensorflow-2-6 -- -L 8080:localhost:8080

completed "Lab"

remove_files