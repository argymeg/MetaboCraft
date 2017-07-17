#!/bin/bash

printf "\nWelcome to the PiMPCraft installer!\nThis script will download, compile and install everything you need\nto run PiMPCraft on your local computer.\nPlease read the documentation before proceeding!\n\n" | tee install.log
printf "In order to run the Spigot server, necesssary to run PiMPCraft,\nyou need to agree to the Minecraft EULA, which you can read at\nhttps://account.mojang.com/documents/minecraft_eula\n\n!!!BY PROCEEDING YOU INDICATE YOUR AGREEMENT TO THE MINECRAFT EULA!!!\n" | tee install.log
printf "Proceed? [y/N] "
read answer
if [ "$answer" != "y" ]
then
  exit
fi

if [ -d "server" ]
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
for i in curl java
do
  if which $i > /dev/null 2>&1
  then
    echo "Checking for $i... OK" | tee -a install.log
  else
    echo "Missing build dependency: $i. You cannot proceed with installation!" | tee -a install.log
    exit
  fi
done

for i in screen Rscript #more?
do
  if which $i > /dev/null 2>&1
  then
    echo "Checking for $i... OK" | tee -a install.log
  else
    printf "Missing runtime dependency: $i. You can proceed with installation,\nbut you will need to install this before running PiMPCraft!\n" | tee -a install.log
    printf "Proceed? [Y/n] "
    read answer
    if [ "$answer" = "n" ]
    then
      exit
    fi
  fi
done

mkdir server > /dev/null 2>&1
cd server

echo "Downloading BuildTools..." | tee -a ../install.log
curl -f -o BuildTools.jar https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar 2>> ../install.log
echo "Starting Spigot build - this may take a few minutes..." | tee -a ../install.log
java -jar BuildTools.jar --rev 1.11.2 >> ../install.log 2>&1
echo "Cleaning up build environment..." | tee -a ../install.log
ls | grep -v spigot- | xargs rm -r
echo "eula=true" > eula.txt
#Must also create server.properties!

echo "Downloading ScriptCraft..." | tee -a ../install.log
mkdir plugins
curl -f -o plugins/scriptcraft.jar https://scriptcraftjs.org/download/latest/scriptcraft-3.2.1/scriptcraft.jar 2>> ../install.log

echo "Installing PiMPCraft onto server... (not implemented yet!)"
#Starting here, copy PiMPCraft into appropriate folders before initialising
mkdir -p scriptcraft/plugins
mkdir scriptcraft/modules

echo "Initialising server..." | tee -a ../install.log

java -jar $(ls | grep spigot- ) |
while read -r line
do
  echo $line >> ../install.log
  if echo $line | grep -q Done
  then
    sleep 1;
    pkill -f java.*jar.*spigot
  fi
done

#This is a far more elegant solution, but it doesn't work with the
#ancient screen version still shipped with macOS...
#screen -dmS initServer
#screen -S initServer -X stuff "exec java -jar $(ls | grep spigot- ) \n"
#screen -S initServer -X stuff "stop \n"
#
#while screen -ls | grep -q initServer
#do
#  sleep 1;
#done
#
#cat logs/latest.log >> ../install.log

echo "Done!" | tee -a ../install.log
