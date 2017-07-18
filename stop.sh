#!/bin/sh

screen -S pimpcraftSpigot -p 0 -X stuff "stop
"
screen -S pimpcraftPlumber -p 0 -X stuff 'kill $! ; exit
'
screen -S pimpcraftShiny -p 0 -X stuff 'kill $! ; exit
'

sleep 5;

if ! screen -ls | grep -q pimpcraftSpigot && ! screen -ls | grep -q pimpcraftPlumber && ! screen -ls | grep -q pimpcraftShiny
then
  echo "PiMPCraft has stopped."
else
  echo "Something went wrong. Please stop the PiMPCraft screen sessions individually (see the screen documentation)."
fi
