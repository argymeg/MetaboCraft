//Builds the graph of a pathway selected in the map
//Currently throws multiple exceptions whenever any other block is clicked
//Many checks to be added before this fires
function myNodeClickHook(event){
  var player = event.player;
  var location = event.getClickedBlock().getLocation();
  //echo(breaker, location);
  var selection = location.world.getNearbyEntities(location, 2, 2, 2)[0].getCustomName();
  selection = selection.replace(/ /g, "%20")
  var d = new Drone(player);
  d.pullFromRAndBuildThis(selection);
}
events.playerInteract(myNodeClickHook);
