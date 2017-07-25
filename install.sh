#!/bin/sh

startDir=$PWD
logFile="$startDir/install.log"
buildtoolsSource='https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar'
buildtoolsDest='BuildTools.jar'
scriptcraftSource='https://scriptcraftjs.org/download/latest/scriptcraft-3.2.1/scriptcraft.jar'
scriptcraftDest='scriptcraft.jar'
worldeditSource='https://dev.bukkit.org/projects/worldedit/files/956525/download'
worldeditDest='worldedit-bukkit-6.1.5.jar'
worldguardSource='https://dev.bukkit.org/projects/worldguard/files/956770/download'
worldguardDest='worldguard-6.2.jar'
depends=( curl java screen Rscript )
rdepends=( igraph jsonlite shiny plumber )
jscriptDir='pimpcraft'
rscriptDir='Rscripts'
moduleDir='modules'
spigotDir='spigot'
cacheDir='cache'
initScrName='initServer'

function downloadFile {
  curl -fL -o $1 $2 2>> $logFile
  if [ ! -f $1 ]
  then
    printf "\nError downloading $1! Check the log for details.\n" | tee -a $logFile
    exit
  else
    echo "OK" | tee -a $logFile
  fi
}

printf "\nWelcome to the PiMPCraft installer!\nThis script will download, compile and install everything you need\nto run PiMPCraft on your local computer.\nPlease read the documentation before proceeding!\n\n" | tee $logFile
printf "In order to run the Spigot server, necesssary to run PiMPCraft,\nyou need to agree to the Minecraft EULA, which you can read at\nhttps://account.mojang.com/documents/minecraft_eula\n\n!!!BY PROCEEDING YOU INDICATE YOUR AGREEMENT TO THE MINECRAFT EULA!!!\n" | tee $logFile
printf "Proceed? [y/N] "
read answer
if [ "$answer" != "y" ]
then
  exit
fi

if [ ! -d $jscriptDir ] || [ ! -d $rscriptDir ] || [ ! -d $moduleDir ]
then
  printf "PiMPCraft files missing!\nEnsure you are running the install script inside\nthe full PiMPCraft directory as downloaded and try again.\n" | tee -a $logFile
  exit
fi

if [ -d $spigotDir ]
then
  printf "You seem to be running the installer in a directory containing\nan existing installation. This will be WIPED if you proceed.\n" | tee -a $logFile
  printf "Proceed? [y/N] "
  read answer
  if [ "$answer" != "y" ]
  then
    exit
  fi
fi

echo "Checking for dependencies..."
for i in ${depends[@]}
do
  if which $i > /dev/null 2>&1
  then
    echo "Checking for $i... OK" | tee -a $logFile
  else
    echo "Missing dependency: $i. You cannot proceed with installation!" | tee -a $logFile
    exit
  fi
done

mkdir $spigotDir > /dev/null 2>&1
mkdir $cacheDir > /dev/null 2>&1
if ! cd $spigotDir > /dev/null 2>&1
then
  printf "Something went wrong creating the directory structure!\nEnsure you have write permissions for this location\nand try again.\n" | tee -a $logFile
  exit
fi

printf "Downloading BuildTools... " | tee -a $logFile
downloadFile $buildtoolsDest $buildtoolsSource

printf "Building Spigot - this may take a few minutes... " | tee -a $logFile
java -jar $buildtoolsDest --rev 1.11.2 >> $logFile 2>&1
if ! ls | grep spigot-*.jar > /dev/null
then
  echo "Error building Spigot! Check the log for details." | tee -a $logFile
  exit
else
  echo "OK" | tee -a $logFile
fi

printf "Cleaning up build environment... " | tee -a $logFile
ls | grep -v spigot-*.jar | xargs rm -r
echo "OK" | tee -a $logFile

mkdir plugins #Hardcoding since it's determined by Spigot, not us!

printf "Downloading ScriptCraft... " | tee -a $logFile
downloadFile plugins/$scriptcraftDest $scriptcraftSource

printf "Downloading WorldEdit... " | tee -a $logFile
downloadFile plugins/$worldeditDest $worldeditSource

printf "Downloading WorldGuard... " | tee -a $logFile
downloadFile plugins/$worldguardDest $worldguardSource

#A bunch of hardcoded configs here
printf "Initialising config files... " | tee -a $logFile
echo "eula=true" > eula.txt
printf "allow-nether=false\ngamemode=1\nlevel-type=FLAT\nspawn-monsters=false\nspawn-npcs=false\nspawn-animals=false\ngenerate-structures=false\npvp=false\ngenerator-settings=3;minecraft:bedrock,2*minecraft:stone,minecraft:grass,minecraft:snow_layer;12;biome_1,village" > server.properties
mkdir plugins/WorldGuard
printf "build-permission-nodes:\n    enable: true\n    deny-message: \'\'\n" > plugins/WorldGuard/config.yml
echo "OK" | tee -a $logFile

#And some hardcoded directories here
printf "Installing PiMPCraft on server... " | tee -a $logFile
mkdir -p scriptcraft/plugins
ln -s $startDir/pimpcraft scriptcraft/plugins/
mkdir scriptcraft/modules
ln -s $startDir/modules/* scriptcraft/modules
echo "OK" | tee -a $logFile

printf "Initialising server... " | tee -a $logFile
screen -dmS $initScrName
screen -S $initScrName -p 0 -X stuff "exec java -jar $(ls | grep spigot- )
"
screen -S $initScrName -p 0 -X stuff "gamerule doDaylightCycle false
"
screen -S $initScrName -p 0 -X stuff "gamerule doWeatherCycle false
"
screen -S $initScrName -p 0 -X stuff "time set 6000
"
screen -S $initScrName -p 0 -X stuff "stop
"

while screen -ls | grep -q $initScrName
do
  sleep 1
done

#Hardcoded Spigot logfile name
cat logs/latest.log >> $logFile
echo "OK" | tee -a $logFile

echo "Checking for missing R packages..." | tee -a $logFile

#If we are on Linux and the R library is not in a home directory, assume it is not user-writable and do not attempt to install
#There could be other configurations on which this check is not enough!
if [ $(uname) = "Linux" ] && ! Rscript -e '.libPaths()' | grep -q home
then
  for i in ${rdepends[@]}
  do
    Rscript -e "if(length(find.package(\"$i\", quiet = TRUE))){writeLines(\"Checking for $i... OK\")}else{writeLines(\"Checking for $i... NOT FOUND\")}"  | tee -a $logFile
  done
  printf "It looks like your R library is not user-writable!\nIF any packages were marked as not found, please install them.\n" | tee -a $logFile
else
  for i in ${rdepends[@]}
  do
    Rscript -e "if(length(find.package(\"$i\", quiet = TRUE))){writeLines(\"Checking for $i... OK\")}else{writeLines(\"Checking for $i... Not found, installing...\");install.packages(\"$i\", repos = \"https://cloud.r-project.org/\")}" | tee -a $logFile
  done
fi

echo "Done!" | tee -a $logFile
