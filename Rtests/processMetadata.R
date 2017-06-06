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
