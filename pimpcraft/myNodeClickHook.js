//Builds the graph of a pathway selected in the map

var store = require('storage');
var telepimp = require('telepimp');

function myNodeClickHook(event){
  var player = event.player;
  if(event.getAction() == 'RIGHT_CLICK_BLOCK'){
    if(event.getClickedBlock().getType() == 'BOOKSHELF'){
      if(event.getHand() == 'HAND'){
        var location = event.getClickedBlock().getLocation();
        var entList = location.world.getNearbyEntities(location, 0.6, 2, 0.6);
        for(var i = 0; i <= entList.length; i++){

          if(i === entList.length){
            echo(player, 'Could not select a pathway! Try again?');
          }
          else{
            var selection = entList[i].getCustomName();
            if(selection){
              telepimp(player);
              var d = new Drone(player);
              d.pullFromRAndBuildThis(store[player.name]['bioSource'], selection, player.name);
              telepimp(player, 'graph');
              break;
            }
          }
        }
      }
    }
    else if(event.getClickedBlock().getType() == 'PUMPKIN'){
      if(event.getHand() == 'HAND'){
        var location = event.getClickedBlock().getLocation();
        var selection = location.world.getNearbyEntities(location, 1, 1, 1)[0].getCustomName();
        if(selection == 'Everything'){
          selection = '';
        }
        telepimp(player);
        var d = new Drone(player);
        d.pullFromRAndBuildNetwork(store[player.name]['bioSource'], selection);
        telepimp(player, 'map');
      }
    }
    else if(event.getClickedBlock().getType() == 'SIGN_POST'){
      if(event.getHand() == 'HAND'){
        if(event.getClickedBlock().getState().getLine(0) == 'Back to map' || event.getClickedBlock().getState().getLine(0) == 'HERE'){
          telepimp(player);
          var d = new Drone(player)
          d.pullFromRAndBuildNetwork(store[player.name]['bioSource']);
          telepimp(player, 'map');
        }
      }
    }
  }
}
events.playerInteract(myNodeClickHook);
