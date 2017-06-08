#!/usr/local/bin/Rscript --vanilla

library("igraph")
library("jsonlite")

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

inputFile = "argprolpretty.json"

#Read input file, create graph from the source and target of each interaction, build layout
#TODO: experiment with graphing algorithms. Drl looks promising for large networks but let's get there first.
graphData <- fromJSON(txt = inputFile)
allLinks <- as.data.frame(cbind(graphData$links$source, graphData$links$target))
colnames(allLinks) <- c("source","target")
linkType <- graphData$links$interaction
allNodes <- as.data.frame(cbind(c(0:(length(graphData$nodes$name) - 1)),graphData$nodes$name,graphData$nodes$biologicalType), stringsAsFactors = FALSE)
colnames(allNodes) <- c("localID","chemName","biologicalType")

#Only process node if it crosses the threshold for total number of connections - but we don't know how many times in each side.
#If there's more than one occurrence in sources, duplicate all but the first
#Then if there are more occurrences in targets, duplicate them
#Else, if there's only one occurrence in sources, leave that alone and duplicate targets
#Else, duplicate all targets but the first
#TODO1: PROPERLY DETERMINE THRESHOLD
#TODO2: IMPLEMENT LIST-BASED NODE FILTERING
for(i in 0:(length(allNodes$localID) - 1)){
  if(sum(allLinks$source == i) + sum(allLinks$target == i) > 4 && allNodes[i+1,]$biologicalType == "metabolite"){
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
lo <- layout_(graph, with_fr(dim = 3),normalize(xmin=0,xmax=100))

#Build the node part of the output, with node id, coordinates, chemical name. Sort output by id for readability.
#TODO: as.integer(as.character) is rather ugly. Is there no better way?
#UPDATE Mon 05/06: should not be needed anymore since disabling factors. Check during next cleanup.
nodesout <- as.data.frame(cbind((as_data_frame(graph, what ="vertices")$name), lo[,1], lo[,2], lo[,3]))
colnames(nodesout) <- c("localID", "x", "y", "z")
for(i in 1:length(nodesout$localID)){
  nodesout$chemName[i] <- as.character(allNodes$chemName[as.integer(as.character(nodesout$localID[i])) + 1])
  nodesout$biologicalType[i] <- as.character(allNodes$biologicalType[as.integer(as.character(nodesout$localID[i])) + 1])
}
nodesout <- nodesout[order(as.integer(as.character(nodesout$localID))),]

#Build the edge part of the output - just a list of edges for now
edgesout <- as.data.frame(cbind(as_data_frame(graph, what = "edges"), linkType))

write_json(list(nodes = nodesout, edges = edgesout), "outOfR_argprol.json", pretty = TRUE)

