# Q3 demographic cluster script (when sourced, runs one cluster job and saves .rda)


rm(list = ls())
graphics.off()

source("code/Demographic.R")

sum_vect <- function(x, y) {
  x + y
}

iter <- as.numeric(Sys.getenv("PBS_ARRAY_INDEX"))

# Local quick test (ONLY for laptop; comment out on HPC)
#iter <- 1

set.seed(iter)

growth_matrix <- matrix(
  c(0.1, 0.0, 0.0, 0.0,
    0.5, 0.4, 0.0, 0.0,
    0.0, 0.4, 0.7, 0.0,
    0.0, 0.0, 0.25, 0.4),
  nrow = 4, ncol = 4, byrow = TRUE
)

reproduction_matrix <- matrix(
  c(0.0, 0.0, 0.0, 2.6,
    0.0, 0.0, 0.0, 0.0,
    0.0, 0.0, 0.0, 0.0,
    0.0, 0.0, 0.0, 0.0),
  nrow = 4, ncol = 4, byrow = TRUE
)

clutch_distribution <- c(0.06, 0.08, 0.13, 0.15, 0.16, 0.18, 0.15, 0.06, 0.03)

simulation_length <- 120
n_reps <- 150

if (iter >= 1 && iter <= 25) {
  initial_state <- c(0, 0, 0, 100)
  initial_condition <- "large_adult"
} else if (iter >= 26 && iter <= 50) {
  initial_state <- c(0, 0, 0, 10)
  initial_condition <- "small_adult"
} else if (iter >= 51 && iter <= 75) {
  initial_state <- c(25, 25, 25, 25)
  initial_condition <- "large_mixed"
} else if (iter >= 76 && iter <= 100) {
  initial_state <- c(3, 3, 2, 2)
  initial_condition <- "small_mixed"
} else {
  stop("PBS_ARRAY_INDEX must be between 1 and 100.")
}

out_file <- paste("data/demographic_", initial_condition, "_", iter, ".rda", sep = "")

results <- vector("list", n_reps)
for (i in 1:n_reps) {
  results[[i]] <- stochastic_simulation(
    initial_state = initial_state,
    growth_matrix = growth_matrix,
    reproduction_matrix = reproduction_matrix,
    clutch_distribution = clutch_distribution,
    simulation_length = simulation_length
  )
}

save(results, iter, initial_condition, initial_state, file = out_file)