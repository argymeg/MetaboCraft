var store = require('storage');
var teleport = require('teleport')
var utils = require('utils');

function chooseFile(parameters, player){
  if(parameters[0]){
    var targetFile = 'changeData_' + player.name + '-' + parameters[0] + '.json'
    for(var i = 0; i <= store[player.name]['fileList'].length; i++)
    if(i == store[player.name]['fileList'].length){
      echo(player, "File not found!");
    }
    else if(targetFile == store[player.name]['fileList'][i]){
      store[player.name]['currentFile'] = targetFile;
      store[player.name]['changeDataEnabled'] = true;
      echo(player, "Selected file: " + store[player.name]['currentFile'].match(/changeData.+-(.+)\./)[1]);
      break;
    }
  }
  else{
    store[player.name]['currentFile'] = '';
    store[player.name]['changeDataEnabled'] = false;
    echo(player, "User data disabled")
  }
}
command(chooseFile);

function changeBioSource(parameters, player){
  if(parameters[0] % 1 === 0){
    store[player.name]['bioSource'] = parameters[0];
    echo(player, "You have selected BioSource " + store[player.name]['bioSource']);
  }
  else{
    echo(player, "Invalid BioSource ID!")
  }

}
command(changeBioSource);

function teleportMe(parameters, player){
  if(parameters[0]){
    var players = utils.players();
    for(var j = 0; j <= players.length; j++){
      if(j == players.length){
        echo(player, "Player not found!");
      }
      else if(parameters[0] === players[j].name){
        var otherPlayerLocation = utils.getPlayerPos(parameters[0]);
        teleport(player.name, otherPlayerLocation);
        break;
      }
    }
  }
  else{
    echo(player, "Enter another player\'s name!")
  }
}

command(teleportMe);
