var bresenham = require('bresenham-js');
var Drone = require('drone');
var http = require('http');

var data;

function pullFromRAndBuildThis(){
  startPulling(this);
}

function startPulling(dronea){

  http.request('http://localhost:8080/Rtests/outOfR6.json',
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
    var material, dim;
    if(data.nodes[i].biologicalType === "metabolite"){
      material = 3;
      dim = 2;
    }
    else if(data.nodes[i].biologicalType === "reaction"){
      material = 35;
      dim = 3;
    }

    //Unused types
    /*
    else if(data.nodes[i].type === "red"){
      material = 152;
    }
    else if(data.nodes[i].type === "yellow"){
      material = 41;
    }
    */
    //Move drone to node coordinates
    droneb.right(parseInt(data.nodes[i].x));
    droneb.up(parseInt(data.nodes[i].y));
    droneb.fwd(parseInt(data.nodes[i].z));

    //Draw node as 2x2x2 cube
    droneb.cuboidX(material, '', dim, dim, dim, true);
    droneb.wallsign(data.nodes[i].chemName);
    droneb.move('pointzero');
  }

  /*
    Main edge drawing loop!
  */
  for(var j = 0; j < data.edges.length; j++){

    //Hardcode materials for now
    var reMat = 1;

    /*
    var reMat;

    //Assign material to edge types, TODO: pull externally
    if(data.edges[j].type === "blue"){
      reMat = 22;
    }
    else if(data.edges[j].type === "purple"){
      reMat = 201;
    }
    else if(data.edges[j].type === "grey"){
      reMat = 1;
    }
    */

    //Set start and end coordinates for this edge
    var frontx, fronty, backx, backy, frontz, backz;
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
      }
    }

    var points = bresenham([backx, backy, backz], [frontx, fronty, frontz]);
    for(var l = 2; l < points.length - 1; l++){
      droneb.move('pointzero');
      droneb.right(points[l][0]);
      droneb.up(points[l][1]);
      droneb.fwd(points[l][2]);
      droneb.cuboidX(reMat, '', 1, 1, 1, true);
    }


    droneb.move('pointzero');
  }
}

Drone.extend(pullFromRAndBuildThis);

//Removed for now to make life easier
/*
//Draw edge as a whole if it is a straight line
//Otherwise call bresenham and draw block by block
//Adds complexity but is probably measurably cheaper. Revisit.
//UPDATE 01/06: in real data probably very few edges will be straight
//Shortlist for removal after settling on plotting algorithm.
if((frontx - backx === 0) && (fronty - backy === 0)){
  droneb.move('pointzero');
  droneb.right(backx).up(backy).fwd(backz + 3);
  droneb.cuboidX(reMat, '', 1, 1, frontz - backz - 3, true);
}
else if ((frontx - backx === 0) && (frontz - backz === 0)) {
  droneb.move('pointzero');
  droneb.right(backx).up(backy + 3).fwd(backz);
  droneb.cuboidX(reMat, '', 1, fronty - backy - 3, 1, true);
}
else if ((fronty - backy === 0) && (frontz - backz === 0)) {
  droneb.move('pointzero');
  droneb.right(backx + 3).up(backy).fwd(backz);
  droneb.cuboidX(reMat, '', frontx - backx - 3, 1, 1, true);
}
else{
  var points = bresenham([backx, backy, backz], [frontx, fronty, frontz]);
  for(var l = 3; l < points.length - 1; l++){
    droneb.move('pointzero');
    droneb.right(points[l][0]);
    droneb.up(points[l][1]);
    droneb.fwd(points[l][2]);
    droneb.cuboidX(reMat, '', 1, 1, 1, true);
  }
}
*/
