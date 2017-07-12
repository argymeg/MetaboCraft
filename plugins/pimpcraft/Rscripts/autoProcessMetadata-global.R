#!/usr/local/bin/Rscript

library("jsonlite")

bioSource <- commandArgs(trailingOnly = TRUE)[1]
mdataFile <- commandArgs(trailingOnly = TRUE)[2]

#bioSource <- 1363
#mdataFile <- "pathos_KEGGlist3-withink.csv"

metadataSource = paste0("~/pimpcraft_working/data/", mdataFile)
outputSink = paste0("~/pimpcraft_working/data/outOfR_change_", bioSource, ".json")

#Import sample data and calculate a crude metric of positive or negative change (more than 2-fold)
sampleData <- read.csv(metadataSource)
sampleFrame <- as.data.frame(cbind(sampleData$Mean..24hrs_A, sampleData$Mean..24hrs_B))
rownames(sampleFrame) <- sampleData$InChiKEy
colnames(sampleFrame) <- c("A-24", "B-24")
sampleFrame$l2fc <- log2(sampleFrame$`B-24`/sampleFrame$`A-24`)
sampleFrame$pos <- sampleFrame$l2fc > 1
sampleFrame$neg <- sampleFrame$l2fc < -1

#Create new data frame containing only InChiKeys and positive or negative change
#TODO: Use [] notation instead of subset
changed <- subset(sampleFrame, select = c(pos,neg))
colnames(changed) <- c("pos","neg")
changed <- subset(changed, !is.na(pos))
changed <- subset(changed, pos | neg)
changed$ink <- rownames(changed)
rownames(changed) <- NULL
changed <- changed[,c("ink","pos")]

write_json(changed, outputSink, pretty = TRUE)
