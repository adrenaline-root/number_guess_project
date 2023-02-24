#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
# $PSQL "TRUNCATE TABLE games, users"


CHECK_FOR_INT() {
  GUESS=$1
  until [[ ! -z $GUESS && $GUESS =~ ^[0-9]*$ ]]
  do 
    echo "That is not an integer, guess again:"
    read GUESS
  done
}

SECRET_NUMBER=$(($RANDOM%1000))
NUMBER_OF_TRIES=$((1))
# echo "$SECRET_NUMBER"

PLAY_GAME() {
  echo "Guess the secret number between 1 and 1000:"
  read GUESS

  CHECK_FOR_INT $GUESS

  until [[ $GUESS -eq $SECRET_NUMBER ]] 
  do
    if [[ $GUESS -gt $SECRET_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
      read GUESS
    elif [[ $GUESS -lt $SECRET_NUMBER ]]
    then
      echo "It's higher than that, guess again:"
      read GUESS
    fi
    
    CHECK_FOR_INT $GUESS
    NUMBER_OF_TRIES=$(($NUMBER_OF_TRIES + 1))
  done

}

echo "Enter your username:"
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USERNAME'")

if [[ -z $USER_ID ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(name) VALUES('$USERNAME')")
  echo "$INSERT_USER_RESULT"
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USERNAME'")

  PLAY_GAME
  INSERT_USER_GAME=$($PSQL "INSERT INTO games(user_id, number_of_guesses) VALUES($USER_ID, $NUMBER_OF_TRIES)")

else
  USERNAME=$($PSQL "SELECT name FROM users WHERE user_id=$USER_ID")
  NUMBER_OF_GAMES=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID")
  BEST_SCORE=$($PSQL "SELECT MIN(number_of_guesses) FROM games WHERE user_id=$USER_ID")
  echo "Welcome back, $USERNAME! You have played $NUMBER_OF_GAMES games, and your best game took $BEST_SCORE guesses."
  PLAY_GAME
  INSERT_USER_GAME=$($PSQL "INSERT INTO games(user_id, number_of_guesses) VALUES($USER_ID, $NUMBER_OF_TRIES)")
fi

echo "You guessed it in $NUMBER_OF_TRIES tries. The secret number was $SECRET_NUMBER. Nice job!"

