var bresenham = require('bresenham-js');
var Drone = require('drone');
var http = require('http');

var nodes;
var edges;

function pullAndBuildThis(){
  startPulling(this);
}

function startPulling(dronea){

  http.request('http://localhost:8080/nodes.json',
  function(responseCode, responseBody){
    nodes = JSON.parse(responseBody);
    console.log(typeof(nodes));
    keepPulling(dronea);
  });
}

function keepPulling(droneb){

  console.log(typeof(nodes));
  http.request('http://localhost:8080/edges.json',
  function(responseCode, responseBody){
    edges = JSON.parse(responseBody);
    actuallyBuild(droneb);
  });

}

function actuallyBuild(dronec){
  dronec.chkpt('pointzero');

  /*
    Main node drawing loop!
  */
  for(var i = 0; i < nodes.length; i++){

    //Assign material to node types, TODO: pull externally
    var material;
    if(nodes[i].type === "brown"){
      material = 3;
    }
    else if(nodes[i].type === "white"){
      material = 35;
    }
    else if(nodes[i].type === "red"){
      material = 152;
    }
    else if(nodes[i].type === "yellow"){
      material = 41;
    }

    //Move drone to node coordinates
    dronec.right(nodes[i].x);
    dronec.up(nodes[i].y);
    dronec.fwd(nodes[i].z);

    //Draw node as 2x2x2 cube
    dronec.cuboidX(material, '', 2, 2, 2, true);
    dronec.wallsign(nodes[i].name);
    dronec.move('pointzero');
  }

  /*
    Main edge drawing loop!
  */
  for(var j = 0; j < edges.length; j++){
    var reMat;

    //Assign material to edge types, TODO: pull externally
    if(edges[j].type === "blue"){
      reMat = 22;
    }
    else if(edges[j].type === "purple"){
      reMat = 201;
    }
    else if(edges[j].type === "grey"){
      reMat = 1;
    }

    //Set start and end coordinates for this edge
    var frontx, fronty, backx, backy, frontz, backz;
    for (var k = 0; k < nodes.length; k++){
      if(edges[j].to === nodes[k].name){
        frontx = nodes[k].x;
        fronty = nodes[k].y;
        frontz = nodes[k].z;
      }
      else if(edges[j].from === nodes[k].name){
        backx = nodes[k].x;
        backy = nodes[k].y;
        backz = nodes[k].z;
      }
    }

    //Draw edge as a whole if it is a straight line
    //Otherwise call bresenham and draw block by block
    //Adds complexity but is probably measurably cheaper. Revisit.
    if((frontx - backx === 0) && (fronty - backy === 0)){
      dronec.move('pointzero');
      dronec.right(backx).up(backy).fwd(backz + 2);
      dronec.cuboidX(reMat, '', 1, 1, frontz - backz - 2, true);
    }
    else if ((frontx - backx === 0) && (frontz - backz === 0)) {
      dronec.move('pointzero');
      dronec.right(backx).up(backy + 2).fwd(backz);
      dronec.cuboidX(reMat, '', 1, fronty - backy - 2, 1, true);
    }
    else if ((fronty - backy === 0) && (frontz - backz === 0)) {
      dronec.move('pointzero');
      dronec.right(backx + 2).up(backy).fwd(backz);
      dronec.cuboidX(reMat, '', frontx - backx - 2, 1, 1, true);
    }
    else{
      var points = bresenham([backx, backy, backz], [frontx, fronty, frontz]);
      for(var l = 2; l < points.length - 1; l++){
        dronec.move('pointzero');
        dronec.right(points[l][0]);
        dronec.up(points[l][1]);
        dronec.fwd(points[l][2]);
        dronec.cuboidX(reMat, '', 1, 1, 1, true);
      }
    }
    dronec.move('pointzero');
  }
}

Drone.extend(pullAndBuildThis);
