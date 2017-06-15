library("igraph")
library("jsonlite")

pathList <- fromJSON("http://metexplore.toulouse.inra.fr:8080/metExploreWebService/biosources/1363/pathways")
metList <- fromJSON("http://metexplore.toulouse.inra.fr:8080/metExploreWebService/graph/1363")$nodes

pathList <- pathList[-which(pathList$name == "Miscellaneous" | pathList$name == "Unassigned"),]
pathMat <- matrix(data = 0, nrow = length(pathList$name), ncol = length(pathList$name), dimnames = list(pathList$name, pathList$name))

#Make weighted graph
for(i in metList$pathways){
  pList <- unique(i)[-which(unique(i) == "Miscellaneous" | unique(i) == "Unassigned")]
  if(length(pList) > 1){
    pathMat[pList,pList] = pathMat[pList,pList] + 1
  }
}
diag(pathMat) <- 0

pathMap <- graph_from_adjacency_matrix(pathMat, weighted = TRUE)
mapLo <- layout_(pathMap, with_fr(dim = 2, weights = E(pathMap)$weight), normalize(xmin = 0, xmax = 100))

plot(pathMap, layout = mapLo)

#Make connected-or-not-graph
for(i in metList$pathways){
  pList <- unique(i)[-which(unique(i) == "Miscellaneous" | unique(i) == "Unassigned")]
  if(length(pList) > 1){
    pathMat[pList,pList] = 1
  }
}
diag(pathMat) <- 0

pathMap <- graph_from_adjacency_matrix(pathMat)
mapLo <- layout_(pathMap, with_fr(dim = 2), normalize(xmin = 0, xmax = 100))

plot(pathMap, layout = mapLo)

#Make connected-or-not-graph with threshold
for(i in metList$pathways){
  pList <- unique(i)[-which(unique(i) == "Miscellaneous" | unique(i) == "Unassigned")]
  if(length(pList) > 1){
    pathMat[pList,pList] = pathMat[pList,pList] + 1
  }
}
diag(pathMat) <- 0

pathMat <- (pathMat > 20) * 1

pathMap <- graph_from_adjacency_matrix(pathMat)
mapLo <- layout_(pathMap, with_fr(dim = 2), normalize(xmin = 0, xmax = 100))

plot(pathMap, layout = mapLo)

#Make weighted graph with threshold
for(i in metList$pathways){
  pList <- unique(i)[-which(unique(i) == "Miscellaneous" | unique(i) == "Unassigned")]
  if(length(pList) > 1){
    pathMat[pList,pList] = pathMat[pList,pList] + 1
  }
}
diag(pathMat) <- 0
pathMat <- pathMat - 10
pathMat[pathMat < 0] <- 0

pathMap <- graph_from_adjacency_matrix(pathMat, weighted = TRUE)
mapLo <- layout_(pathMap, with_fr(dim = 2, weights = E(pathMap)$weight), normalize(xmin = 0, xmax = 100))

plot(pathMap, layout = mapLo)


pathNodesOut <- as.data.frame(cbind((as_data_frame(pathMap, what ="vertices")$name), mapLo[,1], mapLo[,2]))
colnames(pathNodesOut) <- c("name", "x", "z")
pathEdgesOut <- as_data_frame(pathMap, what = "edges")

write_json(list(nodes = pathNodesOut, edges = pathEdgesOut), "outOfR_pathMap.json", pretty = TRUE)
