var bresenham = require('bresenham-js');

var data = {molecules:[],reactions:[]};
data.molecules.push({name:"caffeine",type:"brown",x:0,y:0});
data.molecules.push({name:"atropine",type:"white",x:10,y:0});
data.molecules.push({name:"holine",type:"red",x:10,y:15});

data.reactions.push({from:"caffeine",to:"atropine",type:"blue"});
data.reactions.push({from:"caffeine",to:"holine",type:"purple"});
data.reactions.push({from:"atropine",to:"holine",type:"grey"})

function buildThis(){

  this.chkpt('pointzero');
  for(var i = 0; i < data.molecules.length; i++){

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

    this.right(data.molecules[i].x);
    this.up(data.molecules[i].y);

    this.box(material,2,2,2);
    this.move('pointzero');
  }

  for(var j = 0; j < data.reactions.length; j++){
    var reMat;
    if(data.reactions[j].type === "blue"){
      reMat = 22;
    }
    else if(data.reactions[j].type === "purple"){
      reMat = 201;
    }
    else if(data.reactions[j].type === "grey"){
      reMat = 1;
    }

    var frontx, fronty, backx, backy;

    for (var k = 0; k < data.molecules.length; k++){
      if(data.reactions[j].to === data.molecules[k].name){
        frontx = data.molecules[k].x;
        fronty = data.molecules[k].y;
      }
      else if(data.reactions[j].from === data.molecules[k].name){
        backx = data.molecules[k].x;
        backy = data.molecules[k].y;
      }
    }

    var points = bresenham([backx, backy], [frontx,fronty]);
    for(var l = 0; l < points.length; l++){
      this.move('pointzero');
      this.right(points[l][0]);
      this.up(points[l][1]);
      this.box(reMat);
    }
    this.move('pointzero')
  }
}
var Drone = require('drone');
Drone.extend(buildThis);


//    this.right(backx);
//    this.up(backy);
//    var xDist = frontx - backx;
//    var yDist = fronty - backy;
//    var slope = yDist - xDist;

/*
    for(var l = 0 ; l < frontx - backx; l++){
      this.box(reMat);
      this.right(1);
    }
    for(var m = 0 ; m < fronty - backy; m++){
      this.box(reMat);
      this.up(1);
    }
*/

/*

    var maxDimension = Math.max(xDist,yDist);

    for(var n = 0; n < maxDimension; n++)
    {
      this.box(reMat);
      if(xDist > 0){
        this.right(1);
        xDist--;
      }
      if(yDist > 0){
        this.up(1);
        yDist--;
      }
    }
*/


/*
    if(xDist > yDist){
      var chunkSize = Math.floor(1 + (xDist / (yDist + 1)));
      for (var o = 0; o < xDist / chunkSize; o++){
        for(var p = 0; p < chunkSize; p++){
          this.box(reMat);
          this.right(1);
        }
        this.box(reMat);
        this.up(1);
      }
    }
    else {
      var chunkSize = Math.floor((yDist / (xDist + 1)));
      for (var o = 0; o < yDist / chunkSize; o++){
        for(var p = 0; p < chunkSize; p++){
          this.box(reMat);
          this.up(1);
          echo('gone up!' + p);
        }
        this.box(reMat);
        this.right(1);
        echo('went right!' + o)
      }
    }
*/
