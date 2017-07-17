//Fires when a player logs in, welcoming and initialising

var store = require('storage');
var http = require('http');
var player, playerFiles;

function myJoinHook(event){
  player = event.player;
  var playerFileSource = 'http://localhost:32908/listplayerfiles?player=' + player.name;
  store[player.name] = {};
  store[player.name]['bioSource'] = 4324;

  http.request(playerFileSource,
  function(responseCode, responseBody){
    playerFiles = JSON.parse(responseBody);
    store[player.name]['currentFile'] = playerFiles[0];
    console.log(store[player.name]['currentFile']);
    showGreeting();
  });
}

function showGreeting(){
  echo(player, "Welcome to PiMPCraft, " + player.name + "!");
  echo(player, "You are seeing BioSource " + store[player.name]['bioSource'] + ".");
  echo(player, "Your currently available files are:");
  for(var i = 0; i < playerFiles.length; i++){
    echo(player, playerFiles[i]);
  }
  echo(player, "Your currently selected file is " + store[player.name]['currentFile']);
}

events.playerJoin(myJoinHook);
