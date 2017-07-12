#!/usr/bin/env Rscript

library(plumber)
pimpcraftBackend <- plumb("plumberFunctions.R")
pimpcraftBackend$run(port = 32908)
