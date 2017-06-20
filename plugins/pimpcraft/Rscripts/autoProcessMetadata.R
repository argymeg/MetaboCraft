#!/usr/local/bin/Rscript

library("jsonlite")

bioSource <- commandArgs(trailingOnly = TRUE)[1]
pathName <- commandArgs(trailingOnly = TRUE)[2]
mdataFile <- commandArgs(trailingOnly = TRUE)[3]

pathwayListSource <- paste0("http://localhost:8080/outOfR_pathList_", bioSource, ".json")
pathList <- fromJSON(pathwayListSource)
pathId <- pathList[which(pathList$name == pathName),]$id

nodeSource = paste0("~/pimpcraft_working/data/outOfR_", pathId, ".json")
metadataSource = paste0("~/pimpcraft_working/data/", mdataFile)
outputSink = paste0("~/pimpcraft_working/data/outOfR_change_", pathName, ".json")

nodeList <- fromJSON(nodeSource)$nodes

#Only store name and the first result from cts
transOut <- data.frame(searchTerm = character(), result = character(), stringsAsFactors = FALSE)
transCounter <- 1
for (i in which(nodeList$biologicalType == "metabolite")){
  tryCatch({
    queryURL <- paste("http://cts.fiehnlab.ucdavis.edu/service/convert/Chemical%20Name/KEGG/", nodeList[i,]$chemName, sep = "")
    queryURL <- gsub(" ", "%20", queryURL)
    print(queryURL)
    transOutTemp <- fromJSON(queryURL, simplifyVector = FALSE)
    transOut[transCounter, 1] <- transOutTemp[[1]]$searchTerm[[1]]
    transOut[transCounter, 2] <- transOutTemp[[1]]$result[[1]]
    transCounter <- transCounter + 1
  }, error = function(e){print(e)})
}

#Import sample data and calculate a crude metric of positive or negative change (more than 2-fold)
sampleData <- read.csv(metadataSource)
sampleFrame <- as.data.frame(cbind(sampleData$Mean..24hrs_A, sampleData$Mean..24hrs_B))
rownames(sampleFrame) <- sampleData$C14
colnames(sampleFrame) <- c("A-24", "B-24")
sampleFrame$l2fc <- log2(sampleFrame$`B-24`/sampleFrame$`A-24`)
sampleFrame$pos <- sampleFrame$l2fc > 1
sampleFrame$neg <- sampleFrame$l2fc < -1

#Create new data frame containing only node identifiers and positive or negative change
#TODO: Use [] notation instead of subset
transList <- as.list(transOut$result)
names(transList) <- transOut$searchTerm
nodeChange <- subset(nodeList, biologicalType == "metabolite", select = c("localID", "chemName"))
nodeChange$KEGG <- as.character(transList[nodeChange$chemName])
nodeChange <- subset(nodeChange, KEGG != "NULL")
nodeChange$pos <- sampleFrame[nodeChange$KEGG,]$pos
nodeChange$neg <- sampleFrame[nodeChange$KEGG,]$neg
nodeChange <- subset(nodeChange, !is.na(pos))
nodeChange <- subset(nodeChange, pos | neg)
nodeChange <- subset(nodeChange, select = c("localID", "pos"))

write_json((change = nodeChange), outputSink, pretty = TRUE)
