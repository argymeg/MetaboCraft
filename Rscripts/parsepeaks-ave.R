library(jsonlite)

#playerName <- argymeg
#mdataFile <- "pathos_KEGGlist3-withink.csv"
#alias <- testdata
#cond1colsIn <- "P1.mzXML,P2.mzXML,P3.mzXML,P4.mzXML,P5.mzXML,P6.mzXML,P7.mzXML,P8.mzXML,P9.mzXML,P10.mzXML"
#cond2colsIn <- "B1.mzXML,B2.mzXML,B3.mzXML,B4.mzXML,B5.mzXML,B6.mzXML,B7.mzXML,B8.mzXML,B9.mzXML,B10.mzXML"
#userdataSource = "../examples/example1.csv"

outputSink = paste0("../../cache/userData_", playerName, "-", alias, ".json")

userdata <- read.csv(userdataSource, stringsAsFactors = FALSE)
userdata[is.na(userdata)] <- 2000

#GREATER MEANS GREATER IN X!!!!!!
#LESS MEANS SMALLER IN X!!!!!
print(cond2colsIn)
print(cond1colsIn)
cond1cols <- as.vector(read.csv(text = gsub(" ", "", cond2colsIn, fixed = TRUE), header = FALSE, stringsAsFactors = FALSE), mode = "character")
cond2cols <- as.vector(read.csv(text = gsub(" ", "", cond1colsIn, fixed = TRUE), header = FALSE, stringsAsFactors = FALSE), mode = "character")
datacols <- c(cond2cols, cond1cols)

greaters <- apply(userdata[,datacols], 1, function(x) {t.test(x[cond2cols], x[cond1cols], alternative = "greater")$p.value})
lessers <- apply(userdata[,datacols], 1, function(x) {t.test(x[cond2cols], x[cond1cols], alternative = "less")$p.value})

greaters <- p.adjust(greaters, method = "BH")
lessers <- p.adjust(lessers, method = "BH")

greaters <- greaters < 0.05
lessers <- lessers < 0.05

inksup <- userdata[greaters,]$InChI.Key
inksdown <- userdata[lessers,]$InChI.Key

inksup <- unique(unlist(strsplit(inksup, ",")))
inksdown <- unique(unlist(strsplit(inksdown, ",")))
inksambig <- intersect(inksup, inksdown)

#using datacols, cond2cols, cond1cols from before!
for(thisink in inksambig){
  candidates <- userdata[grep(thisink, userdata$InChI.Key, fixed = TRUE),]
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

write_json(inksall, outputSink, pretty = TRUE)
