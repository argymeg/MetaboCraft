library("igraph")
library("jsonlite")

graphData = fromJSON(txt = "alldataRin.json")
graph <- graph_from_data_frame(testData$edges, directed = FALSE)
lo <- layout_on_grid(tgraph, dim = 3)

nodesout <- as.data.frame(cbind((as_data_frame(graph, what ="vertices")$name),lo[,1]*10,lo[,2]*10,lo[,3]*10))
edgesout <- as_data_frame(graph, what = "edges")
colnames(nodesout) <- c("name", "x", "y", "z")

toJSON(list(nodes = nodesout, edges = edgesout), pretty = TRUE)

write_json(list(nodes = nodesout, edges = edgesout), "outOfR2.json", pretty = TRUE)
