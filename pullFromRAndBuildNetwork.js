/*
Build metabolic network map
Will do for now but far too much code duplication!
Should be merged with the pathway builder
(and possibly the deleter as well)
*/

var bresenham = require('bresenham-js');
var Drone = require('drone');
var http = require('http');

var data;

function pullFromRAndBuildNetwork(){
  startPulling(this);
}

function startPulling(dronea){

  http.request('http://localhost:8080/Rtests/outOfR_pathMap.json',
  function(responseCode, responseBody){
    data = JSON.parse(responseBody);
    actuallyBuild(dronea);
  });
}

function actuallyBuild(droneb){
  droneb.chkpt('pointzero');

  /*
    Main node drawing loop!
  */
  for(var i = 0; i < data.nodes.length; i++){

    //Assign material to node types, TODO: pull externally
    var material = 152; //redstone
    var dim = 2;

    //Move drone to node coordinates
    droneb.right(parseInt(data.nodes[i].x));
    droneb.fwd(parseInt(data.nodes[i].z));

    //Draw node as cube of arbitrary dimensions
    droneb.cuboidX(material, '', dim, dim, dim, true);
    //droneb.wallsign(data.nodes[i].chemName);
    droneb.move('pointzero');
  }

  /*
    Main edge drawing loop!
  */
  for(var j = 0; j < data.edges.length; j++){

    //Assign material to edge types, TODO: pull externally
    var reMat = 22; //blue

    //Set start and end coordinates for this edge
    var frontx, backx, frontz, backz;
    for (var k = 0; k < data.nodes.length; k++){
      if(data.edges[j].to === data.nodes[k].name){
        frontx = parseInt(data.nodes[k].x);
        frontz = parseInt(data.nodes[k].z);
      }
      else if(data.edges[j].from === data.nodes[k].name){
        backx = parseInt(data.nodes[k].x);
        backz = parseInt(data.nodes[k].z);

        var nDim = 2;

        //Must do something in the in between cases, bring coords as close
        //to reality as possible
        if(frontx - backx > nDim){
          backx += nDim;
        }
        else if(backx - frontx > nDim){
          frontx += nDim;
        }
        if(frontz - backz > nDim){
          backz += nDim
        }
        else if (backz - frontz > nDim){
          frontz += nDim;
        }
      }
    }

    var points = bresenham([backx, backz], [frontx, frontz]);
    for(var l = 0; l < points.length - 1; l++){
      droneb.move('pointzero');
      droneb.right(points[l][0]);
      droneb.fwd(points[l][1]);
      droneb.cuboidX(reMat, '', 1, 1, 1, true);
    }


    droneb.move('pointzero');
  }
}

Drone.extend(pullFromRAndBuildNetwork);
