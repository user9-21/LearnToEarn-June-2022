PROJECT_ID=`gcloud projects list  --format="value(project_id)"| grep qwiklabs-gcp | head -1`
gcloud config set project $PROJECT_ID

curl -o default.sh https://raw.githubusercontent.com/user9-21/LearnToEarn-June-2022/main/files/default.sh
source default.sh

echo "${BOLD}${CYAN}$PROJECT_ID ${RESET}"

echo " "
read -p "${BOLD}${YELLOW}Events Table Name : ${RESET}" EVENTS_NAME
read -p "${BOLD}${YELLOW}  Tags Table Name : ${RESET}" TAGS_NAME
read -p "${BOLD}${YELLOW}       Model Name : ${RESET}" MODEL_NAME
echo "${BOLD} "
echo "${YELLOW}Events Table Name :${CYAN} $EVENTS_NAME  "
echo "${YELLOW}  Tags Table Name :${CYAN} $TAGS_NAME  "
echo "${YELLOW}       Model Name :${CYAN} $MODEL_NAME  "
echo " "

read -p "${BOLD}${YELLOW}Verify all details are correct? [ y/n ] : ${RESET}" VERIFY_DETAILS

while [ $VERIFY_DETAILS != 'y' ];
do echo " " && 
read -p "${BOLD}${YELLOW}Events Table Name : ${RESET}" EVENTS_NAME && 
read -p "${BOLD}${YELLOW}  Tags Table Name : ${RESET}" TAGS_NAME && 
read -p "${BOLD}${YELLOW}       Model Name : ${RESET}" MODEL_NAME && 
echo "${BOLD} " && 
echo "${YELLOW}Events Table Name :${CYAN} $EVENTS_NAME  " && 
echo "${YELLOW}  Tags Table Name :${CYAN} $TAGS_NAME  " && 
echo "${YELLOW}       Model Name :${CYAN} $MODEL_NAME  " && 
echo " " && 
read -p "${BOLD}${YELLOW}Verify all details are correct? [ y/n ] : ${RESET}" VERIFY_DETAILS;
done

CODE=`echo $MODEL_NAME | sed "s/[^0-9]//g"`
CODE2=`echo $EVENTS_NAME | sed "s/[^0-9]//g"`
echo $CODE
echo $CODE2
DISTANCE_FUNCTION=soccer.GetShotDistanceToGoal$CODE
ANGLE_FUNCTION=soccer.GetShotAngleToGoal$CODE

if [ $CODE != $CODE2 ]
then
warning "${RED}Value Conflicting"
fi

warning "${CYAN}https://console.cloud.google.com/bigquery?project=$PROJECT_ID"

warning "${RED}You will find below details in between the instructions particularly in Task 3 & 4"
read -p "${BOLD}${YELLOW}Midpoints1 of the goal mouth : ${RESET}" MIDPOINT1
read -p "${BOLD}${YELLOW}Midpoints2 of the goal mouth : ${RESET}" MIDPOINT2
read -p "${BOLD}${YELLOW}Dimensions1  of a soccer field : ${RESET}" DIMENSIONS1
read -p "${BOLD}${YELLOW}Dimensions2  of a soccer field : ${RESET}" DIMENSIONS2
echo "${BOLD} "
HALF_DIMENSIONS2=`perl -e "print $DIMENSIONS2/2"`
echo "${YELLOW}Midpoints1 of the goal mouth   :${CYAN} $MIDPOINT1  "
echo "${YELLOW}Midpoints2 of the goal mouth   :${CYAN} $MIDPOINT2  "
echo "${YELLOW}Dimensions1  of a soccer field :${CYAN} $DIMENSIONS1  "
echo "${YELLOW}Dimensions2  of a soccer field :${CYAN} $DIMENSIONS2  "
echo "${YELLOW}Distance Function :${CYAN} $DISTANCE_FUNCTION  "
echo "${YELLOW}   Angle Function :${CYAN} $ANGLE_FUNCTION  "
echo "${YELLOW}Half of Dimensions2:${CYAN} $HALF_DIMENSIONS2  "

read -p "${BOLD}${YELLOW}Confirm all inside-details are correct? [ y/n ] : ${RESET}" CONFIRM_DETAILS

while [ $CONFIRM_DETAILS != 'y' ];
do warning "${RED}You will find below details in between the instructions particularly in Task 3 & 4" && 
echo " " && 
read -p "${BOLD}${YELLOW}Midpoints1 of the goal mouth : ${RESET}" MIDPOINT1 && 
read -p "${BOLD}${YELLOW}Midpoints2 of the goal mouth : ${RESET}" MIDPOINT2 && 
read -p "${BOLD}${YELLOW}Dimensions1  of a soccer field : ${RESET}" DIMENSIONS1 && 
read -p "${BOLD}${YELLOW}Dimensions2  of a soccer field : ${RESET}" DIMENSIONS2 && 
echo "${BOLD} " && 
HALF_DIMENSIONS2=`perl -e "print $DIMENSIONS2/2"` && 
echo "${YELLOW}Midpoints1 of the goal mouth   :${CYAN} $MIDPOINT1  " && 
echo "${YELLOW}Midpoints2 of the goal mouth   :${CYAN} $MIDPOINT2  " && 
echo "${YELLOW}Dimensions1  of a soccer field :${CYAN} $DIMENSIONS1  " && 
echo "${YELLOW}Dimensions2  of a soccer field :${CYAN} $DIMENSIONS2  " && 
echo "${YELLOW}Distance Function :${CYAN} $DISTANCE_FUNCTION  " && 
echo "${YELLOW}   Angle Function :${CYAN} $ANGLE_FUNCTION  " && 
echo "${YELLOW}Half of Dimensions2:${CYAN} $HALF_DIMENSIONS2  " && 
read -p "${BOLD}${YELLOW}Confirm all inside-details are correct? [ y/n ] : ${RESET}" CONFIRM_DETAILS
done

bq --location=us load --autodetect --source_format=NEWLINE_DELIMITED_JSON  soccer.$EVENTS_NAME gs://spls/bq-soccer-analytics/events.json
bq --location=us load --autodetect --source_format=CSV  soccer.$TAGS_NAME gs://spls/bq-soccer-analytics/tags2name.csv
completed "Task 1"

sed -i "s/<EVENT_NAME>/$EVENTS_NAME/g" script.sh
sed -i "s/<MODEL_NAME>/$MODEL_NAME/g" script.sh
sed -i "s/<DISTANCE_FUNCTION>/$DISTANCE_FUNCTION/g" script.sh
sed -i "s/<ANGLE_FUNCTION>/$ANGLE_FUNCTION/g" script.sh
sed -i "s/<MIDPOINT1>/$MIDPOINT1/g" script.sh
sed -i "s/<MIDPOINT2>/$MIDPOINT2/g" script.sh
sed -i "s/<DIMENSIONS1>/$DIMENSIONS1/g" script.sh
sed -i "s/<DIMENSIONS2>/$DIMENSIONS2/g" script.sh
sed -i "s/<HALF_DIMENSIONS2>/$HALF_DIMENSIONS2/g" script.sh

cp script.sh bq.sh
sed -i '1,4d;8,103d' bq.sh

chmod +x bq.sh
./bq.sh






bq query --use_legacy_sql=false \
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
`soccer.<EVENT_NAME>` Events
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
PKSuccessRate DESC, numPKAtt DESC
'
completed "Task 2"


#bq query --use_legacy_sql=false ''

bq query --use_legacy_sql=false \
'WITH
Shots AS
(
SELECT
*,
/* 101 is known Tag for "goals" from goals table */
(101 IN UNNEST(tags.id)) AS isGoal,
/* Translate 0-100 (x,y) coordinate-based distances to absolute positions
using "average" field dimensions of 105x68 before combining in 2D dist calc */
SQRT(
POW(
  (100 - positions[ORDINAL(1)].x) * <MIDPOINT1>/<MIDPOINT2>,
  2) +
POW(
  (60 - positions[ORDINAL(1)].y) * <DIMENSIONS1>/<DIMENSIONS2>,
  2)
 ) AS shotDistance
FROM
`soccer.<EVENT_NAME>`
WHERE
/* Includes both "open play" & free kick shots (including penalties) */
eventName = "Shot" OR
(eventName = "Free Kick" AND subEventName IN ("Free kick shot", "Penalty"))
)
SELECT
ROUND(shotDistance, 0) AS ShotDistRound0,
COUNT(*) AS numShots,
SUM(IF(isGoal, 1, 0)) AS numGoals,
AVG(IF(isGoal, 1, 0)) AS goalPct
FROM
Shots
WHERE
shotDistance <= 50
GROUP BY
ShotDistRound0
ORDER BY
ShotDistRound0
'
completed "Task 3"

bq ls --routines soccer

bq query --use_legacy_sql=false \
'CREATE FUNCTION `<DISTANCE_FUNCTION>`(x INT64, y INT64)
RETURNS FLOAT64
AS (
 /* Translate 0-100 (x,y) coordinate-based distances to absolute positions
 using "average" field dimensions of <DIMENSIONS1>x<DIMENSIONS2> before combining in 2D dist calc */
 SQRT(
   POW((<MIDPOINT1> - x) * <DIMENSIONS1>/100, 2) +
   POW((<MIDPOINT2> - y) * <DIMENSIONS2>/100, 2)
   )
 );'

completed "Task 4"
bq query --use_legacy_sql=false \
'CREATE FUNCTION `<ANGLE_FUNCTION>`(x INT64, y INT64)
RETURNS FLOAT64
AS (
 SAFE.ACOS(
   /* Have to translate 0-100 (x,y) coordinates to absolute positions using
   "average" field dimensions of <DIMENSIONS1>x<DIMENSIONS2> before using in various distance calcs */
   SAFE_DIVIDE(
     ( /* Squared distance between shot and 1 post, in meters */
       (POW(<DIMENSIONS1> - (x * <DIMENSIONS1>/100), 2) + POW(<HALF_DIMENSIONS2> + (7.32/2) - (y * <DIMENSIONS2>/100), 2)) +
       /* Squared distance between shot and other post, in meters */
       (POW(<DIMENSIONS1> - (x * <DIMENSIONS1>/100), 2) + POW(<HALF_DIMENSIONS2> - (7.32/2) - (y * <DIMENSIONS2>/100), 2)) -
       /* Squared length of goal opening, in meters */
       POW(7.32, 2)
     ),
     (2 *
       /* Distance between shot and 1 post, in meters */
       SQRT(POW(<DIMENSIONS1> - (x * <DIMENSIONS1>/100), 2) + POW(<HALF_DIMENSIONS2> + 7.32/2 - (y * <DIMENSIONS2>/100), 2)) *
       /* Distance between shot and other post, in meters */
       SQRT(POW(<DIMENSIONS1> - (x * <DIMENSIONS1>/100), 2) + POW(<HALF_DIMENSIONS2> - 7.32/2 - (y * <DIMENSIONS2>/100), 2))
     )
    )
  /* Translate radians to degrees */
  ) * 180 / ACOS(-1)
 )
;'

bq ls --routines soccer
completed "Task 5"

bq query --use_legacy_sql=false \
'CREATE MODEL `<MODEL_NAME>`
OPTIONS(
model_type = "LOGISTIC_REG",
input_label_cols = ["isGoal"]
) AS
SELECT
Events.subEventName AS shotType,
/* 101 is known Tag for "goals" from goals table */
(101 IN UNNEST(Events.tags.id)) AS isGoal,
`<DISTANCE_FUNCTION>`(Events.positions[ORDINAL(1)].x,
Events.positions[ORDINAL(1)].y) AS shotDistance,
`<ANGLE_FUNCTION>`(Events.positions[ORDINAL(1)].x,
Events.positions[ORDINAL(1)].y) AS shotAngle
FROM
`soccer.<EVENT_NAME>` Events
LEFT JOIN
`soccer.matches` Matches ON
Events.matchId = Matches.wyId
LEFT JOIN
`soccer.competitions` Competitions ON
Matches.competitionId = Competitions.wyId
WHERE
/* Filter out World Cup matches for model fitting purposes */
Competitions.name != "World Cup" AND
/* Includes both "open play" & free kick shots (including penalties) */
(
eventName = "Shot" OR
(eventName = "Free Kick" AND subEventName IN ("Free kick shot", "Penalty"))
)
;'

completed "Task 6"

bq query --use_legacy_sql=false \
'SELECT
predicted_isGoal_probs[ORDINAL(1)].prob AS predictedGoalProb,
* EXCEPT (predicted_isGoal, predicted_isGoal_probs),
FROM
ML.PREDICT(
MODEL `<MODEL_NAME>`, 
(
 SELECT
   Events.playerId,
   (Players.firstName || " " || Players.lastName) AS playerName,
   Teams.name AS teamName,
   CAST(Matches.dateutc AS DATE) AS matchDate,
   Matches.label AS match,
 /* Convert match period and event seconds to minute of match */
   CAST((CASE
     WHEN Events.matchPeriod = "1H" THEN 0
     WHEN Events.matchPeriod = "2H" THEN 45
     WHEN Events.matchPeriod = "E1" THEN 90
     WHEN Events.matchPeriod = "E2" THEN 105
     ELSE 120
     END) +
     CEILING(Events.eventSec / 60) AS INT64)
     AS matchMinute,
   Events.subEventName AS shotType,
   /* 101 is known Tag for "goals" from goals table */
   (101 IN UNNEST(Events.tags.id)) AS isGoal,
 
   `<DISTANCE_FUNCTION>`(Events.positions[ORDINAL(1)].x,
       Events.positions[ORDINAL(1)].y) AS shotDistance,
   `<ANGLE_FUNCTION>`(Events.positions[ORDINAL(1)].x,
       Events.positions[ORDINAL(1)].y) AS shotAngle
 FROM
   `soccer.<EVENT_NAME>` Events
 LEFT JOIN
   `soccer.matches` Matches ON
       Events.matchId = Matches.wyId
 LEFT JOIN
   `soccer.competitions` Competitions ON
       Matches.competitionId = Competitions.wyId
 LEFT JOIN
   `soccer.players` Players ON
       Events.playerId = Players.wyId
 LEFT JOIN
   `soccer.teams` Teams ON
       Events.teamId = Teams.wyId
 WHERE
   /* Look only at World Cup matches to apply model */
   Competitions.name = "World Cup" AND
   /* Includes both "open play" & free kick shots (but not penalties) */
   (
     eventName = "Shot" OR
     (eventName = "Free Kick" AND subEventName IN ("Free kick shot"))
   ) AND
   /* Filter only to goals scored */
   (101 IN UNNEST(Events.tags.id))
)
)
ORDER BY
predictedgoalProb
'
completed "Task 7"

completed "Lab"

remove_files