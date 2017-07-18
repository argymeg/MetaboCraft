#!/bin/sh

cd spigot
screen -dmS pimpcraftSpigot
screen -S pimpcraftSpigot -p 0 -X stuff "cd spigot
"
screen -S pimpcraftSpigot -p 0 -X stuff "exec java -jar $(ls | grep spigot- )
"

#Start plumber and shiny as background children in their own shells
#This makes it A LOT easier to kill them when stopping (since they
#refuse to die when their screen does) but we can't tell if they actually
#started correctly, which is A Bad Idea(tm).
cd ../Rscripts
screen -dmS pimpcraftPlumber
screen -S pimpcraftPlumber -p 0 -X stuff "./startPlumber.R &
"
screen -dmS pimpcraftShiny
screen -S pimpcraftShiny -p 0 -X stuff "./startShiny.R &
"

sleep 5;
if screen -ls | grep -q pimpcraftSpigot && screen -ls | grep -q pimpcraftPlumber && screen -ls | grep -q pimpcraftShiny
then
  printf "PiMPCraft is up and running!\nYou can now access your local PiMPCraft homepage at\nhttp://localhost:32909/\n"
else
  echo "Something went wrong. You can try starting the PiMPCraft components individually (see documentation)."
fi
