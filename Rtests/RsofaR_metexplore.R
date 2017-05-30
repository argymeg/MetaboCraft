library("igraph")
library("jsonlite")

write_json(fromJSON(txt = "1755sterol.json"), "prettysterol.json", pretty = TRUE)
graphData = fromJSON(txt = "prettysterol.json")
graph <- graph_from_data_frame(as.data.frame(cbind(graphData$links$source, graphData$links$target)), directed = FALSE)
lo <- layout_with_fr(graph, dim = 3)
minCoord = min(lo)

nodesout <- as.data.frame(cbind((as_data_frame(graph, what ="vertices")$name),(-minCoord+lo[,1])*2,(-minCoord+lo[,2])*2,(-minCoord+lo[,3])*2))
edgesout <- as_data_frame(graph, what = "edges")
colnames(nodesout) <- c("name", "x", "y", "z")

write_json(list(nodes = nodesout, edges = edgesout), "outOfR3.json", pretty = TRUE)
