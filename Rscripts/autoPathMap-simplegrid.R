#!/usr/bin/env Rscript
#Automated pathway map generation, for user-defined biosource

library("igraph")
library("jsonlite")

#bioSource <- commandArgs(trailingOnly = TRUE)[1]
#compartmentWanted <- commandArgs(trailingOnly = TRUE)[2]

#bioSource <- 1363
#compartmentWanted <- "mitochondrion"

mapOutSink = paste0("../cache/pathMap_",bioSource,"_", gsub("/","--", compartmentWanted, fixed = TRUE),".json")
if(file.exists(mapOutSink)){
  mapOut <- fromJSON(mapOutSink) #If the map is already there, we're done!
} else {
  excludedPaths <- c("Unassigned","Miscellaneous")
  
  pathwayListOutSink = paste0("../cache/pathwayList_",bioSource,".json")
  metaboliteListOutSink = paste0("../cache/metaboliteList_",bioSource,".json")
  
  #Check if pathway list and/or metabolite list are cached, don't redownload them if we don't have to!
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
  #compaListSource <- paste0("http://metexplore.toulouse.inra.fr:8080/metExploreWebService/biosources/",bioSource,"/compartments") #Keep for future error checking
  
  pathList <- pathList[-which(pathList$name == excludedPaths),]
  
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
  pathMat <- matrix(data = 0, nrow = length(pathList$name), ncol = length(pathList$name), dimnames = list(pathList$name, pathList$name))
  
  #Make weighted graph
  for(i in metList$pathways){
    pList <- setdiff(i, excludedPaths)
    if(length(pList) > 1){
      pathMat[pList,pList] = pathMat[pList,pList] + 1
    }
  }
  diag(pathMat) <- 0
  
  pathMap <- graph_from_adjacency_matrix(pathMat, weighted = TRUE)
  mapLo <- layout_(pathMap, on_grid(dim = 2), normalize(xmin = 0, xmax =  0.4 * length(pathList$name) + 9 ))
 
  pathNodesOut <- as.data.frame(cbind((as_data_frame(pathMap, what ="vertices")$name), mapLo[,1], mapLo[,2]))
  colnames(pathNodesOut) <- c("name", "x", "z")
  
  mapOut <- list(nodes = pathNodesOut)
  write_json(mapOut, mapOutSink, pretty = TRUE) #Cache map for next use
}
