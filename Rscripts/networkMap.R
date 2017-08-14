#Generate a pathway network map
#The following variables (<- example value) must be set in the environment before sourcing this script:
#bioSource (<- 4324)
#compartmentWanted (<- "mitochondrion")
#mapMode (<- "forcedirected") #Defaults to forcedirected if not set

library("igraph")
library("jsonlite")

if(!exists("mapMode") || mapMode != "alphabetical"){
  mapMode <- "forcedirected"
}

#Check cache for network map
mapOutSink = paste0("../cache/pathMap_",bioSource,"_", gsub("/","--", compartmentWanted, fixed = TRUE), "_", mapMode, ".json")
if(file.exists(mapOutSink)){
  mapOut <- fromJSON(mapOutSink)
} else {
  excludedPaths <- c("Unassigned","Miscellaneous")

  pathwayListOutSink = paste0("../cache/pathwayList_",bioSource,".json")
  metaboliteListOutSink = paste0("../cache/metaboliteList_",bioSource,".json")

  #Check cache for pathway list and metabolite list
  if(file.exists(pathwayListOutSink)){
    pathwayListSource <- pathwayListOutSink
    pathList <- fromJSON(pathwayListSource)
  } else {
    pathwayListSource <- paste0("http://metexplore.toulouse.inra.fr:8080/metExploreWebService/biosources/",bioSource,"/pathways")
    pathList <- fromJSON(pathwayListSource)
    write_json(pathList, pathwayListOutSink, pretty = TRUE)
  }
  if(file.exists(metaboliteListOutSink)){
    metaboliteListSource <- metaboliteListOutSink
    metList <- fromJSON(metaboliteListSource)$nodes
  } else {
    metaboliteListSource <- paste0("http://metexplore.toulouse.inra.fr:8080/metExploreWebService/graph/",bioSource)
    metList <- fromJSON(metaboliteListSource)$nodes
    write_json(list(nodes = metList), metaboliteListOutSink, pretty = TRUE)
  }

  pathList <- pathList[-which(pathList$name == excludedPaths),]

  #Limit selection to compartment if value is not NA
  if(!is.na(compartmentWanted)){
    metList <- metList[metList$compartment == compartmentWanted & metList$biologicalType == "metabolite",]

    #Create a list (matrix) of pathways found in the selected compartment
    compaMat <- matrix(data = 0, nrow = length(pathList$name), ncol = length(compartmentWanted), dimnames = list(pathList$name, compartmentWanted))
    for(i in 1:length(metList$name)){
      compaMat[setdiff(metList[i,]$pathways[[1]], excludedPaths), compartmentWanted] <- 1
    }
    pathList <- pathList[compaMat[,compartmentWanted] == 1,]
  } else {
    metList <- metList[metList$biologicalType == "metabolite",]
  }

  #Make alphabetical if set, default to forcedirected for any other value
  if(mapMode == "alphabetical"){
    pathMat <- matrix(data = 1, nrow = length(pathList$name), ncol = length(pathList$name), dimnames = list(pathList$name[order(pathList$name)], pathList$name[order(pathList$name)]))
    pathMap <- graph_from_adjacency_matrix(pathMat)
    mapLo <- layout_(pathMap, on_grid(dim = 2), normalize(xmin = 0, xmax =  0.4 * length(pathList$name) + 9 ))
  } else {
    pathMat <- matrix(data = 0, nrow = length(pathList$name), ncol = length(pathList$name), dimnames = list(pathList$name, pathList$name))
    for(i in metList$pathways){
      pList <- setdiff(i, excludedPaths)
      #Increment adjacency matrix for each intersection of pathways
      if(length(pList) > 1){
        pathMat[pList,pList] = pathMat[pList,pList] + 1
      }
    }
    diag(pathMat) <- 0

    pathMap <- graph_from_adjacency_matrix(pathMat, weighted = TRUE)
    #Create map layout with the Kamada-Kawai algorithm, adjust size by empirically derived equation
    mapLo <- layout_(pathMap, with_kk(dim = 2, weights = E(pathMap)$weight), normalize(xmin = 0, xmax =  0.4 * length(pathList$name) + 9 ))
  }

  pathNodesOut <- as.data.frame(cbind((as_data_frame(pathMap, what ="vertices")$name), mapLo[,1], mapLo[,2]))
  colnames(pathNodesOut) <- c("name", "x", "z")

  mapOut <- list(nodes = pathNodesOut) #mapOut is returned by plumber
  write_json(mapOut, mapOutSink, pretty = TRUE) #Cache map for next use
}
