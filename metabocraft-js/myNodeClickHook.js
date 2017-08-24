//Builds the graph of a pathway selected in the map

var store = require('storage');
var telepimp = require('telepimp');

function myNodeClickHook(event){
  var player = event.player;
  //Fire on right-clicks only
  if(event.getAction() == 'RIGHT_CLICK_BLOCK'){
    //Right-clicks normally fire two events, one for each hand - only process one!
    if(event.getHand() == 'HAND'){
      //Bookshelves are pathways on map, process accordingly
      if(event.getClickedBlock().getType() == 'BOOKSHELF'){
        var location = event.getClickedBlock().getLocation();
        /**
         * For some reason, getNearbyEntities works on a cuboid of 2X the given dimensions
         * This matches the dimensions of the pathway map nodes (0.6 is rounded down
         * to 1, 0.5 fails due to double math). Sometimes, apparently at random,
         * this will fail to select a node. This is to be treated as a known bug.
         */
        var entList = location.world.getNearbyEntities(location, 0.6, 2, 0.6);
        for(var i = 0; i <= entList.length; i++){
          if(i === entList.length){
            echo(player, 'Something has gone wrong with your session!\nPlease use /jsp reset or disconnect and\nreconnect to the server to try again.');
          }
          else {
            var selection = entList[i].getCustomName();
            //The armor stand should be the only entity in the area with a custom name
            if(selection){
              telepimp(player);
              var d = new Drone(player);
              d.buildGraph(store[player.name]['bioSource'], selection, player.name);
              telepimp(player, 'graph');
              break;
            }
          }
        }
      }
      //Pumpkins are compartments, process accordingly
      else if(event.getClickedBlock().getType() == 'PUMPKIN'){
        var location = event.getClickedBlock().getLocation();
        var selection = location.world.getNearbyEntities(location, 1, 1, 1)[0].getCustomName();
        if(selection === 'Everything'){
          selection = '';
        }
        telepimp(player);
        var d = new Drone(player);
        d.buildMap(store[player.name]['bioSource'], selection);
        telepimp(player, 'map');
      }
      //Sign posts are currently only used for the back to map button as part of an error message.
      //Could have alternative uses in the future.
      else if(event.getClickedBlock().getType() == 'SIGN_POST'){
        if(event.getClickedBlock().getState().getLine(0) === 'Back to map' || event.getClickedBlock().getState().getLine(0) === 'HERE'){
          telepimp(player);
          var d = new Drone(player)
          d.buildMap(store[player.name]['bioSource']);
          telepimp(player, 'map');
        }
      }
    }
  }
}
events.playerInteract(myNodeClickHook);
