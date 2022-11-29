#!/usr/bin/env Rscript
packages = read.table ("rpackages.txt")
install.packages(packages$V1)
session.info()
