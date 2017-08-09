#!/usr/bin/env bash

readonly SPIGOT_SCREEN_NAME=pimpcraftSpigot
readonly PLUMBER_SCREEN_NAME=pimpcraftPlumber
readonly SHINY_SCREEN_NAME=pimpcraftShiny

screen -S $SPIGOT_SCREEN_NAME -p 0 -X stuff "stop
"
screen -S $PLUMBER_SCREEN_NAME -p 0 -X stuff 'kill $! ; exit
'
screen -S $SHINY_SCREEN_NAME -p 0 -X stuff 'kill $! ; exit
'

sleep 5;

if ! screen -ls | grep -q $SPIGOT_SCREEN_NAME && ! screen -ls | grep -q $PLUMBER_SCREEN_NAME && ! screen -ls | grep -q $SHINY_SCREEN_NAME
then
  echo "PiMPCraft has stopped."
else
  echo "Something went wrong. Please stop the PiMPCraft screen sessions individually (see the screen documentation)."
fi
