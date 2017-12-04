#!/usr/bin/env bash

readonly INST_START_DIR=$PWD
readonly INST_LOG_FILE=$INST_START_DIR/install.log
readonly SPIGOT_VER=1.11.2
readonly SPIGOT_FILENAME=spigot-$SPIGOT_VER.jar
readonly BUILDTOOLS_SOURCE=https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar
readonly BUILDTOOLS_DEST=BuildTools.jar
readonly SCRIPTCRAFT_SOURCE=https://scriptcraftjs.org/download/latest/scriptcraft-3.2.1/scriptcraft.jar
readonly SCRIPTCRAFT_DEST=scriptcraft.jar
readonly WORLDEDIT_SOURCE=https://dev.bukkit.org/projects/worldedit/files/956525/download
readonly WORLDEDIT_DEST=worldedit-bukkit-6.1.5.jar
readonly WORLDGUARD_SOURCE=https://dev.bukkit.org/projects/worldguard/files/956770/download
readonly WORLDGUARD_DEST=worldguard-6.2.jar
readonly -a INST_DEPENDS=( curl java screen Rscript git )
readonly -a INST_RDEPENDS=( igraph jsonlite shiny plumber markdown curl )
readonly JSCRIPT_DIR=metabocraft-js
readonly RSCRIPT_DIR=Rscripts
readonly MODULE_DIR=modules
readonly SPIGOT_DIR=spigot
readonly CACHE_DIR=cache
readonly INIT_SCREEN_NAME=initServer

function downloadFile {
  curl -fL -o $1 $2 2>> $INST_LOG_FILE
  if [ ! -f $1 ]
  then
    printf "\nError downloading $1! Check the log for details.\n" | tee -a $INST_LOG_FILE
    exit
  else
    echo "OK" | tee -a $INST_LOG_FILE
  fi
}

if [ -z $WEAREINDOCKER ]; then
  printf "\nWelcome to the MetaboCraft installer!\nThis script will download, compile and install everything you need\nto run MetaboCraft on your local computer.\nPlease read the documentation before proceeding!\n\n" | tee $INST_LOG_FILE
  printf "In order to run the Spigot server, necesssary to run MetaboCraft,\nyou need to agree to the Minecraft EULA, which you can read at\nhttps://account.mojang.com/documents/minecraft_eula\n\n!!!BY PROCEEDING YOU INDICATE YOUR AGREEMENT TO THE MINECRAFT EULA!!!\n" | tee $INST_LOG_FILE
  printf "Proceed? [y/N] "
  read answer
  if [ "$answer" != "y" ]
  then
    exit
  fi
fi


if [ ! -d $JSCRIPT_DIR ] || [ ! -d $RSCRIPT_DIR ] || [ ! -d $MODULE_DIR ]
then
  printf "MetaboCraft files missing!\nEnsure you are running the install script inside\nthe full MetaboCraft directory as downloaded and try again.\n" | tee -a $INST_LOG_FILE
  exit
fi

if [ -d $SPIGOT_DIR ]
then
  printf "You seem to be running the installer in a directory containing\nan existing installation. This will be WIPED if you proceed.\n" | tee -a $INST_LOG_FILE
  printf "Proceed? [y/N] "
  read answer
  if [ "$answer" != "y" ]
  then
    exit
  fi
fi

echo "Checking for dependencies..."
for i in ${INST_DEPENDS[@]}
do
  if which $i > /dev/null 2>&1
  then
    echo "Checking for $i... OK" | tee -a $INST_LOG_FILE
  else
    echo "Missing dependency: $i. You cannot proceed with installation!" | tee -a $INST_LOG_FILE
    exit
  fi
done

mkdir $SPIGOT_DIR > /dev/null 2>&1
mkdir $CACHE_DIR > /dev/null 2>&1
if ! cd $SPIGOT_DIR > /dev/null 2>&1
then
  printf "Something went wrong creating the directory structure!\nEnsure you have write permissions for this location\nand try again.\n" | tee -a $INST_LOG_FILE
  exit
fi

printf "Downloading BuildTools... " | tee -a $INST_LOG_FILE
downloadFile $BUILDTOOLS_DEST $BUILDTOOLS_SOURCE

printf "Building Spigot - this may take a few minutes... " | tee -a $INST_LOG_FILE
java -jar $BUILDTOOLS_DEST --rev $SPIGOT_VER >> $INST_LOG_FILE 2>&1
if [ ! -f $SPIGOT_FILENAME ]
then
  echo "Error building Spigot! Check the log for details." | tee -a $INST_LOG_FILE
  exit
else
  echo "OK" | tee -a $INST_LOG_FILE
fi

printf "Cleaning up build environment... " | tee -a $INST_LOG_FILE
ls | grep -v $SPIGOT_FILENAME | xargs rm -r
echo "OK" | tee -a $INST_LOG_FILE

mkdir plugins #Hardcoding since it's determined by Spigot, not us!

printf "Downloading ScriptCraft... " | tee -a $INST_LOG_FILE
downloadFile plugins/$SCRIPTCRAFT_DEST $SCRIPTCRAFT_SOURCE

printf "Downloading WorldEdit... " | tee -a $INST_LOG_FILE
downloadFile plugins/$WORLDEDIT_DEST $WORLDEDIT_SOURCE

printf "Downloading WorldGuard... " | tee -a $INST_LOG_FILE
downloadFile plugins/$WORLDGUARD_DEST $WORLDGUARD_SOURCE

#A bunch of hardcoded configs here
printf "Initialising config files... " | tee -a $INST_LOG_FILE
echo "eula=true" > eula.txt
printf "allow-nether=false\ngamemode=1\nlevel-type=FLAT\nspawn-monsters=false\nspawn-npcs=false\nspawn-animals=false\ngenerate-structures=false\npvp=false\ngenerator-settings=3;minecraft:bedrock,2*minecraft:stone,minecraft:grass,minecraft:snow_layer;12;biome_1,village" > server.properties
mkdir plugins/WorldGuard
printf "build-permission-nodes:\n    enable: true\n    deny-message: \'\'\n" > plugins/WorldGuard/config.yml
echo "OK" | tee -a $INST_LOG_FILE

#And some hardcoded directories here
printf "Installing MetaboCraft on server... " | tee -a $INST_LOG_FILE
mkdir -p scriptcraft/plugins
ln -s $INST_START_DIR/$JSCRIPT_DIR scriptcraft/plugins/
mkdir scriptcraft/modules
ln -s $INST_START_DIR/$MODULE_DIR/* scriptcraft/modules
echo "OK" | tee -a $INST_LOG_FILE

printf "Initialising server... " | tee -a $INST_LOG_FILE
screen -dmS $INIT_SCREEN_NAME
sleep 1
screen -S $INIT_SCREEN_NAME -p 0 -X stuff "exec java -jar $SPIGOT_FILENAME
"
screen -S $INIT_SCREEN_NAME -p 0 -X stuff "gamerule doDaylightCycle false
"
screen -S $INIT_SCREEN_NAME -p 0 -X stuff "gamerule doWeatherCycle false
"
screen -S $INIT_SCREEN_NAME -p 0 -X stuff "time set 6000
"
screen -S $INIT_SCREEN_NAME -p 0 -X stuff "stop
"

while screen -ls | grep -q $INIT_SCREEN_NAME
do
  sleep 1
done

#Hardcoded Spigot logfile name
cat logs/latest.log >> $INST_LOG_FILE
echo "OK" | tee -a $INST_LOG_FILE

echo "Checking for missing R packages..." | tee -a $INST_LOG_FILE

#If we are on Linux and the R library is not in a home directory, assume it is not user-writable and do not attempt to install
#There could be other configurations on which this check is not enough!
if [ $(uname) = "Linux" ] && ! Rscript -e '.libPaths()' 2> /dev/null | grep -q home
then
  for i in ${INST_RDEPENDS[@]}
  do
    Rscript -e "if(length(find.package(\"$i\", quiet = TRUE))){writeLines(\"Checking for $i... OK\")}else{writeLines(\"Checking for $i... NOT FOUND\")}"  | tee -a $INST_LOG_FILE
  done
  printf "It looks like your R library is not user-writable!\nIf any packages were marked as not found, please install them.\n" | tee -a $INST_LOG_FILE
else
  for i in ${INST_RDEPENDS[@]}
  do
    Rscript -e "if(length(find.package(\"$i\", quiet = TRUE))){writeLines(\"Checking for $i... OK\")}else{writeLines(\"Checking for $i... Not found, installing...\");install.packages(\"$i\", repos = \"https://cloud.r-project.org/\")}" | tee -a $INST_LOG_FILE
  done
  #Check for possible failures with installation!
  for i in ${INST_RDEPENDS[@]}
  do
    Rscript -e "if(length(find.package(\"$i\", quiet = TRUE))){cat()}else{writeLines(\"Failed to install $i! Please install it manually.\")}" | tee -a $INST_LOG_FILE
  done
fi

# This is to enable dynamically changing whether to be able to place blocks
# inside the docker container
tr '\n' '\t' <  plugins/WorldGuard/config.yml | sed 's/build-permission-nodes:\t    enable: true/build-permission-nodes:\t    enable: ${DISALLOW_PLACING_BLOCKS}/' | tr '\t' '\n' >  plugins/WorldGuard/config.yml.template

echo "Done!" | tee -a $INST_LOG_FILE
