#!/usr/bin/env Rscript
# TreeHeight.R

data_path   <- "../data/trees.csv"
output_path <- "../results/TreeHts.csv"

df <- read.csv(data_path, stringsAsFactors = FALSE, check.names = FALSE)

# Calculation: Height = Distance * tan(Angle (degrees) * pi / 180)
df$Tree_Height_m <- df$`Distance.m` * tan(df$`Angle.degrees` * pi / 180)

write.csv(df, output_path, row.names = FALSE)