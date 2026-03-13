# code/00_setup.R
options(stringsAsFactors = FALSE)
options(scipen = 999)
set.seed(1)

Sys.setenv(LANGUAGE = "en")

library(here)

dirs <- c(
  here::here("results", "clean"),
  here::here("results", "fits"),
  here::here("results", "figures"),
  here::here("results", "tables")
)

for (d in dirs) {
  if (!dir.exists(d)) dir.create(d, recursive = TRUE)
}

writeLines(capture.output(sessionInfo()), here::here("results", "tables", "sessionInfo.txt"))