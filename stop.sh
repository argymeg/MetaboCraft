#!/bin/sh

screen -S forSpigot -p 0 -X stuff "stop
"

screen -S forPlumber -p 0 -X kill
screen -S forShiny -p 0 -X kill
