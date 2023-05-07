#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE TABLE games, teams RESTART IDENTITY CASCADE;")

# tail skips line with headers
cat games.csv | tail -n +2 | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  echo "$YEAR | $ROUND | $WINNER | $OPPONENT | $WINNER_GOALS | $OPPONENT_GOALS"

  # Get team id 
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
  # if not found
  if [[ -z $WINNER_ID ]]
  then
    INSERT_WINNER_TEAM_RESULT=$($PSQL "INSERT INTO TEAMS(name) VALUES('$WINNER')")
    if [[ $INSERT_WINNER_TEAM_RESULT == "INSERT 0 1" ]]
    then
      echo "Inserted into teams: $WINNER"
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    fi
  fi

  # get team id
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
  # if not found
  if [[ -z $OPPONENT_ID ]]
  then
    INSERT_OPPONENT_TEAM_RESULT=$($PSQL "INSERT INTO TEAMS(name) VALUES('$OPPONENT')")
    if [[ $INSERT_OPPONENT_TEAM_RESULT == "INSERT 0 1" ]]
    then
      echo "Inserted into teams: $OPPONENT"
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    fi
  fi

  INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
  if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
  then
    echo "Inserted into games: Year: $YEAR | Round: $ROUND | WinnerID: $WINNER_ID | OpponentID: $OPPONENT_ID | Score: $WINNER_GOALS - $OPPONENT_GOALS"
  fi
done
