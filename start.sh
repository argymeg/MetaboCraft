#!/bin/sh

cd spigot
screen -dmS forSpigot
screen -S forSpigot -p 0 -X stuff "cd spigot
"
screen -S forSpigot -p 0 -X stuff "exec java -jar $(ls | grep spigot- )
"
echo done1
cd ../Rscripts
screen -dmS forPlumber
screen -S forPlumber -p 0 -X stuff "exec ./startPlumber.R"
echo done2
screen -dmS forShiny
screen -S forShiny -p 0 -X stuff "exec ./startShiny.R"
echo done3
