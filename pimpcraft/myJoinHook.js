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

//Get list of player files and set initial settings in store
function getPlayerInfo(){
  var playerFileSource = 'http://localhost:32908/listplayerfiles?player=' + player.name;
  store[player.name] = {};
  store[player.name]['bioSource'] = 4324;
  store[player.name]['mapMode'] = 'forcedirected';

  http.request(playerFileSource,
  function(responseCode, responseBody){
    var playerFiles = JSON.parse(responseBody);
    store[player.name]['fileList'] = playerFiles;
    store[player.name]['currentFile'] = playerFiles[0];
    showGreeting();
  });
}

//Show welcome message and player info
function showGreeting(){
  echo(player, "Welcome to PiMPCraft, " + player.name + "!");
  echo(player, "You are seeing BioSource " + store[player.name]['bioSource'] + ".");
  echo(player, "Your selected map layout is: " + store[player.name]['mapMode'] + ".");
  if(store[player.name]['fileList'].length > 0){
    store[player.name]['userDataEnabled'] = true;
    echo(player, "Your currently available files are:");
    for(var i = 0; i < store[player.name]['fileList'].length; i++){
      echo(player, store[player.name]['fileList'][i].match(/userData.+-(.+)\./)[1]);
    }
    echo(player, "Your currently selected file is " + store[player.name]['currentFile'].match(/userData.+-(.+)\./)[1] + ".");
  }
  else{
    store[player.name]['userDataEnabled'] = false;
    echo(player, "You do not have any currently uploaded files.")
  }

  //After showing player info, move to new location and build the network map
  telepimp(player);
  var d = new Drone(player)
  d.buildMap(store[player.name]['bioSource'])
  telepimp(player, 'map');
}
events.playerJoin(myJoinHook);

//Add the reset function to simulate the join events on command
function reset(parameters, player){
    getPlayerInfo();
}
command(reset);
