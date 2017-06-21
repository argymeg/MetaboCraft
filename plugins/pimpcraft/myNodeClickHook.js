//Builds the graph of a pathway selected in the map

function myNodeClickHook(event){
  var player = event.player;
  if(event.getAction() == 'RIGHT_CLICK_BLOCK'){
    if(event.getClickedBlock().getType() == 'REDSTONE_BLOCK'){
      if(event.getHand() == 'HAND'){
        var location = event.getClickedBlock().getLocation();
        var selection = location.world.getNearbyEntities(location, 2, 2, 2)[0].getCustomName();
        selection = selection.replace(/ /g, "%20");

        var d = new Drone(player);
        d.pullFromRAndBuildThis(selection);
      }
    }
  }
}
events.playerInteract(myNodeClickHook);
