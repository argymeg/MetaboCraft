#!/bin/sh

spigotVer=1.11.2
spigotFname=spigot-$spigotVer.jar
plumberFname=startPlumber.R
shinyFname=startShiny.R
spigotDir=spigot
spigScrName=pimpcraftSpigot
plumScrName=pimpcraftPlumber
shinScrName=pimpcraftShiny

cd $spigotDir
screen -dmS $spigScrName
screen -S $spigScrName -p 0 -X stuff "cd spigot
"
screen -S $spigScrName -p 0 -X stuff "exec java -jar $spigotFname
"

#Start plumber and shiny as background children in their own shells
#This makes it A LOT easier to kill them when stopping (since they
#refuse to die when their screen does) but we can't tell if they actually
#started correctly, which is A Bad Idea(tm).
cd ../Rscripts
screen -dmS $plumScrName
screen -S $plumScrName -p 0 -X stuff "./$plumberFname &
"
screen -dmS $shinScrName
screen -S $shinScrName -p 0 -X stuff "./$shinyFname &
"

sleep 5;
if screen -ls | grep -q $spigScrName && screen -ls | grep -q $plumScrName && screen -ls | grep -q $shinScrName
then
  printf "PiMPCraft is up and running!\nYou can now access your local PiMPCraft homepage at\nhttp://localhost:32909/\n"
else
  echo "Something went wrong. You can try starting the PiMPCraft components individually (see documentation)."
fi
