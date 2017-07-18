#http://localhost:32908/pathmap?biosource=1363&compartment=mitochondrion

#* @get /pathmap
function(biosource, compartment = NA){
  bioSource <- biosource
  compartmentWanted <- compartment
  source("autoPathMap-simplegrid.R", local = TRUE)
  return(mapOut)
}

#* @get /pathgraph
function(biosource, pathname){
  bioSource <- biosource
  pathName <- pathname
  source("autoPathGraph.R", local = TRUE)
  return(graphOut)
}

#* @get /listplayerfiles
function(player){
  #return(list.files(pattern = paste0("^", player)))
  return(list.files(path = "../cache/", pattern = paste0("^changeData_", player)))
}

#* @get /getplayerfile
function(file){
  library(jsonlite)
  return(fromJSON(paste0("../cache/", file)))
}
