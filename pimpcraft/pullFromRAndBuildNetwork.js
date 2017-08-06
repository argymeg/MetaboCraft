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

function pullFromRAndBuildNetwork(bioSource, compartment){
  pathMapSource = 'http://localhost:32908/pathmap?biosource=' + bioSource + '&mode=' + store[this.player.name]['mapMode'];
  compartmentSource = 'http://localhost:32908/compartmentlist?biosource=' + bioSource;

  var message = 'Showing network map for BioSource: ' + bioSource;
  if(compartment){
    pathMapSource = pathMapSource + '&compartment=' + compartment;
    message += ', compartment: ' + compartment;
  }

  echo(this.player, message);

  startPulling(this);
}

function startPulling(dronea){

  http.request(pathMapSource,
  function(responseCode, responseBody){
    try{
      data = JSON.parse(responseBody);
      pullCompartments(dronea);
    }
    catch(err){
      handleError(dronea);
    }
  });
}
function pullCompartments(droneb){
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
  dronec.chkpt('pointzero');

  /*
    Main node drawing loop!
  */
  for(var i = 0; i < data.nodes.length; i++){

    //Assign material to node types, TODO: pull externally
    var material = 47; //bookshelf
//    var dim = 2;

    //Move drone to node coordinates
    dronec.right(parseInt(data.nodes[i].x));
    dronec.fwd(parseInt(data.nodes[i].z));

    //Draw node as cube of arbitrary dimensions
    dronec.cuboidX(material, '', 1, 2, 1, true);

/*
    dronec.cuboidX(108, Drone.PLAYER_STAIRS_FACING[dronec.dir], 1, 1, 1, true); //brickstairs
    dronec.fwd(1);
    dronec.cuboidX(45, '', 1, 1, 1, true); //brickblock
    dronec.up(1);
    dronec.cuboidX(108, Drone.PLAYER_STAIRS_FACING[dronec.dir], 1, 1, 1, true);
*/

//    dronec.up(Math.floor(dim / 2));
//    dronec.fwd(Math.floor(dim / 2));
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

  dronec.back(5);
  dronec.right(10);

  for(var j = 0; j <= compartmentList.length; j++){
    if(j == compartmentList.length){
      var thisName = 'Everything';
    }
    else if(compartmentList[j].name == 'fake compartment'){
      continue;
    }
    else{
      var thisName = compartmentList[j].name;
    }
    dronec.cuboidX(86, '', 1, 1, 1, true);
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

function handleError(errdrone){
//  console.log(errdrone.getLocation());
//  var playerName = errdrone.getLocation().world.getNearbyEntities(errdrone.getLocation(), 10, 10, 10)[0].getName();
//  console.log(playerName);
//  echo(playerName, 'Something has gone wrong! Right click the box in front of you to go back to the start.');
  echo(errdrone.player, 'Something has gone wrong!');
  errdrone.fwd(5);
  errdrone.signpost(['Something has', 'gone wrong!', 'Right-click']);
  errdrone.right(1);
  errdrone.signpost('HERE');
  errdrone.right(1);
  errdrone.signpost(['to go back', 'to the start.'])
}

Drone.extend(pullFromRAndBuildNetwork);

function buildMap(parameters, player){
  telepimp(player);
  var d = new Drone(player);
  d.pullFromRAndBuildNetwork(store[player.name]['bioSource'], parameters[0]);
  telepimp(player, 'map');
}

command(buildMap);
