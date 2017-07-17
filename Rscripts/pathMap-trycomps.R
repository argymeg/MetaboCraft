#!/usr/local/bin/Rscript

library("igraph")
library("jsonlite")

compartmentWanted <- "mitochondrion"


pathwayListSource <- "http://metexplore.toulouse.inra.fr:8080/metExploreWebService/biosources/1363/pathways"
metaboliteListSource <- "http://metexplore.toulouse.inra.fr:8080/metExploreWebService/graph/1363"
outputSink = "~/pimpcraft_working/data/outOfR_pathMap_1363.json"

pathList <- fromJSON(pathwayListSource)
metList <- fromJSON(metaboliteListSource)$nodes

pathList <- pathList[-which(pathList$name == excludedPaths),]
compaMat <- matrix(data = 0, nrow = length(pathList$name), ncol = length(compartmentWanted), dimnames = list(pathList$name, compartmentWanted))

#Create a matrix of pathways and compartments, assuming that if a metabolite belonging to a pathway
#can be found in a compartment, so will the pathway. Should be fairly accurate since MetExplore has
#different entries for metabolites in different compartments.
excludedPaths <- c("Unassigned","Miscellaneous")
metListSubset <- metList[metList$compartment == compartmentWanted & metList$biologicalType == "metabolite",]
for(i in 1:length(metListSubset$name)){
  compaMat[setdiff(metListSubset[i,]$pathways[[1]], excludedPaths), compartmentWanted] <- 1
}

pathListWanted <- pathList[compaMat[,compartmentWanted] == 1,]
pathMat <- matrix(data = 0, nrow = length(pathListWanted$name), ncol = length(pathListWanted$name), dimnames = list(pathListWanted$name, pathListWanted$name))

#Make graph with top 2 connections
for(i in metListSubset$pathways){
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

plot(pathMap, layout = mapLo)


#Write map to disk
pathNodesOut <- as.data.frame(cbind((as_data_frame(pathMap, what ="vertices")$name), mapLo[,1], mapLo[,2]))
colnames(pathNodesOut) <- c("name", "x", "z")
pathEdgesOut <- as_data_frame(pathMap, what = "edges")

write_json(list(nodes = pathNodesOut, edges = pathEdgesOut), outputSink, pretty = TRUE)
