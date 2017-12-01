#!/usr/bin/env bash

readonly SPIGOT_VER=1.11.2
readonly SPIGOT_FILENAME=spigot-$SPIGOT_VER.jar
readonly PLUMBER_FILENAME=startPlumber.R
readonly SHINY_FILENAME=startShiny.R
readonly SPIGOT_DIR=spigot
readonly SPIGOT_SCREEN_NAME=metabocraftSpigot
readonly PLUMBER_SCREEN_NAME=metabocraftPlumber
readonly SHINY_SCREEN_NAME=metabocraftShiny

cd $SPIGOT_DIR
screen -dmS $SPIGOT_SCREEN_NAME
sleep 1
screen -S $SPIGOT_SCREEN_NAME -p 0 -X stuff "cd spigot
"
screen -S $SPIGOT_SCREEN_NAME -p 0 -X stuff "exec java -jar $SPIGOT_FILENAME
"

#Start plumber and shiny as background children in their own shells
#This is a temporary solution for being able to stop them at shutdown
#(since they refuse to simply die when their screen does)
#but we can't tell if they actually started correctly, which is far from ideal.
cd ../Rscripts
screen -dmS $PLUMBER_SCREEN_NAME
sleep 1
screen -S $PLUMBER_SCREEN_NAME -p 0 -X stuff "./$PLUMBER_FILENAME &
"
screen -dmS $SHINY_SCREEN_NAME
sleep 1
screen -S $SHINY_SCREEN_NAME -p 0 -X stuff "./$SHINY_FILENAME &
"

sleep 5;
if screen -ls | grep -q $SPIGOT_SCREEN_NAME && screen -ls | grep -q $PLUMBER_SCREEN_NAME && screen -ls | grep -q $SHINY_SCREEN_NAME
then
  if [ $WEAREINDOCKER ]
  then
    printf "MetaboCraft is up and running!\nYou can now access your MetaboCraft homepage at the port it is mapped to on this server.\n"
    printf "For example if you published the service at port 80,\n"
    printf "using docker run -p 25565:25565 -p 80:32909 ronandaly/metabocraft\n"
    printf "you can access the homepage at http://localhost/\n"
  else
    printf "MetaboCraft is up and running!\nYou can now access your local MetaboCraft homepage at\nhttp://localhost:32909/\n"
  fi
else
  echo "Something went wrong. You can try starting the MetaboCraft components individually (see documentation)."
fi
