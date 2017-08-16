/**
 * Build an individual pathway graph.
 * Must implement as a method extending the Drone object.
 * But also, the actual build routine must only run after the HTTP requests
 * (which run asynchronously) return their results.
 * To that end, we break the code into functions, and pass the reference
 * to the Drone object (which is "this" in the first function) along to the next
 * function each time, with a different identifier.
 */
var bresenham = require('bresenham-js');
var Drone = require('drone');
var http = require('http');
var utils = require('utils');
var store = require('storage');
var telepimp = require('telepimp');
var data, userData;
var dataSource, userDataSource;

function buildGraph(bioSource, pathName, playerName){
  userDataSource = null; //Otherwise it uses userData from the last run
  userData = null;

  echo(this.player, "Showing pathway: " + pathName);

  pathName = pathName.replace(/ /g, "%20");
  dataSource = 'http://localhost:32908/pathgraph?biosource=' + bioSource + '&pathname=' + pathName;

  if(store[playerName]['userDataEnabled']){
    userDataSource = 'http://localhost:32908/getplayerfile?file=' + store[playerName]['currentFile'];
  }
  getData(this);
}

function getData(dronea){
  //Get the pathway graph coordinates from plumber
  http.request(dataSource,
    function(responseCode, responseBody){
      try{
        data = JSON.parse(responseBody);
        //Get the changed nodes data from plumber - only if display is enabled!
        if(userDataSource){
          http.request(userDataSource,
            function(responseCode, responseBody){
              try{
                userData = JSON.parse(responseBody);
                startBuild(dronea);
              }
              catch(err){
                handleError(dronea);
              }
            }
          );
        }
        else{
          startBuild(dronea);
        }
      }
      catch(err){
        handleError(dronea);
      }
    }
  );
}

function startBuild(droneb){
  droneb.chkpt('pointzero');

  //Build the "back to map" signpost in an immediately visible spot
  droneb.fwd(5);
  droneb.signpost('Back to map');
  droneb.back(5);

  buildEdges(droneb);
  buildNodes(droneb);

}

function buildNodes(dronec){
  for(var i = 0; i < data.nodes.length; i++){
    /**
     * Assign materials and dimensions to each node depending on type.
     * Loop over the entire change file for every metabolite node -
     * not necessarily the most efficient way. Potential alternative:
     * Split loop into 3 parts: loop over all nodes to assign initial values
     * then over all changed nodes to assign changes
     * then over all nodes again to draw them
     */
    var material, meta, dim;
    if(data.nodes[i].biologicalType === "metabolite"){
      material = 35; //wool
      meta = 7; //gray
      dim = 3;
      if(userData){
        for(var m = 0; m < userData.length; m++){
          if(data.nodes[i].inchikey === userData[m].ink){
            if(userData[m].pos === true){
              meta = 11; //blue
            }
            else {
              meta = 14; //red
            }
          }
        }
      }
    }
    else if(data.nodes[i].biologicalType === "reaction"){
      material = 89; //glowstone
      dim = 4;
    }
    else if(data.nodes[i].biologicalType === "sideMetabolite"){
      material = 35; //wool
      meta = 0; //white
      dim = 2;
    }
    else{
      //This should absolutely never happen in normal use -
      //would show something's going wrong in the backend!
      echo('Undefined node type!');
      throw 'Undefined node type!';
    }

    //Move drone to node coordinates
    dronec.right(parseInt(data.nodes[i].x));
    dronec.up(parseInt(data.nodes[i].y));
    dronec.fwd(parseInt(data.nodes[i].z));

    //Draw node as cube of arbitrary dimension - dim
    //'true' is an internal parameter of the cuboidX drone method
    dronec.cuboidX(material, meta, dim, dim, dim, true);

    //Create invisible armor stand that displays the node name
    dronec.up(dim - 1);
    dronec.fwd(Math.floor(dim / 2));
    var location = dronec.getLocation() ;
    var ars = location.world.spawnEntity(location, org.bukkit.entity.EntityType.ARMOR_STAND)
    ars.setVisible(false);
    ars.setGravity(false);
    ars.setInvulnerable(true);
    ars.setCustomName(data.nodes[i].chemName);
    ars.setCustomNameVisible(true);

    dronec.move('pointzero');
  }
}

function buildEdges(droned){
  for(var j = 0; j < data.edges.length; j++){

    //Assign material to edge types
    var material, meta;
    if(data.edges[j].linkType === "in"){
      material = 35; //wool
      meta = 6; //pink
    }
    else if(data.edges[j].linkType === "out"){
      material = 35; //wool
      meta = 5; //green
    }
    else{
      //This should absolutely never happen in normal use -
      //would show something's going wrong in the backend!
      echo('Undefined edge type!');
      throw 'Undefined edge type!';
    }

    //Set start and end coordinates for this edge
    var frontx, fronty, backx, backy, frontz, backz, nDim;
    for (var k = 0; k < data.nodes.length; k++){
      if(data.edges[j].to === data.nodes[k].localID){
        frontx = parseInt(data.nodes[k].x);
        fronty = parseInt(data.nodes[k].y);
        frontz = parseInt(data.nodes[k].z);
      }
      else if(data.edges[j].from === data.nodes[k].localID){
        backx = parseInt(data.nodes[k].x);
        backy = parseInt(data.nodes[k].y);
        backz = parseInt(data.nodes[k].z);

        if(data.nodes[k].biologicalType === "metabolite"){
          nDim = 3;
        }
        else if(data.nodes[k].biologicalType === "reaction"){
          nDim = 4;
        }
        else if(data.nodes[k].biologicalType === "sideMetabolite"){
          nDim = 2;
        }

        //Attempt to resolve inaccuracies in edge placement resulting from
        //blockiness. Further improvements likely possible.
        if(frontx - backx > nDim){
          backx += nDim;
        }
        else if(backx - frontx > nDim){
          frontx += nDim;
        }
        if(fronty - backy > nDim){
          backy += nDim;
        }
        else if (backy - fronty > nDim){
          fronty += nDim;
        }
        if(frontz - backz > nDim){
          backz += nDim
        }
        else if (backz - frontz > nDim){
          frontz += nDim;
        }
      }
    }

    //Calculate exact coordinates for edge using bresenham
    var points = bresenham([backx, backy, backz], [frontx, fronty, frontz]);

    //Build the edge block by block, using given coordinates
    for(var l = 0; l < points.length - 1; l++){
      droned.move('pointzero');
      droned.right(points[l][0]);
      droned.up(points[l][1]);
      droned.fwd(points[l][2]);
      droned.cuboidX(material, meta, 1, 1, 1, true);
    }
    droned.move('pointzero');
  }
}

/**
 * Triggered if plumber does not return valid data for the HTTP request given.
 * Show an error message and a back button using signposts.
 */
function handleError(errdrone){
  echo(errdrone.player, 'Something has gone wrong!');
  errdrone.fwd(3);
  errdrone.right(3);
  errdrone.signpost(['Something has', 'gone wrong!', 'Right-click']);
  errdrone.right(1);
  errdrone.signpost('HERE');
  errdrone.right(1);
  errdrone.signpost(['to go back', 'to the start.'])
}

Drone.extend(buildGraph);

//Turn the above into a command directly invoked from the Minecraft console
function buildPath(parameters, player){

  //Join any number of arguments into a single string, assumed to be a pathway name
  var pathNameBuilder = '';
  for(var n = 0; n < parameters.length; n++){
    pathNameBuilder += parameters[n] + ' '
  }
  pathNameBuilder = pathNameBuilder.substr(0, pathNameBuilder.length - 1)

  //Move player and invoke the graph builder
  telepimp(player);
  var d = new Drone(player);
  d.buildGraph(store[player.name]['bioSource'], pathNameBuilder, player.name);
  telepimp(player, 'graph');
}
command(buildPath);
