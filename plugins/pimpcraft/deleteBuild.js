/*
Trace over the build routine again, replacing everything with air,
effectively deleting the build
!!!MAJOR TODO!!!: Make drone location persistent!
For now this only works if player doesn't move at all after building.
Also, it gives a /very/ weird Java error otherwise...
*/
/*
I swear to god, cross-my-heart-and-hope-to-die, this is the exact same
code that worked an hour ago. Somehow it doesn't anymore. Location is stored in JSON and passed over,
but after starting at the same points SOMEHOW the two drones DIVERGE!!!!!!!!!!!!!!!
Giving up on this for now. At any rate, persistence doesn't work unless you refresh scriptcraft
(and that's by design), which makes the whole think impractical.
Revisit when it's time to merge builder and bulldozer. Should be more straightforward then.
*/
/*
Update a few minutes later: I don't know what that says about my sanity,
but it works now.
Still, revisit at merge.
Alternative if I decide not to merge scripts: implement a barebones "module"
that just holds information.
*/
var bresenham = require('bresenham-js');
var Drone = require('drone');
var http = require('http');
var utils = require('utils');
var droneCheck = persist('droneCheck',{});
var data;

var dataSource = 'http://localhost:8080/outOfR_argprol.json';


function deleteBuild(){
  startPulling(this);
}

function startPulling(dronea){

  http.request(dataSource,
  function(responseCode, responseBody){
    data = JSON.parse(responseBody);
    actuallyBuild(dronea);
  });
}

function actuallyBuild(droneb){
  droneb.move(utils.locationFromJSON(droneCheck.startPoint));
  droneb.chkpt('pointzero');

  /*
    Main node removal loop!
  */
  for(var i = 0; i < data.nodes.length; i++){

    var material = 0; //air
    var dim;

    if(data.nodes[i].biologicalType === "metabolite"){
      dim = 3;
    }
    else if(data.nodes[i].biologicalType === "reaction"){
      dim = 4;
    }
    else if(data.nodes[i].biologicalType === "sideMetabolite"){
      dim = 2;
    }
    else{
      echo('Undefined node type!');
      throw 'Undefined node type!';
    }

    //Move drone to node coordinates
    droneb.right(parseInt(data.nodes[i].x));
    droneb.up(parseInt(data.nodes[i].y));
    droneb.fwd(parseInt(data.nodes[i].z));

    //Draw node (air equivalent) as cube of arbitrary dimensions
    droneb.cuboidX(material, '', dim, dim, dim, true);

    //Remove armor stand
    droneb.up(Math.floor(dim / 2));
    droneb.fwd(Math.floor(dim / 2));
    var location = droneb.getLocation() ;
    location.world.getNearbyEntities(location, 1, 1, 1)[0].remove(); //Comment this to make the drone do its route for debugging

    droneb.move('pointzero');
  }

  /*
    Main edge removal loop!
  */
  for(var j = 0; j < data.edges.length; j++){

    var reMat = 0; //air

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

Drone.extend(deleteBuild);

function deletePath(parameters, player){
  var d = new Drone(player);
  d.deleteBuild();
}

command(deletePath);
