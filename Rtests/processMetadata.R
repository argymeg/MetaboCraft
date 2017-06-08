#argprolGraphData <- fromJSON("http://metexplore.toulouse.inra.fr:8080/metExploreWebService/graph/1363/filteredbypathway?pathwayidlist=(123700)")

#Read entire lines from cts into data frame
transOut <- data.frame(fromIdentifier = character(), searchTerm = character(), toIdentifier = character(), result = character(), stringsAsFactors = FALSE)
for (i in argprolGraphData$nodes$name){
  tryCatch({
    queryURL <- paste("http://cts.fiehnlab.ucdavis.edu/service/convert/Chemical%20Name/KEGG/", i, sep = "")
    queryURL <- gsub(" ", "%20", queryURL)
    print(queryURL)
    transOut[length(transOut$result) + 1, ] <- fromJSON(queryURL)
  }, error = function(e){})
}

#Only store name and the first result from cts
transOut <- data.frame(searchTerm = character(), result = character(), stringsAsFactors = FALSE)
transCounter <- 1
for (i in which(nodesout$biologicalType == "metabolite")){
  tryCatch({
    queryURL <- paste("http://cts.fiehnlab.ucdavis.edu/service/convert/Chemical%20Name/KEGG/", nodesout[i,]$chemName, sep = "")
    queryURL <- gsub(" ", "%20", queryURL)
    print(queryURL)
    transOutTemp <- fromJSON(queryURL, simplifyVector = FALSE)
    transOut[transCounter, 1] <- transOutTemp[[1]]$searchTerm[[1]]
    transOut[transCounter, 2] <- transOutTemp[[1]]$result[[1]]
    transCounter <- transCounter + 1
  }, error = function(e){print(e)})
}


#Import sample data and calculate a crude metric of positive or negative change (more than 2-fold)
sampleData <- read.csv("pathos_KEGGlist2.csv")
sampleFrame <- as.data.frame(cbind(sampleData$Mean..24hrs_A, sampleData$Mean..24hrs_B))
rownames(sampleFrame) <- sampleData$C14
colnames(sampleFrame) <- c("A-24", "B-24")
sampleFrame$l2fc <- log2(sampleFrame$`B-24`/sampleFrame$`A-24`)
sampleFrame$pos <- sampleFrame$l2fc > 1
sampleFrame$neg <- sampleFrame$l2fc < -1

#Create new data frame containing only node identifiers and positive or negative change
#TODO1: Further condense output
#TODO2: Use [] notation instead of subset
transList <- as.list(transOut$result)
names(transList) <- transOut$searchTerm
nodeChange <- subset(nodesout, biologicalType == "metabolite", select = c("localID", "chemName"))
nodeChange$KEGG <- as.character(transList[nodeChange$chemName])
nodeChange <- subset(nodeChange, KEGG != "NULL")
nodeChange$pos <- sampleFrame[nodeChange$KEGG,]$pos
nodeChange$neg <- sampleFrame[nodeChange$KEGG,]$neg
nodeChange <- subset(nodeChange, !is.na(pos))
nodeChange <- subset(nodeChange, pos | neg)

write_json((change = nodeChange), "outOfR_change.json", pretty = TRUE)
