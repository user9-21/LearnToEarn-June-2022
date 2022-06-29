PROJECT_ID=`gcloud projects list  --format='value(project_id)'| grep qwiklabs-gcp | head -1`
gcloud config set project $PROJECT_ID

curl -o default.sh https://raw.githubusercontent.com/user9-21/LearnToEarn-June-2022/main/files/default.sh
source default.sh

echo "${BOLD}${CYAN}$PROJECT_ID ${RESET}"

bq query --use_legacy_sql=false  \
'SELECT
 date,
 label,
 (team1.score + team2.score) AS totalGoals
FROM
 `soccer.matches` Matches
LEFT JOIN
 `soccer.competitions` Competitions ON
   Matches.competitionId = Competitions.wyId
WHERE
 status = "Played" AND
 Competitions.name = "Spanish first division"
ORDER BY
 totalGoals DESC, date DESC'
completed "Task 1"

bq query --use_legacy_sql=false  \
'SELECT
 playerId,
 (Players.firstName || " " || Players.lastName) AS playerName,
 COUNT(id) AS numPasses
FROM
 `soccer.events` Events
LEFT JOIN
 `soccer.players` Players ON
   Events.playerId = Players.wyId
WHERE
 eventName = "Pass"
GROUP BY
 playerId, playerName
ORDER BY
 numPasses DESC
LIMIT 10'
completed "Task 2"

bq query --use_legacy_sql=false  \
'SELECT
 playerId,
 (Players.firstName || " " || Players.lastName) AS playerName,
 COUNT(id) AS numPKAtt,
 SUM(IF(101 IN UNNEST(tags.id), 1, 0)) AS numPKGoals,
 SAFE_DIVIDE(
   SUM(IF(101 IN UNNEST(tags.id), 1, 0)),
   COUNT(id)
   ) AS PKSuccessRate
FROM
 `soccer.events` Events
LEFT JOIN
 `soccer.players` Players ON
   Events.playerId = Players.wyId
WHERE
 eventName = "Free Kick" AND
 subEventName = "Penalty"
GROUP BY
 playerId, playerName
HAVING
 numPkAtt >= 5
ORDER BY
 PKSuccessRate DESC, numPKAtt DESC'
completed "Task 3"

completed "Lab"

remove_files