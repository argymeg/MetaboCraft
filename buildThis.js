var bresenham = require('bresenham-js');
var Drone = require('drone');

//Placeholder imaginary data, TODO: pull externally
//Current assumption, first node in the graph is 0,0,0. Will that scale?
var data = {molecules:[],reactions:[]};
data.molecules.push({name:"caffeine",type:"brown",x:0,y:0,z:0});
data.molecules.push({name:"atropine",type:"white",x:10,y:0,z:0});
data.molecules.push({name:"holine",type:"red",x:10,y:15,z:0});
data.molecules.push({name:"valine",type:"yellow",x:6,y:10,z:10});

data.reactions.push({from:"caffeine",to:"atropine",type:"blue"});
data.reactions.push({from:"caffeine",to:"holine",type:"purple"});
data.reactions.push({from:"atropine",to:"holine",type:"grey"});
data.reactions.push({from:"atropine",to:"valine",type:"purple"});
data.reactions.push({from:"holine",to:"valine",type:"blue"});

function buildThis(){

  this.chkpt('pointzero');

  /*
    Main node drawing loop!
  */
  for(var i = 0; i < data.molecules.length; i++){

    //Assign material to node types, TODO: pull externally
    var material;
    if(data.molecules[i].type === "brown"){
      material = 3;
    }
    else if(data.molecules[i].type === "white"){
      material = 35;
    }
    else if(data.molecules[i].type === "red"){
      material = 152;
    }
    else if(data.molecules[i].type === "yellow"){
      material = 41;
    }

    //Move drone to node coordinates
    this.right(data.molecules[i].x);
    this.up(data.molecules[i].y);
    this.fwd(data.molecules[i].z);

    //Draw node as 3x3x3 cube
    this.cuboidX(material, '', 3, 3, 3, true);
    this.move('pointzero');
  }

  /*
    Main edge drawing loop!
  */
  for(var j = 0; j < data.reactions.length; j++){
    var reMat;

    //Assign material to edge types, TODO: pull externally
    if(data.reactions[j].type === "blue"){
      reMat = 22;
    }
    else if(data.reactions[j].type === "purple"){
      reMat = 201;
    }
    else if(data.reactions[j].type === "grey"){
      reMat = 1;
    }

    //Set start and end coordinates for this edge
    var frontx, fronty, backx, backy, frontz, backz;
    for (var k = 0; k < data.molecules.length; k++){
      if(data.reactions[j].to === data.molecules[k].name){
        frontx = data.molecules[k].x;
        fronty = data.molecules[k].y;
        frontz = data.molecules[k].z;
      }
      else if(data.reactions[j].from === data.molecules[k].name){
        backx = data.molecules[k].x;
        backy = data.molecules[k].y;
        backz = data.molecules[k].z;
      }
    }

    //Draw edge as a whole if it is a straight line
    //Otherwise call bresenham and draw block by block
    //Adds complexity but is probably measurably cheaper. Revisit.
    if((frontx - backx === 0) && (fronty - backy === 0)){
      this.move('pointzero');
      this.right(backx).up(backy).fwd(backz + 3);
      this.cuboidX(reMat, '', 1, 1, frontz - backz - 3, true);
    }
    else if ((frontx - backx === 0) && (frontz - backz === 0)) {
      this.move('pointzero');
      this.right(backx).up(backy + 3).fwd(backz);
      this.cuboidX(reMat, '', 1, fronty - backy - 3, 1, true);
    }
    else if ((fronty - backy === 0) && (frontz - backz === 0)) {
      this.move('pointzero');
      this.right(backx + 3).up(backy).fwd(backz);
      this.cuboidX(reMat, '', frontx - backx - 3, 1, 1, true);
    }
    else{
      var points = bresenham([backx, backy, backz], [frontx, fronty, frontz]);
      for(var l = 3; l < points.length - 1; l++){
        this.move('pointzero');
        this.right(points[l][0]);
        this.up(points[l][1]);
        this.fwd(points[l][2]);
        this.cuboidX(reMat, '', 1, 1, 1, true);
      }
    }
    this.move('pointzero')
  }
}
Drone.extend(buildThis);
