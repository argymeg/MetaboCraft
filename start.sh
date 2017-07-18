#!/bin/sh

cd spigot
screen -dmS pimpcraftSpigot
screen -S pimpcraftSpigot -p 0 -X stuff "cd spigot
"
screen -S pimpcraftSpigot -p 0 -X stuff "exec java -jar $(ls | grep spigot- )
"

cd ../Rscripts
screen -dmS pimpcraftPlumber
screen -S pimpcraftPlumber -p 0 -X stuff "exec ./startPlumber.R"
screen -dmS pimpcraftShiny
screen -S pimpcraftShiny -p 0 -X stuff "exec ./startShiny.R"

if screen -ls | grep -q pimpcraftSpigot && screen -ls | grep -q pimpcraftPlumber && screen -ls | grep -q pimpcraftShiny
then
  echo "PiMPCraft is up and running!"
else
  echo "Something went wrong. You can try starting the PiMPCraft components individually (see documentation)."
fi
