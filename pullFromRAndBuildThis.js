var bresenham = require('bresenham-js');
var Drone = require('drone');
var http = require('http');

var data, changeData;

function pullFromRAndBuildThis(){
  startPulling(this);
}

function startPulling(dronea){

  http.request('http://localhost:8080/Rtests/outOfR_argprol.json',
  function(responseCode, responseBody){
    data = JSON.parse(responseBody);
    http.request('http://localhost:8080/Rtests/outOfR_change.json',
    function(responseCode, responseBody){
      changeData = JSON.parse(responseBody);
      actuallyBuild(dronea);
    });
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

    //For now, loop over the entire change file for every metabolite node -
    //will probably not scale too well.
    //Two obvious ways out:
    //1)Split loop into 3 parts: loop over all nodes to assign initial values
    //then over all changed nodes to assign changes
    //then over all nodes again to draw them
    //2)Collate change data with core data in the input -
    //minimise overhead at the expense of flexibility

    if(data.nodes[i].biologicalType === "metabolite"){
      material = 3; //dirt
      dim = 3;
      for(var m = 0; m < changeData.length; m++){
        if(data.nodes[i].localID == changeData[m].localID){
          if(changeData[m].pos == true){
            material = 133; //emerald
          }
          else {
            material = 152; //redstone
          }
        }
      }
    }
    else if(data.nodes[i].biologicalType === "reaction"){
      material = 35; //wool
      dim = 4;
    }
    else if(data.nodes[i].biologicalType === "sideMetabolite"){
      material = 24; //sandstone
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
    droneb.wallsign(data.nodes[i].chemName); //Not needed any more, keeping for debugging

    //Create invisible armor stand that displays the node name
    droneb.up(Math.floor(dim / 2));
    droneb.fwd(Math.floor(dim / 2));
    var location = droneb.getLocation() ;
    var ars = location.world.spawnEntity(location, org.bukkit.entity.EntityType.ARMOR_STAND)
    ars.setVisible(false);
    ars.setGravity(false);
    ars.setInvulnerable(true);
    ars.setCustomName(data.nodes[i].chemName);
    ars.setCustomNameVisible(true);

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
