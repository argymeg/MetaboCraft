//Fires when a player logs in, welcoming and initialising

var store = require('storage');
var http = require('http');
var Drone = require('drone');
var telepimp = require('telepimp');
var player;

function myJoinHook(event){
  player = event.player;
  getPlayerInfo();
}

function getPlayerInfo(){
  var playerFileSource = 'http://localhost:32908/listplayerfiles?player=' + player.name;
  store[player.name] = {};
  store[player.name]['bioSource'] = 4324;

  http.request(playerFileSource,
  function(responseCode, responseBody){
    var playerFiles = JSON.parse(responseBody);
    store[player.name]['fileList'] = playerFiles;
    store[player.name]['currentFile'] = playerFiles[0];
    showGreeting();
  });
}

function showGreeting(){
  echo(player, "Welcome to PiMPCraft, " + player.name + "!");
  echo(player, "You are seeing BioSource " + store[player.name]['bioSource'] + ".");
  if(store[player.name]['fileList'].length > 0){
    store[player.name]['changeDataEnabled'] = true;
    echo(player, "Your currently available files are:");
    for(var i = 0; i < store[player.name]['fileList'].length; i++){
      echo(player, store[player.name]['fileList'][i].match(/changeData.+-(.+)\./)[1]);
    }
    echo(player, "Your currently selected file is " + store[player.name]['currentFile'].match(/changeData.+-(.+)\./)[1]);
  }
  else{
    store[player.name]['changeDataEnabled'] = false;
    echo(player, "You do not have any currently uploaded files.")
  }

  telepimp(player);
  var d = new Drone(player)
  d.pullFromRAndBuildNetwork(store[player.name]['bioSource'])
  telepimp(player, 'map');
}

events.playerJoin(myJoinHook);

function refresh(parameters, player){
    getPlayerInfo();
}

command(refresh);
