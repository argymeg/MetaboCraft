#!/usr/bin/env bash

echo "Refreshing server..."

cd spigot
rm -r world*

screen -dmS initServer
sleep 1
screen -S initServer -p 0 -X stuff "exec java -jar $(ls | grep spigot- )
"
screen -S initServer -p 0 -X stuff "gamerule doDaylightCycle false
"
screen -S initServer -p 0 -X stuff "gamerule doWeatherCycle false
"
screen -S initServer -p 0 -X stuff "time set 6000
"
screen -S initServer -p 0 -X stuff "stop
"

while screen -ls | grep -q initServer
do
  sleep 1
done

echo "Done!"
