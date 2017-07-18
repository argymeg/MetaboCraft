var store = require('storage');
var tp = require('teleport');
var utils = require('utils')

function telepimp(player){
  if(!store[player.name]['location']) {
    store[player.name]['location'] = player.location;
    store[player.name]['location']['x'] = Math.random() * 10000000;
    store[player.name]['location']['y'] = 4;
    store[player.name]['location']['z'] = Math.random() * 10000000;
    var newLocation = utils.locationFromJSON(store[player.name]['location'])
    tp(player, newLocation);
  }
  else {
    store[player.name]['location']['x'] = store[player.name]['location'][x] + 2000;
    store[player.name]['location']['y'] = 4;
    store[player.name]['location']['z'] = store[player.name]['location'][z] + 2000;
    var newLocation = utils.locationFromJSON(store[player.name]['location'])
    tp(player, newLocation);
  }
}

module.exports = telepimp;
