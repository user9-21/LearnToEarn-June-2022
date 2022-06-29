PROJECT_ID=`gcloud projects list  --format='value(project_id)'| grep qwiklabs-gcp | head -1`
gcloud config set project $PROJECT_ID

curl -o default.sh https://raw.githubusercontent.com/user9-21/LearnToEarn-June-2022/main/files/default.sh
source default.sh

echo "${BOLD}${CYAN}$PROJECT_ID ${RESET}"

gcloud spanner instances create cloudspanner-leaderboard --config=regional-us-central1 --description="cloudspanner-leaderboard" --nodes=1
	
completed "Task 1"

git clone https://github.com/GoogleCloudPlatform/dotnet-docs-samples.git
cd dotnet-docs-samples/applications/
mkdir demolab && cd $_
dotnet new console -n Leaderboard
cd Leaderboard
dotnet run
cd ~/dotnet-docs-samples/applications/leaderboard/step4
dotnet run
dotnet run create
dotnet run create $PROJECT_ID cloudspanner-leaderboard leaderboard
completed "Task 2"

cd ~/dotnet-docs-samples/applications/leaderboard/step5
dotnet run
dotnet run insert
dotnet run insert $PROJECT_ID cloudspanner-leaderboard leaderboard players
dotnet run insert $PROJECT_ID cloudspanner-leaderboard leaderboard scores

completed "Task 3"

completed "Lab"

remove_files