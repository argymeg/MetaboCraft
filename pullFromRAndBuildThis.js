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
      material = 3; //dirt
      dim = 3;
    }
    else if(data.nodes[i].biologicalType === "reaction"){
      material = 35; //wool
      dim = 4;
    }
    else if(data.nodes[i].biologicalType === "sideMetabolite"){
      material = 152; //redstone
      dim = 2;
    }
    else{
      echo('Undefined node type!');
      throw 'Undefined node type!';
    }
    /*
    //Unused types
    else if(data.nodes[i].type === "yellow"){
      material = 41;
    }
    */

    //Move drone to node coordinates
    droneb.right(parseInt(data.nodes[i].x));
    droneb.up(parseInt(data.nodes[i].y));
    droneb.fwd(parseInt(data.nodes[i].z));

    //Draw node as cube of arbitrary dimensions
    droneb.cuboidX(material, '', dim, dim, dim, true);
    droneb.wallsign(data.nodes[i].chemName);
    droneb.move('pointzero');
  }

  /*
    Main edge drawing loop!
  */
  for(var j = 0; j < data.edges.length; j++){

    //Assign material to edge types, TODO: pull externally
    var reMat;

    if(data.edges[j].linkType === "in"){
      reMat = 22; //blue
    }
    else if(data.edges[j].linkType === "out"){
      reMat = 201; //purple
    }
    else{
      echo('Undefined edge type!');
      throw 'Undefined edge type!';
    }
    /*
    //Unused types
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

        if(data.nodes[k].biologicalType === "metabolite"){
          backx += 3;
          backy += 3;
          backz += 3;
        }
        else if(data.nodes[k].biologicalType === "reaction"){
          backx += 4;
          backy += 4;
          backz += 4;
        }
        else if(data.nodes[k].biologicalType === "sideMetabolite"){
          backx += 2;
          backy += 2;
          backz += 2;
        }
      }
    }

    var points = bresenham([backx, backy, backz], [frontx, fronty, frontz]);
    for(var l = 0; l < points.length - 1; l++){
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
