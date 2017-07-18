#!/usr/bin/env Rscript

library("igraph")
library("jsonlite")

#bioSource <- commandArgs(trailingOnly = TRUE)[1]
#pathName <- commandArgs(trailingOnly = TRUE)[2]

outputSink = paste0("../cache/pathGraph_", pathName, ".json")
if(file.exists(outputSink)){
  graphOut <- fromJSON(outputSink)
} else {
  #Small but crucial bit of duplicated code - could conceivably cause issues
  #TODO: find a way to dynamically choose which set of nodes to apply duplication to.
  #Previous effort (using eval(parse(x))) failed b/c this apparently can't be used in an assignment
  #Maybe use it that in the for statement, then have an if/else to do the assignment?
  
  #For each excess source (or target) node, duplicate the row, then set the id of the copy to the new maximum id,
  #then change the pointer for the node in allLinks to the new entry.
  #startAt == 2 means leave out the first node, when starting duplication.
  #startAt == 1 means duplicate all occurrences, when running for a second time
  #TODO: increase readability (assign length(allNodes$localID) to a new value at the beginning?)
  duplicateSources <- function(startAt){
    for(j in which(allLinks$source == i)[startAt:sum(allLinks$source == i)]){
      allNodes[length(allNodes$localID) + 1,] <<- allNodes[i+1,]
      allNodes[length(allNodes$localID),]$localID <<- length(allNodes$localID) - 1 #After previous line, length = old length + 1!
      allLinks[j,]$source <<- allNodes[length(allNodes$localID),]$localID
    }
  }
  duplicateTargets <- function(startAt){
    for(j in which(allLinks$target == i)[startAt:sum(allLinks$target == i)]){
      allNodes[length(allNodes$localID) + 1,] <<- allNodes[i+1,]
      allNodes[length(allNodes$localID),]$localID <<- length(allNodes$localID) - 1
      allLinks[j,]$target <<- allNodes[length(allNodes$localID),]$localID
    }
  }
  
  pathwayListOutSink = paste0("../cache/pathwayList_",bioSource,".json")
  
  if(file.exists(pathwayListOutSink)){
    pathwayListSource <- pathwayListOutSink
    pathList <- fromJSON(pathwayListSource)
  } else {
    pathwayListSource <- paste0("http://metexplore.toulouse.inra.fr:8080/metExploreWebService/biosources/",bioSource,"/pathways")
    pathList <- fromJSON(pathwayListSource)
    write_json(pathList, pathwayListOutSink, pretty = TRUE)
  }
  pathId <- pathList[which(pathList$name == pathName),]$id
  
  inputSource = paste0("http://metexplore.toulouse.inra.fr:8080/metExploreWebService/graph/1363/filteredbypathway?pathwayidlist=(", pathId, ")")
  
  #Read input file, create graph from the source and target of each interaction, build layout
  #TODO: experiment with graphing algorithms. Drl looks promising for large networks but let's get there first.
  graphData <- fromJSON(inputSource)
  allLinks <- as.data.frame(cbind(graphData$links$source, graphData$links$target))
  colnames(allLinks) <- c("source","target")
  linkType <- graphData$links$interaction
  allNodes <- as.data.frame(cbind(c(0:(length(graphData$nodes$name) - 1)), graphData$nodes$name, graphData$nodes$biologicalType, graphData$nodes$id), stringsAsFactors = FALSE)
  colnames(allNodes) <- c("localID","chemName","biologicalType","globalID")
  
  #Only process node if it crosses the threshold for total number of connections - but we don't know how many times in each side.
  #If there's more than one occurrence in sources, duplicate all but the first
  #Then if there are more occurrences in targets, duplicate them
  #Else, if there's only one occurrence in sources, leave that alone and duplicate targets
  #Else, duplicate all targets but the first
  #TODO1: PROPERLY DETERMINE THRESHOLD
  #TODO2: IMPLEMENT LIST-BASED NODE FILTERING
  for(i in 0:(length(allNodes$localID) - 1)){
    if(sum(allLinks$source == i) + sum(allLinks$target == i) > 5 && allNodes[i+1,]$biologicalType == "metabolite"){
      allNodes[i+1,]$biologicalType <- "sideMetabolite"
      if(sum(allLinks$source == i) > 1){
        duplicateSources(2)
        if(sum(allLinks$target == i) > 1){
          duplicateTargets(1)
        }
      } else if (sum(allLinks$source == i) == 1){
        duplicateTargets(1)
      } else {
        duplicateTargets(2)
      }
    }
  }
  graph <- graph_from_data_frame(allLinks, directed = FALSE)
  lo <- layout_(graph, with_fr(dim = 3), normalize(xmin = 0, xmax = 100))
  
  #Build the node part of the output, with node id, coordinates, chemical name. Sort output by id for readability.
  #TODO: as.integer(as.character) is rather ugly. Is there no better way?
  #UPDATE Fri 09/06: have to disable more factors to fix this. Is there a reason not to?
  nodesout <- as.data.frame(cbind((as_data_frame(graph, what ="vertices")$name), lo[,1], lo[,2], lo[,3]))
  colnames(nodesout) <- c("localID", "x", "y", "z")
  
  nodesout$chemName <- allNodes$chemName[as.integer(as.character(nodesout$localID)) + 1]
  nodesout$biologicalType <- allNodes$biologicalType[as.integer(as.character(nodesout$localID)) + 1]
  nodesout$globalID <- allNodes$globalID[as.integer(as.character(nodesout$localID)) + 1]
  
  nodesout <- nodesout[order(as.integer(as.character(nodesout$localID))),]
  
  #Build the edge part of the output - just a list of edges for now
  edgesout <- as.data.frame(cbind(as_data_frame(graph, what = "edges"), linkType))
  
  graphOut <- list(nodes = nodesout, edges = edgesout)
  write_json(graphOut, outputSink, pretty = TRUE)
}
