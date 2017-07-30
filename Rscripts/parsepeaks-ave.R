library(jsonlite)

pimpData <- read.csv("peaks.csv", stringsAsFactors = FALSE)
pimpData[is.na(pimpData)] <- 0

#GREATER MEANS GREATER IN X!!!!!!
#LESS MEANS SMALLER IN X!!!!!
datacols <- grep("mzXML", colnames(pimpData))
pcols <- grep("^P.+mzXML", colnames(pimpData[,datacols]))
bcols <- grep("^B.+mzXML", colnames(pimpData[,datacols]))
greaters <- apply(pimpData[,datacols], 1, function(x) {t.test(x[pcols], x[bcols], alternative = "greater")$p.value})
lessers <- apply(pimpData[,datacols], 1, function(x) {t.test(x[pcols], x[bcols], alternative = "less")$p.value})

greaters <- greaters < 0.05
lessers <- lessers < 0.05

inksup <- pimpData[greaters,]$InChI.Key
inksdown <- pimpData[lessers,]$InChI.Key

inksup <- unique(unlist(strsplit(inksup, ",")))
inksdown <- unique(unlist(strsplit(inksdown, ",")))
inksambig <- intersect(inksup, inksdown)

#using datacols, pcols, bcols from before!
for(thisink in inksambig){
  candidates <- pimpData[grep(thisink, pimpData$InChI.Key),]
  candidates <- candidates[,datacols]
  if (t.test(candidates[pcols], candidates[bcols], alternative = "greater")$p.value < 0.05){
    inksup <- append(inksup, thisink)
  } else if (t.test(candidates[pcols], candidates[bcols], alternative = "less")$p.value < 0.05) {
    inksdown <- append(inksdown, thisink)
  }
}

inksup <- as.data.frame(inksup, stringsAsFactors = FALSE)
inksup[,2] <- TRUE
colnames(inksup) <- c("ink", "pos")

inksdown <- as.data.frame(inksdown, stringsAsFactors = FALSE)
inksdown[,2] <- FALSE
colnames(inksdown) <- c("ink", "pos")

inksall <- rbind(inksup, inksdown)

write_json(inksall, 'parsedpeaks2.json', pretty = TRUE)
