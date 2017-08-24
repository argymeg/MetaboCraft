#!/usr/bin/env Rscript

library(plumber)
metabocraftBackend <- plumb("plumberFunctions.R")
metabocraftBackend$run(port = 32908)
