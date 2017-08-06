var bresenham = require('bresenham-js');
var Drone = require('drone');
var http = require('http');
var utils = require('utils');
var store = require('storage');
var telepimp = require('telepimp');
var droneCheck = persist('droneCheck',{});
var data, userData;
var dataSource, userDataSource;

function pullFromRAndBuildThis(bioSource, pathName, playerName){
  userDataSource = null; //Otherwise it uses userData from the last run
  userData = null;

  echo(this.player, "Showing pathway: " + pathName);

  pathName = pathName.replace(/ /g, "%20");
  dataSource = 'http://localhost:32908/pathgraph?biosource=' + bioSource + '&pathname=' + pathName;

  if(store[playerName]['userDataEnabled']){
    userDataSource = 'http://localhost:32908/getplayerfile?file=' + store[playerName]['currentFile'];
  }
  startPulling(this);
}

function startPulling(dronea){
  http.request(dataSource,
    function(responseCode, responseBody){
      try{
        data = JSON.parse(responseBody);
        if(userDataSource){
          http.request(userDataSource,
            function(responseCode, responseBody){
              try{
                userData = JSON.parse(responseBody);
                actuallyBuild(dronea);
              }
              catch(err){
                handleError(dronea);
              }
            }
          );
        }
        else{
          actuallyBuild(dronea);
        }
      }
      catch(err){
        handleError(dronea);
      }
    }
  );
}

function actuallyBuild(droneb){
  droneCheck.startPoint = utils.locationToJSON(droneb.getLocation());
  droneb.chkpt('pointzero');

  droneb.fwd(5);
  droneb.signpost('Back to map');
  droneb.back(5);

  buildEdges(droneb);
  buildNodes(droneb);

}

function buildNodes(dronec){
  /*
    Main node drawing loop!
  */
  for(var i = 0; i < data.nodes.length; i++){

    //Assign material to node types, TODO: pull externally
    var material, dim, meta;

    //Loop over the entire change file for every metabolite node -
    //not necessarily the most efficient way. Potential alternative:
    //Split loop into 3 parts: loop over all nodes to assign initial values
    //then over all changed nodes to assign changes
    //then over all nodes again to draw them

    if(data.nodes[i].biologicalType === "metabolite"){
      material = 35; //dirt
      dim = 3;
      meta = 7;
      if(userData){
        for(var m = 0; m < userData.length; m++){
          if(data.nodes[i].inchikey == userData[m].ink){
            if(userData[m].pos == true){
              material = 35; //wool
              meta = 11; //blue
            }
            else {
              material = 35; //wool
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
      dim = 2;
      meta = 0; //white
    }
    else{
      echo('Undefined node type!');
      throw 'Undefined node type!';
    }

    //Move drone to node coordinates
    dronec.right(parseInt(data.nodes[i].x));
    dronec.up(parseInt(data.nodes[i].y));
    dronec.fwd(parseInt(data.nodes[i].z));

    //Draw node as cube of arbitrary dimensions
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
  /*
    Main edge drawing loop!
  */
  for(var j = 0; j < data.edges.length; j++){

    //Assign material to edge types, TODO: pull externally
    var reMat, meta;

    if(data.edges[j].linkType === "in"){
      reMat = 35; //wool
      meta = 6; //pink
    }
    else if(data.edges[j].linkType === "out"){
      reMat = 35; //wool
      meta = 5; //green
    }
    else{
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

        //Must do something in the in between cases, bring coords as close
        //to reality as possible
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

    var points = bresenham([backx, backy, backz], [frontx, fronty, frontz]);
    for(var l = 0; l < points.length - 1; l++){
      droned.move('pointzero');
      droned.right(points[l][0]);
      droned.up(points[l][1]);
      droned.fwd(points[l][2]);
      droned.cuboidX(reMat, meta, 1, 1, 1, true);
    }


    droned.move('pointzero');
  }
}

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

Drone.extend(pullFromRAndBuildThis);

function buildPath(parameters, player){
  var pathNameBuilder = '';
  for(var n = 0; n < parameters.length; n++){
    pathNameBuilder += parameters[n] + ' '
  }
  pathNameBuilder = pathNameBuilder.substr(0, pathNameBuilder.length - 1)

  telepimp(player);
  var d = new Drone(player);
  d.pullFromRAndBuildThis(store[player.name]['bioSource'], pathNameBuilder, player.name);
  telepimp(player, 'graph');
}

command(buildPath);
