//Fires when a player logs in, welcoming and initialising

var store = require('storage');
var http = require('http');
var Drone = require('drone');
var telepimp = require('telepimp');
var player, playerFiles;

function myJoinHook(event){
  player = event.player;
  var playerFileSource = 'http://localhost:32908/listplayerfiles?player=' + player.name;
  store[player.name] = {};
  store[player.name]['bioSource'] = 1363;//4324;

  http.request(playerFileSource,
  function(responseCode, responseBody){
    playerFiles = JSON.parse(responseBody);
    store[player.name]['currentFile'] = playerFiles[0];
    showGreeting();
  });
}

function showGreeting(){
  echo(player, "Welcome to PiMPCraft, " + player.name + "!");
  echo(player, "You are seeing BioSource " + store[player.name]['bioSource'] + ".");
  if(playerFiles.length > 0){
    store[player.name]['changeDataEnabled'] = true;
    echo(player, "Your currently available files are:");
    for(var i = 0; i < playerFiles.length; i++){
      echo(player, playerFiles[i]);
    }
    echo(player, "Your currently selected file is " + store[player.name]['currentFile']);
  }
  else{
    store[player.name]['changeDataEnabled'] = false;
    echo(player, "You do not have any currently uploaded files.")
  }

  telepimp(player);
  var d = new Drone(player)
  d.pullFromRAndBuildNetwork(store[player.name]['bioSource'])
}

events.playerJoin(myJoinHook);
