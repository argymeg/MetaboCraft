//Various small functions providing console commands

var store = require('storage');
var teleport = require('teleport')
var utils = require('utils');

//Function to choose between player files (or disable user data display)
function chooseFile(parameters, player){
  if(parameters[0]){
    var targetFile = 'userData_' + player.name + '-' + parameters[0] + '.json'
    for(var i = 0; i <= store[player.name]['fileList'].length; i++)
    if(i === store[player.name]['fileList'].length){
      echo(player, "File not found!");
    }
    else if(targetFile === store[player.name]['fileList'][i]){
      store[player.name]['currentFile'] = targetFile;
      store[player.name]['userDataEnabled'] = true;
      echo(player, "Selected file: " + store[player.name]['currentFile'].match(/userData.+-(.+)\./)[1]);
      break;
    }
  }
  else {
    store[player.name]['currentFile'] = '';
    store[player.name]['userDataEnabled'] = false;
    echo(player, "User data disabled")
  }
}
command(chooseFile);

//Function to change the selected BioSource
function changeBioSource(parameters, player){
  if(parameters[0] % 1 === 0){
    store[player.name]['bioSource'] = parameters[0];
    echo(player, "You have selected BioSource " + store[player.name]['bioSource']);
  }
  else {
    echo(player, "Invalid BioSource ID!")
  }
}
command(changeBioSource);

//Function to teleport to another player's location
function teleportMe(parameters, player){
  if(parameters[0]){
    var players = utils.players();
    for(var j = 0; j <= players.length; j++){
      if(j === players.length){
        echo(player, "Player not found!");
      }
      else if(parameters[0] === players[j].name){
        var otherPlayerLocation = utils.getPlayerPos(parameters[0]);
        teleport(player.name, otherPlayerLocation);
        break;
      }
    }
  }
  else {
    echo(player, "Enter another player\'s name!")
  }
}
command(teleportMe);

//Function to toggle between force-directed and alphabetical map layout
function toggleMapMode(parameters, player){
  if(store[player.name]['mapMode'] === 'forcedirected'){
    store[player.name]['mapMode'] = 'alphabetical';
    echo(player, "Switched map to alphabetical mode");
  }
  else{
    store[player.name]['mapMode'] = 'forcedirected';
    echo(player, "Switched map to force-directed layout mode");
  }
}
command(toggleMapMode);
