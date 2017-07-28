library(jsonlite)

pimpData <- read.csv("peaks.csv", stringsAsFactors = FALSE)
#pimpData <- cbind(pimpData[,grep("Peak.id", colnames(pimpData))], pimpData[,grep("^P.+mzXML", colnames(pimpData))], pimpData[,grep("^B.+mzXML", colnames(pimpData))])
pimpData[is.na(pimpData)] <- 0
#pimpData <- cbind(pimpData$Peak.id, rowMeans(pimpData[,grep("^P.+mzXML", colnames(pimpData))]), rowMeans(pimpData[,grep("^B.+mzXML", colnames(pimpData))]), pimpData$InChI.Key)


#t.test(pimpData[,grep("^P.+mzXML", colnames(pimpData))], pimpData[,grep("^B.+mzXML", colnames(pimpData))])


#pcols <- grep("^P.+mzXML", colnames(pimpData))
#bcols <- grep("^B.+mzXML", colnames(pimpData))
#letssee <- apply(pimpData[,c(pcols,bcols)], 1, function(x) {t.test(x[pcols], x[bcols]); browser()})
#browser()



#apply(pimpData[,c(pcols,bcols)], 1, function(x) {t.test(x[grep("^P.+mzXML", colnames(x))], x[grep("^B.+mzXML", colnames(x))])})

#letssee <- apply(pimpData[,c(pcols,bcols)], 1, function(x) {t.test(x[grep("^P.+mzXML", colnames(x))], x[grep("^B.+mzXML", colnames(x))])})

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

#if i get a different way to assign ambiguous, i can use unique() here
inksup <- unlist(strsplit(inksup, ","))
inksdown <- unlist(strsplit(inksdown, ","))
inksambig <- as.data.frame(intersect(inksup, inksdown), stringsAsFactors = FALSE)

inksambig$up <- as.numeric(table(inksup)[inksambig[,1]])
inksambig$down <- as.numeric(table(inksdown)[inksambig[,1]])

inksup <- setdiff(inksup, inksambig[,1])
inksdown <- setdiff(inksdown, inksambig[,1])

#inksambig <- inksambig[!inksambig$up == inksambig$down,]
inksup <- append(inksup, inksambig[inksambig$up > inksambig$down, 1])
inksdown <- append(inksdown, inksambig[inksambig$up < inksambig$down, 1])

inksup <- as.data.frame(inksup, stringsAsFactors = FALSE)
inksup[,2] <- TRUE
colnames(inksup) <- c("ink", "pos")

inksdown <- as.data.frame(inksdown, stringsAsFactors = FALSE)
inksdown[,2] <- FALSE
colnames(inksdown) <- c("ink", "pos")

inksall <- rbind(inksup, inksdown)

write_json(inksall, 'parsedpeaks.json', pretty = TRUE)
