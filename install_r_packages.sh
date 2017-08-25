#!/bin/bash

R --vanilla <<EOF
install.packages(c('devtools', 'jsonlite', 'shiny', 'plumber', 'markdown', 'curl'), repos = "https://cloud.r-project.org/")
library(devtools)
install_github("igraph/rigraph")
q()
EOF