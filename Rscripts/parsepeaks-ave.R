library(jsonlite)

pimpData <- read.csv("../examples/example1.csv", stringsAsFactors = FALSE)
pimpData[is.na(pimpData)] <- 2000

cond1colsIn <- "P1.mzXML,P2.mzXML,P3.mzXML,P4.mzXML,P5.mzXML,P6.mzXML,P7.mzXML,P8.mzXML,P9.mzXML,P10.mzXML"
cond2colsIn <- "B1.mzXML,B2.mzXML,B3.mzXML,B4.mzXML,B5.mzXML,B6.mzXML,B7.mzXML,B8.mzXML,B9.mzXML,B10.mzXML"

#GREATER MEANS GREATER IN X!!!!!!
#LESS MEANS SMALLER IN X!!!!!
cond1cols <- as.vector(read.csv(text = cond1colsIn, header = FALSE, stringsAsFactors = FALSE), mode = "character")
cond2cols <- as.vector(read.csv(text = cond2colsIn, header = FALSE, stringsAsFactors = FALSE), mode = "character")
datacols <- c(cond2cols, cond1cols)

greaters <- apply(pimpData[,datacols], 1, function(x) {t.test(x[cond2cols], x[cond1cols], alternative = "greater")$p.value})
lessers <- apply(pimpData[,datacols], 1, function(x) {t.test(x[cond2cols], x[cond1cols], alternative = "less")$p.value})

greaters <- p.adjust(greaters, method = "BH")
lessers <- p.adjust(lessers, method = "BH")

greaters <- greaters < 0.05
lessers <- lessers < 0.05

inksup <- pimpData[greaters,]$InChI.Key
inksdown <- pimpData[lessers,]$InChI.Key

inksup <- unique(unlist(strsplit(inksup, ",")))
inksdown <- unique(unlist(strsplit(inksdown, ",")))
inksambig <- intersect(inksup, inksdown)

#using datacols, cond2cols, cond1cols from before!
for(thisink in inksambig){
  candidates <- pimpData[grep(thisink, pimpData$InChI.Key, fixed = TRUE),]
  candidates <- candidates[,datacols]
  if (t.test(candidates[cond2cols], candidates[cond1cols], alternative = "greater")$p.value < 0.05){
    inksup <- c(inksup, thisink)
  } else if (t.test(candidates[cond2cols], candidates[cond1cols], alternative = "less")$p.value < 0.05) {
    inksdown <- c(inksdown, thisink)
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
