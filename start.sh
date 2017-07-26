#!/bin/sh

readonly SPIGOT_VER=1.11.2
readonly SPIGOT_FILENAME=spigot-$SPIGOT_VER.jar
readonly PLUMBER_FILENAME=startPlumber.R
readonly SHINY_FILENAME=startShiny.R
readonly SPIGOT_DIR=spigot
readonly SPIGOT_SCREEN_NAME=pimpcraftSpigot
readonly PLUMBER_SCREEN_NAME=pimpcraftPlumber
readonly SHINY_SCREEN_NAME=pimpcraftShiny

cd $SPIGOT_DIR
screen -dmS $SPIGOT_SCREEN_NAME
screen -S $SPIGOT_SCREEN_NAME -p 0 -X stuff "cd spigot
"
screen -S $SPIGOT_SCREEN_NAME -p 0 -X stuff "exec java -jar $SPIGOT_FILENAME
"

#Start plumber and shiny as background children in their own shells
#This makes it A LOT easier to kill them when stopping (since they
#refuse to die when their screen does) but we can't tell if they actually
#started correctly, which is A Bad Idea(tm).
cd ../Rscripts
screen -dmS $PLUMBER_SCREEN_NAME
screen -S $PLUMBER_SCREEN_NAME -p 0 -X stuff "./$PLUMBER_FILENAME &
"
screen -dmS $SHINY_SCREEN_NAME
screen -S $SHINY_SCREEN_NAME -p 0 -X stuff "./$SHINY_FILENAME &
"

sleep 5;
if screen -ls | grep -q $SPIGOT_SCREEN_NAME && screen -ls | grep -q $PLUMBER_SCREEN_NAME && screen -ls | grep -q $SHINY_SCREEN_NAME
then
  printf "PiMPCraft is up and running!\nYou can now access your local PiMPCraft homepage at\nhttp://localhost:32909/\n"
else
  echo "Something went wrong. You can try starting the PiMPCraft components individually (see documentation)."
fi
