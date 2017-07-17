#!/bin/bash

printf "\nWelcome to the PiMPCraft installer!\nThis script will download, compile and install everything you need\nto run PiMPCraft on your local computer.\nPlease read the documentation before proceeding!\n\n" | tee install.log
printf "In order to run the Spigot server, necesssary to run PiMPCraft,\nyou need to agree to the Minecraft EULA, which you can read at\nhttps://account.mojang.com/documents/minecraft_eula\n\n!!!BY PROCEEDING YOU INDICATE YOUR AGREEMENT TO THE MINECRAFT EULA!!!\n" | tee install.log
printf "Proceed? [y/N] "
read answer
if [ "$answer" != "y" ]
then
  exit
fi

if [ -d "spigot" ]
then
  printf "You seem to be running the installer in a directory containing\nan existing installation. This will be WIPED if you proceed.\n" | tee -a install.log
  printf "Proceed? [y/N] "
  read answer
  if [ "$answer" != "y" ]
  then
    exit
  fi
fi

echo "Checking for dependencies..."
for i in curl java screen Rscript
do
  if which $i > /dev/null 2>&1
  then
    echo "Checking for $i... OK" | tee -a install.log
  else
    echo "Missing dependency: $i. You cannot proceed with installation!" | tee -a install.log
    exit
  fi
done

STARTDIR=$PWD

mkdir cache > /dev/null 2>&1
mkdir spigot > /dev/null 2>&1
cd spigot

echo "Downloading BuildTools..." | tee -a ../install.log
curl -f -o BuildTools.jar https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar 2>> ../install.log
echo "Starting Spigot build - this may take a few minutes..." | tee -a ../install.log
java -jar BuildTools.jar --rev 1.11.2 >> ../install.log 2>&1
echo "Cleaning up build environment..." | tee -a ../install.log
ls | grep -v spigot- | xargs rm -r
echo "eula=true" > eula.txt
printf "allow-nether=false\ngamemode=1\nlevel-type=FLAT\nspawn-monsters=false\nspawn-npcs=false\nspawn-animals=false\ngenerate-structures=false\npvp=false" > server.properties

echo "Downloading ScriptCraft..." | tee -a ../install.log
mkdir plugins
curl -f -o plugins/scriptcraft.jar https://scriptcraftjs.org/download/latest/scriptcraft-3.2.1/scriptcraft.jar 2>> ../install.log

echo "Installing PiMPCraft onto server..."
mkdir -p scriptcraft/plugins
ln -s $STARTDIR/pimpcraft scriptcraft/plugins/
mkdir scriptcraft/modules
ln -s $STARTDIR/modules/* scriptcraft/modules

echo "Initialising server..." | tee -a ../install.log

screen -dmS initServer
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
  sleep 1;
done

cat logs/latest.log >> ../install.log

echo "Installing missing R packages (if any)..." | tee -a ../install.log

for i in igraph jsonlite shiny plumber
do
  Rscript -e "if(!require($i)){install.packages(\"$i\", repos = \"https://cloud.r-project.org/\")}" > /dev/null 2>&1
done

echo "Done!" | tee -a ../install.log
