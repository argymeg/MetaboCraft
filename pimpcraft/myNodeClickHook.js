//Builds the graph of a pathway selected in the map

var store = require('storage');
var telepimp = require('telepimp');

function myNodeClickHook(event){
  var player = event.player;
  if(event.getAction() == 'RIGHT_CLICK_BLOCK'){
    if(event.getClickedBlock().getType() == 'REDSTONE_BLOCK'){
      if(event.getHand() == 'HAND'){
        var location = event.getClickedBlock().getLocation();
        var selection = location.world.getNearbyEntities(location, 2, 2, 2)[0].getCustomName();
        selection = selection.replace(/ /g, "%20");

        telepimp(player);
        var d = new Drone(player);
        d.pullFromRAndBuildThis(store[player.name]['bioSource'], selection, player.name);
        telepimp(player, 'graph');
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
