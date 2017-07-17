#!/usr/local/bin/Rscript

library("jsonlite")

bioSource <- commandArgs(trailingOnly = TRUE)[1]
pathName <- commandArgs(trailingOnly = TRUE)[2]
cDataFile <- commandArgs(trailingOnly = TRUE)[3]

bioSource <- 1363
pathName<- "Arginine and Proline Metabolism"
cDataFile <- paste0("~/pimpcraft_working/data/outOfR_change_", bioSource, ".json")

cData <- fromJSON(cDataFile)

inchiListSource <- paste0("http://metexplore.toulouse.inra.fr:8080/metExploreWebService/link/", bioSource, "/metabolites/inchikey")
inchiList <- fromJSON(inchiListSource)

pathGraphSource <- "outOfR_Arginine and Proline Metabolism.json"
pathGraph <- fromJSON(pathGraphSource)$nodes
#pathGraph <- pathGraph[pathGraph$biologicalType == "metabolite" | pathGraph$biologicalType == "sideMetabolite" ,] #For future use
pathGraph <- pathGraph[pathGraph$biologicalType == "metabolite",]

#Not the most elegant solution, but it works. Revisit at some point.
#Stopped here because of the missing InChiKeys issue.
rownames(pathGraph) <- pathGraph$globalID
inchiList$localID <- pathGraph[inchiList$idMetabolite,"localID"]
inchiList <- subset(inchiList, !is.na(localID))

rownames(cData) <- cData$ink
inchiList$pos <- cData[inchiList$inchikey,"pos"]

changed <- inchiList[,c("localID","pos")]
changed <- subset(changed, !is.na(pos))
