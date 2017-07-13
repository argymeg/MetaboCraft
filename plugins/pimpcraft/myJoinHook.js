//Fires when a player logs in, welcoming and initialising

var store = require('storage');

function myJoinHook(event){
  console.log("Hello world!");
  var player = event.player;
  store[player.name] = {};
  store[player.name]['bioSource'] = 4324;
  echo(player, "Welcome to PiMPCraft, " + player.name + "!")
  echo(player, "You are seeing BioSource " + store[player.name]['bioSource'] + ".")
  console.log("Goodbye world!");
}

events.playerJoin(myJoinHook);
