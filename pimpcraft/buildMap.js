/*
Build metabolic network map
Core functionality same as building graph, but too much divergence
to merge code just now. Might be worth the effort in the future.
*/

var Drone = require('drone');
var http = require('http');
var store = require('storage');
var telepimp = require('telepimp');
var data, compartmentList;
var pathMapSource, compartmentSource;

function buildMap(bioSource, compartment){
  pathMapSource = 'http://localhost:32908/pathmap?biosource=' + bioSource + '&mode=' + store[this.player.name]['mapMode'];
  compartmentSource = 'http://localhost:32908/compartmentlist?biosource=' + bioSource;

  //Construct the info message for the player, depending on whether or not we have a compartment.
  var message = 'Showing network map for BioSource: ' + bioSource;
  if(compartment){
    pathMapSource = pathMapSource + '&compartment=' + compartment;
    message += ', compartment: ' + compartment;
  }
  echo(this.player, message);

  getMap(this);
}

function getMap(dronea){

  http.request(pathMapSource,
  function(responseCode, responseBody){
    try{
      data = JSON.parse(responseBody);
      getCompartments(dronea);
    }
    catch(err){
      handleError(dronea);
    }
  });
}
function getCompartments(droneb){
  http.request(compartmentSource,
  function(responseCode,responseBody){
    try{
      compartmentList = JSON.parse(responseBody);
      actuallyBuild(droneb);
    }
    catch(err){
      handleError(droneb);
    }
  });
}

function actuallyBuild(dronec){
  var material;
  dronec.chkpt('pointzero');

  //Build the network map
  for(var i = 0; i < data.nodes.length; i++){
    material = 47; //bookshelf

    //Move drone to node coordinates
    dronec.right(parseInt(data.nodes[i].x));
    dronec.fwd(parseInt(data.nodes[i].z));

    //Draw node as cuboid. Dimensions hardcoded as they are constant, could
    //switch to variable in the future (as is the case for pathway graphs).
    dronec.cuboidX(material, '', 1, 2, 1, true);

    //Create invisible armor stand that displays the node name
    dronec.up(1);
    var location = dronec.getLocation();
    var ars = location.world.spawnEntity(location, org.bukkit.entity.EntityType.ARMOR_STAND)
    ars.setVisible(false);
    ars.setGravity(false);
    ars.setInvulnerable(true);
    ars.setCustomName(data.nodes[i].name);
    ars.setCustomNameVisible(true);

    dronec.move('pointzero');
  }

  //Build the compartment pickers
  dronec.back(5);
  dronec.right(10);

  for(var j = 0; j <= compartmentList.length; j++){
    material = 86; //pumpkin

    if(j === compartmentList.length){ //Make an 'Everything' block at the end of the list
      var thisName = 'Everything';
    }
    else if(compartmentList[j].name === 'fake compartment'){ //Known to exist in the compartment list, discard
      continue;
    }
    else{
      var thisName = compartmentList[j].name;
    }
    dronec.cuboidX(material, '', 1, 1, 1, true); //Dimensions hardcoded, unlikely to change

    //Create invisible armor stand that displays the node name
    var location = dronec.getLocation() ;
    var ars = location.world.spawnEntity(location, org.bukkit.entity.EntityType.ARMOR_STAND)
    ars.setVisible(false);
    ars.setGravity(false);
    ars.setInvulnerable(true);
    ars.setCustomName(thisName);
    ars.setCustomNameVisible(true);

    dronec.right(3);
  }
}

/**
 * Triggered if plumber does not return valid data for the HTTP request given.
 * Show an error message and a back button using signposts.
 */
function handleError(errdrone){
  echo(errdrone.player, 'Something has gone wrong!');
  errdrone.fwd(5);
  errdrone.signpost(['Something has', 'gone wrong!', 'Right-click']);
  errdrone.right(1);
  errdrone.signpost('HERE');
  errdrone.right(1);
  errdrone.signpost(['to go back', 'to the start.'])
}
Drone.extend(buildMap);

//Turn the above into a command directly invoked from the Minecraft console
function buildNetwork(parameters, player){
  //Move player and invoke the map builder
  telepimp(player);
  var d = new Drone(player);
  d.buildMap(store[player.name]['bioSource'], parameters[0]); //Parameter is the compartment name and is optional
  telepimp(player, 'map');
}
command(buildNetwork);
