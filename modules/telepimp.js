var store = require('storage');
var teleport = require('teleport');
var utils = require('utils')

function telepimp(player, vantage){

  if(vantage == 'map'){
    echo(player, "shouldbemap");
    var vantagePoint = store[player.name]['location']
    vantagePoint['y'] = 11;
    vantagePoint['pitch'] = 42;
    vantagePoint['yaw'] = 46;
    teleport(player, vantagePoint);
  }
  else if(vantage == 'graph'){
    var vantagePoint = store[player.name]['location']
    vantagePoint['pitch'] = -24;
    vantagePoint['yaw'] = 34;
    teleport(player, vantagePoint);
  }
  else{
    if(!store[player.name]['location']) {
      store[player.name]['location'] = player.location;
      store[player.name]['location']['x'] = Math.random() * 1000000;
      store[player.name]['location']['y'] = 4;
      store[player.name]['location']['z'] = Math.random() * 1000000;
      store[player.name]['location']['pitch'] = 0;
      store[player.name]['location']['yaw'] = 0;
      teleport(player, store[player.name]['location']);
    }
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
