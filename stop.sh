#!/bin/sh

spigScrName=pimpcraftSpigot
plumScrName=pimpcraftPlumber
shinScrName=pimpcraftShiny

screen -S $spigScrName -p 0 -X stuff "stop
"
screen -S $plumScrName -p 0 -X stuff 'kill $! ; exit
'
screen -S $shinScrName -p 0 -X stuff 'kill $! ; exit
'

sleep 5;

if ! screen -ls | grep -q $spigScrName && ! screen -ls | grep -q $plumScrName && ! screen -ls | grep -q $shinScrName
then
  echo "PiMPCraft has stopped."
else
  echo "Something went wrong. Please stop the PiMPCraft screen sessions individually (see the screen documentation)."
fi
