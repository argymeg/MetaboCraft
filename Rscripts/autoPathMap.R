#!/usr/bin/env Rscript
#Automated pathway map generation, for user-defined biosource

library("igraph")
library("jsonlite")

excludedPaths <- c("Unassigned","Miscellaneous")

bioSource <- commandArgs(trailingOnly = TRUE)[1]
compartmentWanted <- commandArgs(trailingOnly = TRUE)[2]

#compaListSource <- paste0("http://metexplore.toulouse.inra.fr:8080/metExploreWebService/biosources/",bioSource,"/compartments") #Keep for future error checking
pathwayListSource <- paste0("http://metexplore.toulouse.inra.fr:8080/metExploreWebService/biosources/",bioSource,"/pathways")
metaboliteListSource <- paste0("http://metexplore.toulouse.inra.fr:8080/metExploreWebService/graph/",bioSource)
mapOutSink = paste0("~/pimpcraft_working/data/outOfR_pathMap_",bioSource,".json")
pathListOutSink = paste0("~/pimpcraft_working/data/outOfR_pathList_",bioSource,".json")
  
pathList <- fromJSON(pathwayListSource)
metList <- fromJSON(metaboliteListSource)$nodes

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

#Make graph with top 2 connections
for(i in metList$pathways){
  pList <- setdiff(i, excludedPaths)
  if(length(pList) > 1){
    pathMat[pList,pList] = pathMat[pList,pList] + 1
  }
}
diag(pathMat) <- 0

pathMat <- t(apply(pathMat, 1, function(x){
  (x >= min(tail(sort(x), 2)) & x > 0) * 1
  }))

pathMap <- graph_from_adjacency_matrix(pathMat, mode = "lower")
mapLo <- layout_(pathMap, with_fr(dim = 2), normalize(xmin = 0, xmax = 150))


#Write map to disk
pathNodesOut <- as.data.frame(cbind((as_data_frame(pathMap, what ="vertices")$name), mapLo[,1], mapLo[,2]))
colnames(pathNodesOut) <- c("name", "x", "z")
pathEdgesOut <- as_data_frame(pathMap, what = "edges")

write_json(list(nodes = pathNodesOut, edges = pathEdgesOut), mapOutSink, pretty = TRUE)

#Write pathway list to disk, needed for id translation in next step
write_json(pathList, pathListOutSink, pretty = TRUE)
