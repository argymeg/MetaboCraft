//Module to teleport player to different locations depending on parameters
var store = require('storage');
var teleport = require('teleport');
var utils = require('utils')

function telepimp(player, vantage){
  //Move to vantage point suitable for viewing the map
  if(vantage === 'map'){
    var vantagePoint = store[player.name]['location']
    vantagePoint['y'] = 11;
    vantagePoint['pitch'] = 42;
    vantagePoint['yaw'] = 46;
    teleport(player, vantagePoint);
  }
  //Move to vantage point suitable for viewing a pathway
  else if(vantage === 'graph'){
    var vantagePoint = store[player.name]['location']
    vantagePoint['pitch'] = -24;
    vantagePoint['yaw'] = 34;
    teleport(player, vantagePoint);
  }
  //If called without a valid 'vantage' argument, assume we are moving to a new location
  else {
    //If no location is stored for player (i.e. on join), randomise location completely
    if(!store[player.name]['location']) {
      store[player.name]['location'] = player.location;
      store[player.name]['location']['x'] = Math.random() * 1000000;
      store[player.name]['location']['y'] = 4;
      store[player.name]['location']['z'] = Math.random() * 1000000;
      store[player.name]['location']['pitch'] = 0;
      store[player.name]['location']['yaw'] = 0;
      teleport(player, store[player.name]['location']);
    }
    //Move player to a new location relative to their last one
    else {
      store[player.name]['location']['x'] = store[player.name]['location']['x'] + 2000;
      store[player.name]['location']['y'] = 4;
      store[player.name]['location']['z'] = store[player.name]['location']['z'] + 2000;
      store[player.name]['location']['pitch'] = 0;
      store[player.name]['location']['yaw'] = 0;
      teleport(player, store[player.name]['location']);
    }
  }
}
module.exports = telepimp;
