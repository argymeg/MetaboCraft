#!/usr/local/bin/Rscript

library("igraph")
library("jsonlite")

compaListSource <- "http://metexplore.toulouse.inra.fr:8080/metExploreWebService/biosources/1363/compartments"
compaLinkSource <- "http://metexplore.toulouse.inra.fr:8080/metExploreWebService/link/1363/compartments/metabolites"
pathwayListSource <- "http://metexplore.toulouse.inra.fr:8080/metExploreWebService/biosources/1363/pathways"
metaboliteListSource <- "http://metexplore.toulouse.inra.fr:8080/metExploreWebService/graph/1363"
outputSink = "~/pimpcraft_working/data/outOfR_pathMap.json"

compaList <- fromJSON(compaListSource)
compaLinks <- fromJSON(compaLinkSource)
pathList <- fromJSON(pathwayListSource)
metList <- fromJSON(metaboliteListSource)$nodes

pathList <- pathList[-which(pathList$name == "Miscellaneous" | pathList$name == "Unassigned"),]
pathMat <- matrix(data = 0, nrow = length(pathList$name), ncol = length(pathList$name), dimnames = list(pathList$name, pathList$name))
compaMat <- matrix(data = 0, nrow = length(pathList$name), ncol = length(compaList$name), dimnames = list(pathList$name, compaList$name))

#xx <- 1
#yy <- 1
#for(i in 1:length(metList$name)){
#  #print(paste(metList[i,]$biologicalType, metList[i,]$compartment, sep = "sep"))
#  if(metList[i,]$biologicalType == "metabolite" & !is.na(metList[i,]$compartment)){
#    for(j in metList[i,]$pathways){
#      if(j != "Miscellaneous" & j != "Unassigned"){
#        tryCatch({
#          compaMat[j,metList[i,]$compartment] <- 1
#          yy <<- yy + 1
#        }, error = function(e){print(e);print(j);xx <<- xx + 1})
#      }
#    }
#  }
#}

#Create a matrix of pathways and compartments, assuming that if a metabolite belonging to a pathway
#can be found in a compartment, so will the pathway. Should be fairly accurate since MetExplore has
#different entries for metabolites in different compartments.
for(i in 1:length(metList$name)){
  if(metList[i,]$biologicalType == "metabolite" & !is.na(metList[i,]$compartment)){
    for(j in metList[i,]$pathways){
      pList <- unique(j)[-which(unique(j) == "Miscellaneous" | unique(j) == "Unassigned")]
      compaMat[pList,metList[i,]$compartment] <- 1
    }
  }
}


#Make graph with top 3 connections
for(i in metList$pathways){
  pList <- unique(i)[-which(unique(i) == "Miscellaneous" | unique(i) == "Unassigned")]
  if(length(pList) > 1){
    pathMat[pList,pList] = pathMat[pList,pList] + 1
  }
}
diag(pathMat) <- 0

pathMat <- t(apply(pathMat, 1, function(x){
  (x >= min(tail(sort(x), 1)) & x > 0) * 1
  }))

pathMap <- graph_from_adjacency_matrix(pathMat, mode = "lower")
mapLo <- layout_(pathMap, with_fr(dim = 2), normalize(xmin = 0, xmax = 150))

plot(pathMap, layout = mapLo)


#Write map to disk
pathNodesOut <- as.data.frame(cbind((as_data_frame(pathMap, what ="vertices")$name), mapLo[,1], mapLo[,2]))
colnames(pathNodesOut) <- c("name", "x", "z")
pathEdgesOut <- as_data_frame(pathMap, what = "edges")

write_json(list(nodes = pathNodesOut, edges = pathEdgesOut), outputSink, pretty = TRUE)
