#!/usr/local/bin/Rscript --vanilla

library("igraph")
library("jsonlite")

inputFile = "1755sterol.json"

#Read input file, create graph from the source and target of each interaction, build layout
#TODO1: differentiate between metabolites and reactions
#TODO2: experiment with graphing algorithms, although Drl looks promising.
graphData <- fromJSON(txt = inputFile)
graph <- graph_from_data_frame(as.data.frame(cbind(graphData$links$source, graphData$links$target)), directed = FALSE)
lo <- layout_with_drl(graph, dim = 3)


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
nodesout <- as.data.frame(cbind((as_data_frame(graph, what ="vertices")$name),(lo[,1]-minCoord)*10,(lo[,2]-minCoord)*10,(lo[,3]-minCoord)*10))
colnames(nodesout) <- c("name", "x", "y", "z")
for(i in 1:length(nodesout$name)){
  nodesout$chemName[i] <- graphData$nodes$name[as.integer(as.character(nodesout$name[i]))+1]
}
nodesout <- nodesout[order(as.integer(as.character(nodesout$name))),]

#Build the edge part of the output - just a list of edges for now
edgesout <- as_data_frame(graph, what = "edges")

write_json(list(nodes = nodesout, edges = edgesout), "outOfR6.json", pretty = TRUE)