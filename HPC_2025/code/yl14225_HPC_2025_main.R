# CMEE 2024 HPC exercises R code main pro forma
# You don't HAVE to use this but it will be very helpful.
# If you opt to write everything yourself from scratch please ensure you use
# EXACTLY the same function and parameter names and beware that you may lose
# marks if it doesn't work properly because of not using the pro-forma.

name <- "Yian Liu"
preferred_name <- "Jasper"
email <- "Yian.Liu25@imperial.ac.uk"
username <- "jasper5580"

# Please remember *not* to clear the work space here, or anywhere in this file.
# If you do, it'll wipe out your username information that you entered just
# above, and when you use this file as a 'toolbox' as intended it'll also wipe
# away everything you're doing outside of the toolbox.  For example, it would
# wipe away any automarking code that may be running and that would be annoying!

# Section One: Stochastic demographic population model

# Question 0
state_initialise_adult <- function(num_stages, initial_size){
  state <- rep(0, num_stages)
  state[num_stages] <- initial_size
  return(state)
}

state_initialise_spread <- function(num_stages, initial_size){
  base <- floor(initial_size / num_stages)
  rem  <- initial_size - base * num_stages
  
  state <- rep(base, num_stages)
  if(rem > 0){
    state[1:rem] <- state[1:rem] + 1
  }
  return(state)
}

# Question 1
question_1 <- function() {
  
  source("code/Demographic.R")
  
  if(!dir.exists("results")) dir.create("results")
  
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
  
  projection_matrix <- growth_matrix + reproduction_matrix
  
  init_adult  <- state_initialise_adult(num_stages = 4, initial_size = 100)
  init_spread <- state_initialise_spread(num_stages = 4, initial_size = 100)
  
  sim_length <- 24
  time <- 0:sim_length
  
  # Correct argument order: (initial_state, simulation_length, projection_matrix)
  pop_adult  <- deterministic_simulation(initial_state = init_adult,
                                         simulation_length = sim_length,
                                         projection_matrix = projection_matrix)
  
  pop_spread <- deterministic_simulation(initial_state = init_spread,
                                         simulation_length = sim_length,
                                         projection_matrix = projection_matrix)
  
  png(filename = "results/question_1.png", width = 700, height = 450)
  
  plot(time, pop_adult,
       type = "l",
       xlab = "Time step",
       ylab = "Total population size",
       lwd  = 2)
  
  lines(time, pop_spread, lwd = 2, lty = 2)
  
  legend("topleft",
         legend = c("100 adults", "100 spread across stages"),
         lty = c(1, 2),
         lwd = 2,
         bty = "n")
  
  dev.off()
  
  return(paste(
    "When all 100 individuals start as adults, reproduction can happen immediately so the population can grow faster at first.",
    "When individuals are spread across life stages, early growth can be slower because many individuals must mature before contributing to reproduction.",
    "Over time, both trajectories approach the same long-term growth pattern determined by the projection matrix."
  ))
}


# Question 2
question_2 <- function() {
  
  source("code/Demographic.R")
  set.seed(NULL)
  
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
  
  init_adult  <- state_initialise_adult(num_stages = 4, initial_size = 100)
  init_spread <- state_initialise_spread(num_stages = 4, initial_size = 100)
  
  sim_length <- 24
  time <- 0:sim_length
  
  pop_adult <- stochastic_simulation(
    initial_state = init_adult,
    growth_matrix = growth_matrix,
    reproduction_matrix = reproduction_matrix,
    clutch_distribution = clutch_distribution,
    simulation_length = sim_length
  )
  
  pop_spread <- stochastic_simulation(
    initial_state = init_spread,
    growth_matrix = growth_matrix,
    reproduction_matrix = reproduction_matrix,
    clutch_distribution = clutch_distribution,
    simulation_length = sim_length
  )
  
  png(filename = "results/question_2.png", width = 700, height = 450)
  
  plot(time, pop_adult,
       type = "l",
       xlab = "Time step",
       ylab = "Total population size",
       lwd  = 2,
       main = "Stochastic simulations (single runs)"
  )
  
  lines(time, pop_spread, lwd = 2, lty = 2)
  
  legend("topleft",
         legend = c("100 adults", "100 spread across stages"),
         lty = c(1, 2),
         lwd = 2,
         bty = "n")
  
  dev.off()
  
  return(paste(
    "The stochastic simulations are less smooth than the deterministic simulations and show random fluctuations.",
    "This is because survival, maturation and reproduction are implemented as discrete random events,",
    "so demographic stochasticity introduces sampling variation at each time step rather than following a single expected trajectory."
  ))
}


# Questions 3 and 4 involve writing code elsewhere to run your simulations on the cluster


# Question 5
question_5 <- function(){
  
  # Find .rda files (prefer data/; fallback current dir)
  files <- list.files("data", pattern="^demographic_.*\\.rda$", full.names=TRUE)
  if(length(files) == 0){
    files <- list.files(pattern="^demographic_.*\\.rda$", full.names=TRUE)
  }
  if(length(files) == 0){
    stop("No demographic_*.rda files found in data/ or current directory.")
  }
  
  # Labels for plotting (adjust if your initial_condition strings differ)
  label_map <- c(
    large_adult = "Adults, large population",
    small_adult = "Adults, small population",
    large_mixed = "Mixed, large population",
    small_mixed = "Mixed, small population"
  )
  
  # Containers
  extinct_counts <- numeric(0)
  total_counts <- numeric(0)
  
  # Loop through files
  for(f in files){
    env <- new.env()
    load(f, envir=env)
    
    if(!exists("initial_condition", envir=env) || !exists("results", envir=env)){
      warning(paste("Skipping file (missing initial_condition/results):", basename(f)))
      next
    }
    
    cond <- get("initial_condition", envir=env)
    sims <- get("results", envir=env)
    
    finals <- vapply(sims, function(v) v[length(v)], numeric(1))
    extinct <- sum(finals == 0, na.rm=TRUE)
    tot <- length(sims)
    
    if(!(cond %in% names(extinct_counts))){
      extinct_counts[cond] <- extinct
      total_counts[cond] <- tot
    } else {
      extinct_counts[cond] <- extinct_counts[cond] + extinct
      total_counts[cond] <- total_counts[cond] + tot
    }
  }
  
  props <- extinct_counts / total_counts
  
  # Order bars nicely if possible
  desired <- c("large_adult","small_adult","large_mixed","small_mixed")
  present <- names(props)
  ord <- c(desired[desired %in% present], present[!(present %in% desired)])
  props <- props[ord]
  
  labels <- ifelse(names(props) %in% names(label_map), label_map[names(props)], names(props))
  
  # Save plot (put in results/ if you prefer)
  png("results/question_5.png", width=900, height=550)
  par(mar=c(8,5,3,1))
  bp <- barplot(
    props,
    names.arg=labels,
    las=2,
    ylim=c(0, max(props, 0.01) * 1.2),
    ylab="Proportion of simulations extinct",
    main="Extinction probability by initial condition"
  )
  text(bp, props, labels=sprintf("%.3f", props), pos=3, cex=0.9)
  dev.off()
  
  # Text answer
  max_i <- which.max(props)
  most <- labels[max_i]
  
  return(paste(
    most, "was most likely to go extinct because stochastic variation has a much larger relative effect when populations are small,",
    "so runs are more likely to hit zero and cannot recover."
  ))
}


# Question 6
question_6 <- function(){
  
  source("code/Demographic.R")
  
  # 1) find files in data/
  files <- list.files("data", pattern="^demographic_.*\\.rda$", full.names=TRUE)
  if(length(files) == 0){
    stop("No demographic_*.rda files found in data/.")
  }
  
  # only analyse conditions 3 and 4: large_mixed and small_mixed
  target_conds <- c("large_mixed", "small_mixed")
  
  # label map for plot
  label_map <- c(
    large_mixed = "Mixed, large population",
    small_mixed = "Mixed, small population"
  )
  
  # matrices (same as earlier questions)
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
  
  projection_matrix <- growth_matrix + reproduction_matrix
  
  # containers to store mean trends and deterministic series
  mean_trend <- list()
  det_series <- list()
  deviation <- list()
  
  # 2) helper to accumulate sums for mean trend
  # We will compute: mean trend = (sum of all time series vectors) / (number of simulations)
  for(cond in target_conds){
    sum_vec <- NULL
    n_sims <- 0
    
    # loop all files and take those matching this cond (from the stored initial_condition)
    for(f in files){
      env <- new.env()
      load(f, envir=env)
      
      if(!exists("initial_condition", envir=env) || !exists("results", envir=env)){
        next
      }
      
      this_cond <- get("initial_condition", envir=env)
      if(!(this_cond %in% target_conds)) next
      if(this_cond != cond) next
      
      sims <- get("results", envir=env)
      if(!is.list(sims) || length(sims) == 0) next
      
      # initialise sum_vec length on first simulation encountered
      if(is.null(sum_vec)){
        sum_vec <- rep(0, length(sims[[1]]))
      }
      
      # add each simulation time series to sum_vec
      for(v in sims){
        # protect against unexpected length mismatch
        if(length(v) == length(sum_vec)){
          sum_vec <- sum_vec + v
          n_sims <- n_sims + 1
        }
      }
    }
    
    if(n_sims == 0){
      stop(paste("No simulations found for condition:", cond))
    }
    
    mean_trend[[cond]] <- sum_vec / n_sims
    
    # 3) deterministic series for the same initial condition and simulation length
    sim_length <- length(mean_trend[[cond]]) - 1
    
    if(cond == "large_mixed"){
      init_state <- state_initialise_spread(num_stages=4, initial_size=100)
    } else {
      init_state <- state_initialise_spread(num_stages=4, initial_size=10)
    }
    
    det_series[[cond]] <- deterministic_simulation(
      initial_state = init_state,
      simulation_length = sim_length,
      projection_matrix = projection_matrix
    )
    
    # 4) deviation = stochastic mean trend / deterministic series
    # avoid divide-by-zero (should not happen here, but protect anyway)
    denom <- det_series[[cond]]
    denom[denom == 0] <- NA
    deviation[[cond]] <- mean_trend[[cond]] / denom
  }
  
  # 5) plot
  if(!dir.exists("results")) dir.create("results")
  
  sim_length <- length(deviation[[target_conds[1]]]) - 1
  time <- 0:sim_length
  
  png("results/question_6.png", width=900, height=550)
  par(mar=c(5,5,3,1))
  
  ylim_max <- max(c(deviation[[target_conds[1]]], deviation[[target_conds[2]]]), na.rm=TRUE)
  ylim_min <- min(c(deviation[[target_conds[1]]], deviation[[target_conds[2]]]), na.rm=TRUE)
  pad <- 0.05
  ylim <- c(max(0, ylim_min - pad), ylim_max + pad)
  
  plot(time, deviation[[target_conds[1]]],
       type="l", lwd=2,
       xlab="Time step",
       ylab="Deviation (stochastic mean / deterministic)",
       main="Deviation of stochastic mean trend from deterministic model",
       ylim=ylim)
  
  lines(time, deviation[[target_conds[2]]], lwd=2, lty=2)
  
  abline(h=1, lty=3)
  
  legend("topright",
         legend=c(label_map[target_conds[1]], label_map[target_conds[2]], "Perfect match (1.0)"),
         lty=c(1,2,3),
         lwd=c(2,2,1),
         bty="n")
  
  dev.off()
  
  # 6) decide which condition is closer to 1 on average
  score <- sapply(target_conds, function(cond){
    mean(abs(deviation[[cond]] - 1), na.rm=TRUE)
  })
  best_cond <- names(which.min(score))[1]
  
  return(paste(
    "It is more appropriate to approximate the average stochastic behaviour with a deterministic model for",
    label_map[best_cond], "because averaging across many simulations reduces random fluctuations, and this effect is stronger in the larger population.",
    "Therefore the deviation stays closer to 1 for the large mixed population than for the small mixed population."
  ))
}



# Section Two: Individual-based ecological neutral theory simulation 

# Question 7
species_richness <- function(community){
  length(unique(community))
}

# Question 8
init_community_max <- function(size){
  seq(1, size)
}

# Question 9
init_community_min <- function(size){
  rep(1, size)
}

# Question 10
choose_two <- function(max_value){
  sample(seq_len(max_value), size = 2, replace = FALSE)
}

# Question 11
neutral_step <- function(community){
  n <- length(community)
  idx <- choose_two(n)          # two different indices
  die <- idx[1]
  rep <- idx[2]
  community[die] <- community[rep]
  return(community)
}

# Question 12
neutral_generation <- function(community){
  
  x <- length(community)
  
  if(x %% 2 == 0){
    n_steps <- x / 2
  } else {
    n_steps <- sample(c(floor(x/2), ceiling(x/2)), size = 1)
  }
  
  for(i in seq_len(n_steps)){
    community <- neutral_step(community)
  }
  
  return(community)
}


# Question 13
neutral_time_series <- function(community, duration){
  
  rich <- numeric(duration + 1)
  rich[1] <- species_richness(community)
  
  for(g in seq_len(duration)){
    community <- neutral_generation(community)
    rich[g + 1] <- species_richness(community)
  }
  
  return(rich)
}

# Question 14
question_14 <- function(){
  
  set.seed(NULL)
  
  community0 <- init_community_max(100)
  duration <- 200
  
  richness_ts <- neutral_time_series(community = community0, duration = duration)
  
  time <- 0:duration
  
  png(filename = "results/question_14.png", width = 800, height = 500)
  plot(time, richness_ts,
       type = "l",
       xlab = "Generation",
       ylab = "Species richness",
       main = "Neutral model: species richness through time (N=100, max initial diversity)")
  dev.off()
  
  return(paste(
    "If you wait long enough, the system will converge to monodominance (species richness = 1).",
    "In a neutral model without speciation, species are lost by random drift: once a species goes extinct it cannot reappear,",
    "so eventually one species fixes in the community."
  ))
}


# Question 15
neutral_step_speciation <- function(community, speciation_rate){
  
  n <- length(community)
  idx <- choose_two(n)
  die <- idx[1]
  rep <- idx[2]
  
  if(runif(1) < speciation_rate){
    new_species <- max(community) + 1
    community[die] <- new_species
  } else {
    community[die] <- community[rep]
  }
  
  return(community)
}


# Question 16
neutral_generation_speciation <- function(community, speciation_rate){
  
  x <- length(community)
  
  if(x %% 2 == 0){
    n_steps <- x / 2
  } else {
    n_steps <- sample(c(floor(x/2), ceiling(x/2)), size = 1)
  }
  
  for(i in seq_len(n_steps)){
    community <- neutral_step_speciation(community = community,
                                         speciation_rate = speciation_rate)
  }
  
  return(community)
}


# Question 17
neutral_time_series_speciation <- function(community, duration, speciation_rate){
  
  rich <- numeric(duration + 1)
  rich[1] <- species_richness(community)
  
  for(g in seq_len(duration)){
    community <- neutral_generation_speciation(community = community,
                                               speciation_rate = speciation_rate)
    rich[g + 1] <- species_richness(community)
  }
  
  return(rich)
}

# Question 18
question_18 <- function(){
  
  set.seed(NULL)
  
  speciation_rate <- 0.1
  N <- 100
  duration <- 200
  
  comm_max <- init_community_max(N)
  comm_min <- init_community_min(N)
  
  ts_max <- neutral_time_series_speciation(
    community = comm_max,
    duration = duration,
    speciation_rate = speciation_rate
  )
  
  ts_min <- neutral_time_series_speciation(
    community = comm_min,
    duration = duration,
    speciation_rate = speciation_rate
  )
  
  time <- 0:duration
  
  png(filename = "results/question_18.png", width = 850, height = 520)
  
  plot(time, ts_max,
       type = "l", lwd = 2,
       xlab = "Generation",
       ylab = "Species richness",
       main = "Neutral model with speciation: richness through time (N=100, speciation rate=0.1)",
       ylim = range(c(ts_max, ts_min))
  )
  
  lines(time, ts_min, lwd = 2, lty = 2)
  
  legend("topright",
         legend = c("Max initial diversity", "Min initial diversity"),
         lty = c(1, 2),
         lwd = 2,
         bty = "n")
  
  dev.off()
  
  return(paste(
    "From the plot, the effect of the initial condition is temporary. The simulation starting at maximal diversity (richness = 100) rapidly loses species and drops to a moderate richness level, while the simulation starting at minimal diversity (richness = 1) quickly gains species. After enough generations, both trajectories fluctuate around a similar long-term richness (roughly 20–35 in this run).",
    "This happens because the neutral model with speciation has two opposing processes: demographic drift removes species (once extinct they are gone from the community), while speciation introduces brand new species. When richness is very high, many species are rare and are easily lost by drift, so richness declines. When richness is very low, speciation adds new species faster than drift removes them, so richness increases. The system therefore approaches a stochastic equilibrium determined mainly by community size and the speciation rate, rather than by the initial condition."
  ))
}


# Question 19
species_abundance <- function(community){
  abund <- table(community)                 # counts per species
  abund_sorted <- sort(as.numeric(abund), decreasing = TRUE)
  return(abund_sorted)
}

# Question 20
octaves <- function(abundances){
  
  if(length(abundances) == 0){
    return(integer(0))
  }
  
  if(any(abundances <= 0)){
    stop("octaves error: abundances must be positive integers.")
  }
  
  oct <- floor(log(abundances, base = 2)) + 1
  out <- tabulate(oct, nbins = max(oct))
  return(out)
}


# Question 21
sum_vect <- function(x, y){
  
  lx <- length(x)
  ly <- length(y)
  
  if(lx < ly){
    x <- c(x, rep(0, ly - lx))
  } else if(ly < lx){
    y <- c(y, rep(0, lx - ly))
  }
  
  return(x + y)
}

# Question 22
question_22 <- function(){
  
  set.seed(NULL)
  
  N <- 100
  speciation_rate <- 0.1
  
  burn_in <- 200
  duration <- 2000
  sample_every <- 20
  
  # number of recordings: time 0 plus every 20 generations to 2000
  n_records <- duration / sample_every + 1
  
  collect_mean_octaves <- function(init_fun){
    
    community <- init_fun(N)
    
    # burn-in
    for(g in seq_len(burn_in)){
      community <- neutral_generation_speciation(community = community,
                                                 speciation_rate = speciation_rate)
    }
    
    # record octave vectors and accumulate
    sum_oct <- integer(0)
    
    # record at time 0 (immediately after burn-in)
    ab <- species_abundance(community)
    oc <- octaves(ab)
    sum_oct <- sum_vect(sum_oct, oc)
    
    # continue simulation and record every 20 generations
    for(step_block in seq_len(duration / sample_every)){
      for(g in seq_len(sample_every)){
        community <- neutral_generation_speciation(community = community,
                                                   speciation_rate = speciation_rate)
      }
      ab <- species_abundance(community)
      oc <- octaves(ab)
      sum_oct <- sum_vect(sum_oct, oc)
    }
    
    mean_oct <- sum_oct / n_records
    return(mean_oct)
  }
  
  mean_oct_max <- collect_mean_octaves(init_community_max)
  mean_oct_min <- collect_mean_octaves(init_community_min)
  
  # make both vectors same length for plotting
  L <- max(length(mean_oct_max), length(mean_oct_min))
  if(length(mean_oct_max) < L) mean_oct_max <- c(mean_oct_max, rep(0, L - length(mean_oct_max)))
  if(length(mean_oct_min) < L) mean_oct_min <- c(mean_oct_min, rep(0, L - length(mean_oct_min)))
  
  png("results/question_22.png", width = 1000, height = 500)
  par(mfrow = c(1, 2), mar = c(5, 5, 4, 1))
  
  barplot(mean_oct_max,
          xlab = "Octave class",
          ylab = "Mean number of species",
          main = "Mean SAD (octaves)\nMax initial richness",
          names.arg = seq_len(L),
          las = 1)
  
  barplot(mean_oct_min,
          xlab = "Octave class",
          ylab = "Mean number of species",
          main = "Mean SAD (octaves)\nMin initial richness",
          names.arg = seq_len(L),
          las = 1)
  
  dev.off()
  
  return(paste(
    "The two panels show that the mean octave species-abundance distributions after burn-in are almost identical for the max- and min-diversity initial conditions.",
    "This indicates that the initial condition does not matter for the long-term SAD: after enough generations the system approaches a dynamic equilibrium.",
    "In the neutral model with speciation, drift continually removes species while speciation introduces new ones. After burn-in, this balance produces a stationary abundance distribution mainly determined by community size (N=100) and the speciation rate (0.1), so the starting state only affects the early transient dynamics."
  ))
  
}

# Question 23
neutral_cluster_run <- function(speciation_rate,
                                size,
                                wall_time,
                                interval_rich,
                                interval_oct,
                                burn_in_generations,
                                output_file_name){
  
  # initial community: minimal diversity
  community <- init_community_min(size)
  
  # timers (proc.time returns seconds)
  start_time <- proc.time()[["elapsed"]]
  wall_seconds <- wall_time * 60
  
  # storage
  time_series <- numeric(0)
  time_points_rich <- integer(0)
  
  abundance_list <- list()
  time_points_oct <- integer(0)
  
  generation <- 0
  
  repeat {
    
    # check time limit BEFORE doing next generation
    elapsed <- proc.time()[["elapsed"]] - start_time
    if(elapsed >= wall_seconds) break
    
    # advance one generation with speciation
    community <- neutral_generation_speciation(community = community,
                                               speciation_rate = speciation_rate)
    generation <- generation + 1
    
    # record richness only during burn-in
    if(generation <= burn_in_generations){
      if(generation %% interval_rich == 0){
        time_series <- c(time_series, species_richness(community))
        time_points_rich <- c(time_points_rich, generation)
      }
    }
    
    # record octave SAD for entire run
    if(generation %% interval_oct == 0){
      ab <- species_abundance(community)
      oc <- octaves(ab)
      abundance_list[[length(abundance_list) + 1]] <- oc
      time_points_oct <- c(time_points_oct, generation)
    }
  }
  
  total_time <- proc.time()[["elapsed"]] - start_time
  community_end <- community
  
  # save required outputs + parameters (except output_file_name)
  save(time_series,
       abundance_list,
       community_end,
       total_time,
       speciation_rate,
       size,
       wall_time,
       interval_rich,
       interval_oct,
       burn_in_generations,
       generation,
       time_points_rich,
       time_points_oct,
       file = output_file_name)
  
  return(invisible(NULL))
}


# Questions 24 and 25 involve writing code elsewhere to run your simulations on
# the cluster

# Question 26 
process_neutral_cluster_results <- function(){
  
  files <- list.files("data",
                      pattern="^neutral_results_iter_\\d+_N_\\d+\\.rda$",
                      full.names=TRUE)
  if(length(files) == 0) stop("No neutral_results_iter_*_N_*.rda files found in data/")
  
  target_sizes <- c(500, 1000, 2500, 5000)
  
  sum_by_size <- setNames(vector("list", length(target_sizes)), as.character(target_sizes))
  n_by_size <- setNames(rep(0, length(target_sizes)), as.character(target_sizes))
  for(s in target_sizes) sum_by_size[[as.character(s)]] <- numeric(0)
  
  mean_oct_one_file <- function(env){
    burn <- get("burn_in_generations", env)
    ab_list <- get("abundance_list", env)
    t_oct <- get("time_points_oct", env)
    
    m <- min(length(ab_list), length(t_oct))
    ab_list <- ab_list[seq_len(m)]
    t_oct <- t_oct[seq_len(m)]
    
    idx <- which(t_oct > burn)
    if(length(idx) == 0) return(NULL)
    
    svec <- numeric(0)
    for(i in idx){
      svec <- sum_vect(svec, ab_list[[i]])
    }
    svec / length(idx)
  }
  
  for(f in files){
    env <- new.env()
    load(f, envir=env)
    
    if(!exists("size", env) ||
       !exists("burn_in_generations", env) ||
       !exists("abundance_list", env) ||
       !exists("time_points_oct", env)) next
    
    sz <- get("size", env)
    if(!(sz %in% target_sizes)) next
    
    mvec <- mean_oct_one_file(env)
    if(is.null(mvec)) next
    
    key <- as.character(sz)
    sum_by_size[[key]] <- sum_vect(sum_by_size[[key]], mvec)
    n_by_size[key] <- n_by_size[key] + 1
  }
  
  # average across simulations (should be 25 each if all present)
  neutral_cluster_summary <- list()
  for(s in target_sizes){
    key <- as.character(s)
    if(n_by_size[key] == 0){
      neutral_cluster_summary[[key]] <- numeric(0)
    } else {
      neutral_cluster_summary[[key]] <- sum_by_size[[key]] / n_by_size[key]
    }
  }
  
  if(!dir.exists("results")) stop("results/ folder not found.")
  save(neutral_cluster_summary, n_by_size, file="results/neutral_cluster_summary.rda")
  
  return(neutral_cluster_summary)
}

plot_neutral_cluster_results <- function(){
  
  summary_file <- "results/neutral_cluster_summary.rda"
  if(!file.exists(summary_file)){
    stop(summary_file, " not found. Run process_neutral_cluster_results() first.")
  }
  
  load(summary_file)  # should load neutral_cluster_summary
  
  if(!exists("neutral_cluster_summary")){
    stop("neutral_cluster_summary not found inside ", summary_file)
  }
  
  sizes <- c("500", "1000", "2500", "5000")
  
  png(file.path("results", "plot_neutral_cluster_results.png"),
      width = 1100, height = 800)
  par(mfrow = c(2, 2), mar = c(5, 5, 4, 1))
  
  for(k in sizes){
    v <- neutral_cluster_summary[[k]]
    if(is.null(v) || length(v) == 0){
      plot.new()
      title(main = paste("N =", k, "(no data)"))
      next
    }
    
    barplot(v,
            names.arg = seq_len(length(v)),
            xlab = "Octave class",
            ylab = "Mean number of species",
            main = paste("Mean SAD (post burn-in), N =", k),
            las = 1)
  }
  
  dev.off()
  
  return(invisible(neutral_cluster_summary))
}


# Challenge questions - these are substantially harder and worth fewer marks.
# I suggest you only attempt these if you've done all the main questions. 

# Challenge question A
Challenge_A <- function() {
  
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("ggplot2 is required for Challenge_A.")
  }
  
  files <- list.files("data", pattern = "^demographic_.*\\.rda$", full.names = TRUE)
  if (length(files) == 0) stop("No .rda files found in data/ (pattern demographic_*.rda).")
  
  # First pass: get simulation length and total number of simulations
  tmp_env <- new.env(parent = emptyenv())
  load(files[1], envir = tmp_env)
  if (!exists("results", envir = tmp_env)) stop("Object 'results' not found in the first .rda file.")
  sim_len <- length(tmp_env$results[[1]]) - 1
  rm(tmp_env)
  
  total_sims <- 0L
  for (f in files) {
    e <- new.env(parent = emptyenv())
    load(f, envir = e)
    total_sims <- total_sims + length(e$results)
    rm(e)
  }
  
  total_rows <- (sim_len + 1L) * total_sims
  
  time_step <- integer(total_rows)
  population_size <- numeric(total_rows)
  simulation_number <- integer(total_rows)
  initial_condition_vec <- character(total_rows)
  
  k <- 1L
  sim_id <- 0L
  
  for (f in files) {
    e <- new.env(parent = emptyenv())
    load(f, envir = e)
    
    ic_raw <- e$initial_condition
    ic_label <- gsub("_", " ", ic_raw)
    
    res_list <- e$results
    for (j in seq_along(res_list)) {
      sim_id <- sim_id + 1L
      vec <- res_list[[j]]
      
      idx_end <- k + sim_len
      idx <- k:idx_end
      
      time_step[idx] <- 0:sim_len
      population_size[idx] <- vec
      simulation_number[idx] <- sim_id
      initial_condition_vec[idx] <- ic_label
      
      k <- idx_end + 1L
    }
    
    rm(e)
  }
  
  population_size_df <- data.frame(
    simulation_number = simulation_number,
    initial_condition = initial_condition_vec,
    time_step = time_step,
    population_size = population_size,
    stringsAsFactors = FALSE
  )
  
  assign("population_size_df", population_size_df, envir = .GlobalEnv)
  
  if (!dir.exists("results")) dir.create("results", recursive = TRUE)
  
  p <- ggplot2::ggplot(
    population_size_df,
    ggplot2::aes(
      x = time_step,
      y = population_size,
      group = simulation_number,
      colour = initial_condition
    )
  ) +
    ggplot2::geom_line(alpha = 0.1) +
    ggplot2::labs(
      title = "Challenge A: All stochastic population size trajectories",
      x = "Time step",
      y = "Population size",
      colour = "Initial condition"
    ) +
    ggplot2::theme_bw()
  
  png(filename = "results/Challenge_A.png", width = 900, height = 550)
  print(p)
  dev.off()
  
  return(population_size_df)
}

# Challenge question B
Challenge_B <- function(){
  
  set.seed(NULL)
  
  N <- 100
  speciation_rate <- 0.1
  
  burn_in <- 200
  duration <- 2000
  sample_every <- 20
  times <- seq(0, duration, by = sample_every)
  n_times <- length(times)
  
  n_reps <- 50  # number of repeat simulations
  
  simulate_richness_path <- function(init_fun){
    community <- init_fun(N)
    
    # burn-in
    for(g in seq_len(burn_in)){
      community <- neutral_generation_speciation(community, speciation_rate)
    }
    
    # record richness over time
    rich <- numeric(n_times)
    rich[1] <- species_richness(community)
    
    if(duration > 0){
      idx <- 2
      for(block in seq_len(duration / sample_every)){
        for(g in seq_len(sample_every)){
          community <- neutral_generation_speciation(community, speciation_rate)
        }
        rich[idx] <- species_richness(community)
        idx <- idx + 1
      }
    }
    
    return(rich)
  }
  
  # run repeats for both initial conditions
  mat_max <- matrix(NA_real_, nrow = n_reps, ncol = n_times)
  mat_min <- matrix(NA_real_, nrow = n_reps, ncol = n_times)
  
  for(r in seq_len(n_reps)){
    mat_max[r, ] <- simulate_richness_path(init_community_max)
    mat_min[r, ] <- simulate_richness_path(init_community_min)
  }
  
  mean_max <- colMeans(mat_max)
  mean_min <- colMeans(mat_min)
  
  # 97.2% CI = central 97.2% => tails 1.4% each side
  lo_max <- apply(mat_max, 2, quantile, probs = 0.014, na.rm = TRUE)
  hi_max <- apply(mat_max, 2, quantile, probs = 0.986, na.rm = TRUE)
  lo_min <- apply(mat_min, 2, quantile, probs = 0.014, na.rm = TRUE)
  hi_min <- apply(mat_min, 2, quantile, probs = 0.986, na.rm = TRUE)
  
  # estimate equilibrium time: when mean curves become close and stay close
  diff <- abs(mean_max - mean_min)
  tol <- 1.0
  k <- 5  # consecutive points required
  eq_gen <- duration
  
  if(n_times >= k){
    for(i in seq_len(n_times - k + 1)){
      if(all(diff[i:(i + k - 1)] < tol)){
        eq_gen <- times[i]
        break
      }
    }
  }
  
  # plot
  png("results/Challenge_B.png", width = 900, height = 550)
  par(mar = c(5, 5, 4, 2))
  
  ylim <- range(c(lo_max, hi_max, lo_min, hi_min), na.rm = TRUE)
  
  plot(times, mean_max, type = "n",
       xlab = "Generation (post burn-in sampling window)",
       ylab = "Species richness",
       main = "Mean species richness with 97.2% CI (N=100, speciation rate=0.1)",
       ylim = ylim)
  
  # max initial richness
  lines(times, mean_max, lwd = 2)
  lines(times, lo_max, lty = 2)
  lines(times, hi_max, lty = 2)
  
  # min initial richness
  lines(times, mean_min, lwd = 2, lty = 3)
  lines(times, lo_min, lty = 4)
  lines(times, hi_min, lty = 4)
  
  abline(v = eq_gen, lty = 5)
  
  legend("topright",
         legend = c("Mean (max init)", "CI (max init)",
                    "Mean (min init)", "CI (min init)",
                    "Estimated equilibrium"),
         lty = c(1, 2, 3, 4, 5),
         lwd = c(2, 1, 2, 1, 1),
         bty = "n")
  
  dev.off()
  
  return(paste(
    "Estimated dynamic equilibrium is reached after approximately",
    eq_gen,
    "generations (post burn-in sampling window), when the mean richness trajectories from different initial conditions become indistinguishable within tolerance and remain stable."
  ))
}



# Challenge question C
Challenge_C <- function(){
  
  set.seed(NULL)
  
  N <- 100
  speciation_rate <- 0.1
  
  burn_in <- 200
  duration <- 2000
  sample_every <- 20
  times <- seq(0, duration, by = sample_every)
  n_times <- length(times)
  
  # range of initial richness values to explore
  K_vals <- c(1, 2, 5, 10, 20, 40, 60, 80, 100)
  
  reps_per_K <- 30
  
  init_community_uniformK <- function(N, K){
    sample(seq_len(K), size = N, replace = TRUE)
  }
  
  simulate_richness_path_from_comm <- function(community){
    # burn-in
    for(g in seq_len(burn_in)){
      community <- neutral_generation_speciation(community, speciation_rate)
    }
    
    rich <- numeric(n_times)
    rich[1] <- species_richness(community)
    
    if(duration > 0){
      idx <- 2
      for(block in seq_len(duration / sample_every)){
        for(g in seq_len(sample_every)){
          community <- neutral_generation_speciation(community, speciation_rate)
        }
        rich[idx] <- species_richness(community)
        idx <- idx + 1
      }
    }
    
    return(rich)
  }
  
  mean_paths <- matrix(NA_real_, nrow = length(K_vals), ncol = n_times)
  
  for(i in seq_along(K_vals)){
    K <- K_vals[i]
    mat <- matrix(NA_real_, nrow = reps_per_K, ncol = n_times)
    
    for(r in seq_len(reps_per_K)){
      comm0 <- init_community_uniformK(N, K)
      mat[r, ] <- simulate_richness_path_from_comm(comm0)
    }
    
    mean_paths[i, ] <- colMeans(mat)
  }
  
  # plot
  png("results/Challenge_C.png", width = 950, height = 600)
  par(mar = c(5, 5, 4, 2))
  
  ylim <- range(mean_paths, na.rm = TRUE)
  plot(times, mean_paths[1, ], type = "n",
       xlab = "Generation (post burn-in sampling window)",
       ylab = "Mean species richness",
       main = "Mean richness trajectories for different initial richness values\n(N=100, speciation rate=0.1)",
       ylim = ylim)
  
  # multiple lines, distinguish by lty
  ltys <- rep(1:6, length.out = length(K_vals))
  lwds <- rep(2, length(K_vals))
  
  for(i in seq_along(K_vals)){
    lines(times, mean_paths[i, ], lwd = lwds[i], lty = ltys[i])
  }
  
  legend("topright",
         legend = paste0("Initial K=", K_vals),
         lty = ltys,
         lwd = lwds,
         bty = "n")
  
  dev.off()
  
  return("Challenge_C.png saved: mean richness trajectories across a range of initial richness values.")
}


# Challenge question D
Challenge_D <- function(){
  
  files <- list.files("data",
                      pattern="^neutral_results_iter_\\d+_N_\\d+\\.rda$",
                      full.names=TRUE)
  if(length(files) == 0){
    stop("No cluster .rda files found in data/.")
  }
  if(!dir.exists("results")){
    stop("results/ folder not found.")
  }
  
  target_sizes <- c(500, 1000, 2500, 5000)
  
  # size -> list of runs, each run is list(tp, ts)
  by_size <- setNames(vector("list", length(target_sizes)), as.character(target_sizes))
  for(k in names(by_size)) by_size[[k]] <- list()
  
  # ---- read all files ----
  for(f in files){
    e <- new.env()
    load(f, envir = e)
    
    if(!exists("size", e) ||
       !exists("time_series", e) ||
       !exists("time_points_rich", e)){
      next
    }
    
    sz <- get("size", e)
    if(!(sz %in% target_sizes)) next
    
    ts <- get("time_series", e)
    tp <- get("time_points_rich", e)
    
    if(length(ts) == 0 || length(tp) == 0) next
    m <- min(length(ts), length(tp))
    ts <- ts[seq_len(m)]
    tp <- tp[seq_len(m)]
    
    by_size[[as.character(sz)]][[length(by_size[[as.character(sz)]]) + 1]] <- list(tp = tp, ts = ts)
  }
  
  # ---- summarise runs (align to common time grid) ----
  summarise_rich <- function(rec_list){
    all_tp <- sort(unique(unlist(lapply(rec_list, function(z) z$tp))))
    mat <- matrix(NA_real_, nrow = length(rec_list), ncol = length(all_tp))
    colnames(mat) <- as.character(all_tp)
    
    for(i in seq_along(rec_list)){
      tp <- rec_list[[i]]$tp
      ts <- rec_list[[i]]$ts
      idx <- match(tp, all_tp)
      mat[i, idx] <- ts
    }
    
    mu <- apply(mat, 2, mean, na.rm = TRUE)
    lo <- apply(mat, 2, quantile, probs = 0.014, na.rm = TRUE)  # 97.2% band
    hi <- apply(mat, 2, quantile, probs = 0.986, na.rm = TRUE)
    
    list(tp = all_tp, mean = mu, lo = lo, hi = hi)
  }
  
  # ---- estimate burn-in end from stabilisation of mean curve ----
  estimate_burnin <- function(tp, mu){
    if(length(mu) < 20) return(NA_integer_)
    d <- abs(diff(mu))
    tol <- max(1, 0.005 * max(mu, na.rm = TRUE))  # 0.5% of max, at least 1
    k <- 10
    for(i in seq_len(length(d) - k + 1)){
      if(all(d[i:(i + k - 1)] < tol)){
        return(tp[i + 1])
      }
    }
    tp[length(tp)]
  }
  
  summaries <- list()
  burn_est <- setNames(rep(NA_integer_, length(target_sizes)), as.character(target_sizes))
  n_by_size <- setNames(rep(0L, length(target_sizes)), as.character(target_sizes))
  
  out_png <- file.path("results", "Challenge_D.png")
  png(out_png, width = 1100, height = 800)
  par(mfrow = c(2, 2), mar = c(5, 5, 4, 1))
  
  for(sz in target_sizes){
    key <- as.character(sz)
    recs <- by_size[[key]]
    n_by_size[key] <- length(recs)
    
    if(length(recs) == 0){
      plot.new()
      title(main = paste("N =", key, "(no data)"))
      next
    }
    
    s <- summarise_rich(recs)
    summaries[[key]] <- s
    burn_est[key] <- estimate_burnin(s$tp, s$mean)
    
    # downsample points for readability on very long burn-ins
    step <- max(1, floor(length(s$tp) / 2000))
    idx <- seq(1, length(s$tp), by = step)
    tp <- s$tp[idx]
    mu <- s$mean[idx]
    lo <- s$lo[idx]
    hi <- s$hi[idx]
    
    ylim <- range(c(lo, hi), na.rm = TRUE)
    
    plot(tp, mu, type = "n",
         xlab = "Generation (burn-in)",
         ylab = "Species richness",
         main = paste("Mean richness during burn-in (N =", key, ")"),
         ylim = ylim)
    
    # shaded 97.2% band
    polygon(c(tp, rev(tp)),
            c(lo, rev(hi)),
            col = rgb(0, 0, 0, 0.12),
            border = NA)
    
    # mean + bounds (light)
    lines(tp, mu, lwd = 2)
    lines(tp, lo, lty = 2)
    lines(tp, hi, lty = 2)
    
    # estimated burn-in
    if(!is.na(burn_est[key])){
      abline(v = burn_est[key], lty = 3)
      legend("bottomright",
             legend = c("Mean", "97.2% band", paste("Estimated burn-in:", burn_est[key])),
             lty = c(1, 2, 3),
             lwd = c(2, 1, 1),
             bty = "n")
    } else {
      legend("bottomright",
             legend = c("Mean", "97.2% band"),
             lty = c(1, 2),
             lwd = c(2, 1),
             bty = "n")
    }
  }
  
  dev.off()
  
  txt <- paste(
    "Mean species richness rises rapidly from the minimal-diversity initial condition and then fluctuates around a stable mean,",
    "indicating convergence to a dynamic equilibrium. The 97.2% uncertainty band becomes approximately stationary after the initial",
    "transient, showing that the influence of the initial condition is effectively removed. Larger communities generally require longer",
    "absolute burn-in because drift and turnover act on longer timescales, but the cluster burn-in choice (8×N generations) is conservative",
    "and sufficient for all sizes. Estimated stabilisation times (generations):",
    paste(paste0("N=", target_sizes, " ~ ", burn_est[as.character(target_sizes)]), collapse = "; "),
    ". Files read per size:",
    paste(paste0("N=", target_sizes, ":", n_by_size[as.character(target_sizes)]), collapse = "; "),
    "."
  )
  
  return(txt)
}

# Challenge question E
# Coalescence simulation for equilibrium abundances
coalescence_abundances <- function(J, v){
  if(J <= 0) stop("J must be > 0")
  if(v <= 0 || v >= 1) stop("v must be between 0 and 1 (not equal to 0 or 1)")
  
  lineages <- rep(1L, J)
  abundances <- integer(0)
  
  N <- J
  theta <- v * (J - 1) / (1 - v)
  
  while(N > 1){
    j <- sample.int(N, 1)
    randnum <- runif(1)
    
    if(randnum < theta / (theta + N - 1)){
      abundances <- c(abundances, lineages[j])
      lineages <- lineages[-j]
      N <- N - 1
    } else {
      # pick i != j
      i <- sample.int(N - 1, 1)
      if(i >= j) i <- i + 1
      
      lineages[i] <- lineages[i] + lineages[j]
      lineages <- lineages[-j]
      N <- N - 1
    }
  }
  
  abundances <- c(abundances, lineages[1])
  sort(abundances, decreasing=TRUE)
}

Challenge_E <- function(){
  
  # Load processed cluster summary
  summary_file <- file.path("results", "neutral_cluster_summary.rda")
  if(!file.exists(summary_file)){
    stop("Need cluster summary first: run process_neutral_cluster_results() to create ", summary_file)
  }
  load(summary_file)  # expects neutral_cluster_summary (and maybe n_by_size)
  
  if(!exists("neutral_cluster_summary")) stop("neutral_cluster_summary not found inside summary file")
  
  target_sizes <- c(500, 1000, 2500, 5000)
  
  v <- 0.5
  
  n_reps <- 25
  
  # Compute coalescence mean octaves for each size
  coalescence_mean <- list()
  coalescence_cpu_hours <- 0
  
  t0 <- proc.time()[["elapsed"]]
  for(J in target_sizes){
    sum_oct <- numeric(0)
    for(r in seq_len(n_reps)){
      ab <- coalescence_abundances(J, v)
      oc <- octaves(ab)
      sum_oct <- sum_vect(sum_oct, oc)
    }
    coalescence_mean[[as.character(J)]] <- sum_oct / n_reps
  }
  t1 <- proc.time()[["elapsed"]]
  coalescence_cpu_hours <- (t1 - t0) / 3600
  
  # Estimate cluster CPU hours from rda files (sum total_time across runs)
  files <- list.files("data",
                      pattern="^neutral_results_iter_\\d+_N_\\d+\\.rda$",
                      full.names=TRUE)
  cluster_cpu_hours <- NA_real_
  if(length(files) > 0){
    total_seconds <- 0
    n_ok <- 0
    for(f in files){
      e <- new.env()
      load(f, envir=e)
      if(exists("total_time", e)){
        total_seconds <- total_seconds + get("total_time", e)
        n_ok <- n_ok + 1
      }
    }
    if(n_ok > 0) cluster_cpu_hours <- total_seconds / 3600
  }
  
  # Plot comparison (cluster vs coalescence) in 2x2 panels
  out_png <- file.path("results", "Challenge_E.png")
  png(out_png, width=1200, height=850)
  par(mfrow=c(2,2), mar=c(5,5,4,1))
  
  for(J in target_sizes){
    key <- as.character(J)
    v_cluster <- neutral_cluster_summary[[key]]
    v_coal <- coalescence_mean[[key]]
    
    if(is.null(v_cluster) || length(v_cluster)==0 || is.null(v_coal) || length(v_coal)==0){
      plot.new()
      title(main=paste("N =", key, "(no data)"))
      next
    }
    
    L <- max(length(v_cluster), length(v_coal))
    if(length(v_cluster) < L) v_cluster <- c(v_cluster, rep(0, L - length(v_cluster)))
    if(length(v_coal) < L) v_coal <- c(v_coal, rep(0, L - length(v_coal)))
    
    mat <- rbind(v_cluster, v_coal)
    barplot(mat, beside=TRUE,
            names.arg=seq_len(L),
            xlab="Octave class",
            ylab="Mean number of species",
            main=paste("Cluster vs coalescence SAD (N =", key, ")"),
            las=1)
    legend("topright", legend=c("Cluster", "Coalescence"), bty="n")
  }
  
  dev.off()
  
  ans <- paste(
    "Coalescence CPU hours (this run):", round(coalescence_cpu_hours, 4), ".",
    if(is.na(cluster_cpu_hours)) "Cluster CPU hours could not be estimated (total_time missing)." else paste("Cluster CPU hours (sum of total_time across .rda files):", round(cluster_cpu_hours, 2), "."),
    "Coalescence is much faster because it samples the equilibrium species abundance distribution directly by tracing lineages backward, avoiding explicit forward-time simulation over many generations and burn-in."
  )
  
  return(ans)
}

