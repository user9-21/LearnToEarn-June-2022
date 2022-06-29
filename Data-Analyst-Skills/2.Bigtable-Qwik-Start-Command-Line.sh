PROJECT_ID=`gcloud projects list  --format='value(project_id)'| grep qwiklabs-gcp | head -1`
gcloud config set project $PROJECT_ID

curl -o default.sh https://raw.githubusercontent.com/user9-21/GCRF/main/files/default.sh
source default.sh
echo "${CYAN}$PROJECT_ID"

gcloud iam service-accounts keys create key.json --iam-account=$PROJECT_ID@$PROJECT_ID.iam.gserviceaccount.com
			
INSTANCE_ID=quickstart-instance
DISPLAY_NAME=quickstart-instance
CLUSTER_ID=quickstart-instance-c1
CLUSTER_ZONE=us-east1-c
CLUSTER_NUM_NODES=1
CLUSTER_STORAGE_TYPE=SSD
	
echo project = `gcloud config get-value project` > ~/.cbtrc
echo instance = quickstart-instance >> ~/.cbtrc
echo creds = key.json >> ~/.cbtrc

cbt createinstance $INSTANCE_ID $DISPLAY_NAME $CLUSTER_ID $CLUSTER_ZONE \
    $CLUSTER_NUM_NODES $CLUSTER_STORAGE_TYPE


completed "Task 1"

cbt createtable my-table
cbt ls
cbt createfamily my-table cf1
cbt ls my-table

completed "Task 2"

cbt set my-table r1 cf1:c1=test-value
cbt read my-table
cbt deletetable my-table

completed "Task 3"

completed "Lab"

remove_files 