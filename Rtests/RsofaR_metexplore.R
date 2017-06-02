#!/usr/local/bin/Rscript --vanilla

library("igraph")
library("jsonlite")

duplicateCompoundsOld <- function(startAt, side){
  target <- paste("allLinks$", side, sep="")
  print(target)
  eval(parse(text = target))
  for(j in which(eval(parse(text = target)) == i)[startAt:sum(eval(parse(text = target)) == i)]){
    print(allNodes[i+1,])
    allNodes[length(allNodes$localID)+1,] <<- allNodes[i+1,]
    #allNodes$localID <- as.character(allNodes$localID)
    allNodes[length(allNodes$localID),]$localID <<- length(allNodes$localID) - 1
    #allNodes$localID <- as.factor(allNodes$localID)
    target <- paste("allLinks$", side, sep="")
    (eval(parse(text = "allLinks$source")))[j] <<- allNodes[length(allNodes$localID),]$localID
  }
}

duplicateSources <- function(startAt){
    for(j in which(allLinks$source == i)[startAt:sum(allLinks$source == i)]){
      allNodes[length(allNodes$localID)+1,] <<- allNodes[i+1,]
      allNodes[length(allNodes$localID),]$localID <<- length(allNodes$localID) - 1
      allLinks[j,]$source <<- allNodes[length(allNodes$localID),]$localID
    }
}
duplicateTargets <- function(startAt){
  for(j in which(allLinks$target == i)[startAt:sum(allLinks$target == i)]){
    allNodes[length(allNodes$localID)+1,] <<- allNodes[i+1,]
    allNodes[length(allNodes$localID),]$localID <<- length(allNodes$localID) - 1
    allLinks[j,]$target <<- allNodes[length(allNodes$localID),]$localID
  }
}

inputFile = "1755sterol.json"

#Read input file, create graph from the source and target of each interaction, build layout
#TODO1: differentiate between metabolites and reactions
#TODO2: experiment with graphing algorithms. Drl looks promising for large networks but let's get there first.
graphData <- fromJSON(txt = inputFile)
allLinks <- as.data.frame(cbind(graphData$links$source, graphData$links$target))
colnames(allLinks) <- c("source","target")
allNodes <- as.data.frame(cbind(c(0:(length(graphData$nodes$name)-1)),graphData$nodes$name,graphData$nodes$biologicalType), stringsAsFactors = FALSE)
colnames(allNodes) <- c("localID","chemName","biologicalType")

for(i in 0:(length(allNodes$localID)-1)){
  #print(paste(i,sum(allLinks$source == i),sep = " sep "))
  if(sum(allLinks$source == i) + sum(allLinks$target == i) > 1 && allNodes[i+1,]$biologicalType == "metabolite"){
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
    #print(paste(i,allNodes[i+1,]$chemName,sum(allLinks$source == i),sep = " sep "))
#    for(j in which(allLinks$source == i)[2:sum(allLinks$source == i)]){
#      #print(allNodes[i+1,])
#      allNodes[length(allNodes$localID)+1,] <- allNodes[i+1,]
#      #allNodes$localID <- as.character(allNodes$localID)
#      allNodes[length(allNodes$localID),]$localID <- length(allNodes$localID) - 1
#      #allNodes$localID <- as.factor(allNodes$localID)
#      allLinks[j,]$source <- allNodes[length(allNodes$localID),]$localID
#    }
#    for(j in which(allLinks$target == i)[2:sum(allLinks$target == i)]){
#      #print(allNodes[i+1,])
#      allNodes[length(allNodes$localID)+1,] <- allNodes[i+1,]
#      #allNodes$localID <- as.character(allNodes$localID)
#      allNodes[length(allNodes$localID),]$localID <- length(allNodes$localID) - 1
#      #allNodes$localID <- as.factor(allNodes$localID)
#      allLinks[j,]$target <- allNodes[length(allNodes$localID),]$localID
#    }
  }
}
sum(graphData$links$source == 28)

graph <- graph_from_data_frame(allLinks, directed = FALSE)
lo <- layout_(graph, with_fr(dim = 3),normalize(xmin=0,xmax=100))


#If negative coordinates exist, make them all positive
#TOTHINK: should this be limited to the y axis?
#TODO: use igraph methods (eg normalize) rather than transforming coords by hand

if(min(lo) < 0) {
  minCoord <- min(lo)
} else {
  minCoord <- 0
}

#Build the node part of the output, with node id, coordinates, chemical name. Sort output by id for readability.
#TODO: as.integer(as.character) is rather ugly. Is there no better way?
nodesout <- as.data.frame(cbind((as_data_frame(graph, what ="vertices")$name),lo[,1],lo[,2],lo[,3]))
colnames(nodesout) <- c("name", "x", "y", "z")
for(i in 1:length(nodesout$name)){
  nodesout$chemName[i] <- as.character(allNodes$chemName[as.integer(as.character(nodesout$name[i]))+1])
  nodesout$biologicalType[i] <- as.character(allNodes$biologicalType[as.integer(as.character(nodesout$name[i]))+1])
}
nodesout <- nodesout[order(as.integer(as.character(nodesout$name))),]

#Build the edge part of the output - just a list of edges for now
edgesout <- as_data_frame(graph, what = "edges")

write_json(list(nodes = nodesout, edges = edgesout), "outOfR6.json", pretty = TRUE)

