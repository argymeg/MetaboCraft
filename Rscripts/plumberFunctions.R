#A script defining a plumber "router" and the five valid requests to plumber

#Takes a BioSource, a compartment and a mode as options, returns a pathway network map.
#* @get /pathmap
function(biosource, compartment = NA, mode = "forcedirected"){
  bioSource <- biosource
  compartmentWanted <- compartment
  mapMode <- mode
  source("networkMap.R", local = TRUE)
  return(mapOut)
}

#Takes a BioSource and a pathway name as options, returns a pathway graph
#* @get /pathgraph
function(biosource, pathname){
  bioSource <- biosource
  pathName <- pathname
  source("pathwayGraph.R", local = TRUE)
  return(graphOut)
}

#Takes a player name as option, returns a list of files uploaded by player
#* @get /listplayerfiles
function(player){
  #return(list.files(pattern = paste0("^", player)))
  return(list.files(path = "../cache/", pattern = paste0("^userData_", player)))
}

#Takes a file name as option, returns the file as-is from cache ()
#* @get /getplayerfile
function(file){
  library(jsonlite)
  return(fromJSON(paste0("../cache/", file)))
}

#Takes a BioSource as option, returns the compartment list.
#Uses the same caching mechanism as pathwayGraph.R and networkMap.R scripts.
#* @get /compartmentlist
function(biosource){
  compartmentListOutSink <- paste0("../cache/compartmentList_",biosource,".json")
  if(file.exists(compartmentListOutSink)){
    compartmentListSource <- compartmentListOutSink
    compartmentList <- fromJSON(compartmentListSource)
  } else {
    compartmentListSource <- paste0("http://metexplore.toulouse.inra.fr:8080/metExploreWebService/biosources/",biosource,"/Compartment")
    compartmentList <- fromJSON(compartmentListSource)
    write_json(compartmentList, compartmentListOutSink, pretty = TRUE)
  }
  return(compartmentList)
}
