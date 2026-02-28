rm(list = ls())
graphics.off()

# Load all functions you wrote (including neutral_cluster_run)
source("code/yl14225.Liu_HPC_2025_main.R")

# ---- Job number from cluster ----
# On HPC: UNCOMMENT the next line
iter <- as.numeric(Sys.getenv("PBS_ARRAY_INDEX"))

# Local testing: COMMENT OUT before running on HPC
# iter <- 1

set.seed(iter)

if(iter >= 1 && iter <= 25){
  size <- 500
} else if(iter >= 26 && iter <= 50){
  size <- 1000
} else if(iter >= 51 && iter <= 75){
  size <- 2500
} else if(iter >= 76 && iter <= 100){
  size <- 5000
} else {
  stop("PBS_ARRAY_INDEX must be between 1 and 100.")
}

# Same speciation rate for all jobs (replace with your assigned value)
speciation_rate <- 0.5  # TODO: replace with your assigned speciation rate

# Parameters required by worksheet
interval_rich <- 1
interval_oct <- size / 10
burn_in_generations <- 8 * size

# Give code 11.5 hours; request 12 hours in the scheduler script
wall_time <- 11.5 * 60  # minutes

# Ensure data folder exists (you already have it, but this is a safe check)
if(!dir.exists("data")){
  stop("data/ directory not found under getwd(): ", getwd())
}

output_file_name <- file.path(
  "data",
  paste("neutral_results_iter_", iter, "_N_", size, ".rda", sep = "")
)

# Run simulation and save results
neutral_cluster_run(speciation_rate = speciation_rate,
                    size = size,
                    wall_time = wall_time,
                    interval_rich = interval_rich,
                    interval_oct = interval_oct,
                    burn_in_generations = burn_in_generations,
                    output_file_name = output_file_name)
