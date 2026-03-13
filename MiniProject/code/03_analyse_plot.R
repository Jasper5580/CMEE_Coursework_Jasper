source(here::here("code", "00_setup.R"))

library(readr)
library(dplyr)
library(tidyr)
library(purrr)
library(ggplot2)

MAX_PLOTS <- Inf
SET_SEED <- 1
PLOT_WIDTH <- 7
PLOT_HEIGHT <- 5

data_file  <- here::here("results", "clean", "growth_clean.csv")
fits_file  <- here::here("results", "fits", "model_fits.csv")
param_file <- here::here("results", "fits", "model_params.csv")
cfg_file   <- here::here("results", "fits", "fit_config.csv")

fig_dir <- here::here("results", "figures", "fits")
sum_fig_dir <- here::here("results", "figures", "summary")
if (!dir.exists(fig_dir)) dir.create(fig_dir, recursive = TRUE)
if (!dir.exists(sum_fig_dir)) dir.create(sum_fig_dir, recursive = TRUE)

logistic_fun <- function(t, N0, r, K) {
  K / (1 + ((K - N0) / N0) * exp(-r * t))
}

gompertz_fun <- function(t, y0, A, mu, lambda) {
  y0 + A * exp(-exp((mu * exp(1) / A) * (lambda - t) + 1))
}

dat <- readr::read_csv(data_file, show_col_types = FALSE) %>%
  mutate(
    Time = readr::parse_number(as.character(Time)),
    PopBio = readr::parse_number(as.character(PopBio)),
    Temp = readr::parse_number(as.character(Temp)),
    curve_num = as.integer(curve_num)
  ) %>%
  filter(is.finite(Time), is.finite(PopBio)) %>%
  group_by(curve_num) %>%
  arrange(Time, .by_group = TRUE) %>%
  mutate(t = Time - min(Time)) %>%
  ungroup()

fits <- readr::read_csv(fits_file, show_col_types = FALSE)
params <- readr::read_csv(param_file, show_col_types = FALSE)

if (file.exists(cfg_file)) {
  cfg <- readr::read_csv(cfg_file, show_col_types = FALSE)
  readr::write_csv(cfg, here::here("results", "tables", "fit_config_copied.csv"))
}

conv_summary <- fits %>%
  group_by(model) %>%
  summarise(
    n_total = n(),
    n_converged = sum(converged == 1, na.rm = TRUE),
    converge_rate = n_converged / n_total,
    .groups = "drop"
  ) %>%
  arrange(desc(converge_rate))

readr::write_csv(conv_summary, here::here("results", "tables", "convergence_summary.csv"))

best_by_aic <- fits %>%
  filter(converged == 1, is.finite(AIC)) %>%
  group_by(curve_num) %>%
  mutate(minAIC = min(AIC), deltaAIC = AIC - minAIC) %>%
  arrange(deltaAIC, .by_group = TRUE) %>%
  slice(1) %>%
  ungroup() %>%
  select(curve_num, curve_id, PopBio_units, best_model_AIC = model, AIC, deltaAIC, n, n_unique_time, k)

best_by_bic <- fits %>%
  filter(converged == 1, is.finite(BIC)) %>%
  group_by(curve_num) %>%
  mutate(minBIC = min(BIC), deltaBIC = BIC - minBIC) %>%
  arrange(deltaBIC, .by_group = TRUE) %>%
  slice(1) %>%
  ungroup() %>%
  select(curve_num, curve_id, PopBio_units, best_model_BIC = model, BIC, deltaBIC, n, n_unique_time, k)

readr::write_csv(best_by_aic, here::here("results", "tables", "best_model_by_curve_AIC.csv"))
readr::write_csv(best_by_bic, here::here("results", "tables", "best_model_by_curve_BIC.csv"))

win_aic <- best_by_aic %>% count(best_model_AIC, name = "n_curves") %>%
  mutate(prop = n_curves / sum(n_curves)) %>% arrange(desc(n_curves))
win_bic <- best_by_bic %>% count(best_model_BIC, name = "n_curves") %>%
  mutate(prop = n_curves / sum(n_curves)) %>% arrange(desc(n_curves))

readr::write_csv(win_aic, here::here("results", "tables", "model_win_counts_AIC.csv"))
readr::write_csv(win_bic, here::here("results", "tables", "model_win_counts_BIC.csv"))

p_win_aic <- ggplot(win_aic, aes(x = best_model_AIC, y = n_curves)) +
  geom_col() + theme_bw() +
  labs(title = "Model wins by AIC", x = "Model", y = "Number of curves")
p_win_bic <- ggplot(win_bic, aes(x = best_model_BIC, y = n_curves)) +
  geom_col() + theme_bw() +
  labs(title = "Model wins by BIC", x = "Model", y = "Number of curves")

ggsave(filename = file.path(sum_fig_dir, "model_wins_AIC.pdf"), plot = p_win_aic, width = 7, height = 4)
ggsave(filename = file.path(sum_fig_dir, "model_wins_BIC.pdf"), plot = p_win_bic, width = 7, height = 4)

param_wide <- params %>%
  mutate(param = as.character(param)) %>%
  pivot_wider(names_from = param, values_from = estimate)

make_pred_for_curve <- function(curve_id_num) {
  df_curve <- dat %>% filter(curve_num == curve_id_num) %>% arrange(Time)
  if (nrow(df_curve) == 0) return(tibble())
  
  t_min <- min(df_curve$t)
  t_max <- max(df_curve$t)
  if (!is.finite(t_min) || !is.finite(t_max) || t_max <= t_min) return(tibble())
  
  grid_t <- seq(t_min, t_max, length.out = 200)
  base_pred <- tibble(curve_num = curve_id_num, t = grid_t, Time = grid_t + min(df_curve$Time))
  
  f_this <- fits %>% filter(curve_num == curve_id_num, converged == 1)
  pred_list <- list()
  
  if (any(f_this$model == "quadratic")) {
    p <- param_wide %>% filter(curve_num == curve_id_num, model == "quadratic")
    if (nrow(p) == 1 && all(c("b0", "b1", "b2") %in% names(p))) {
      yhat <- p$b0 + p$b1 * base_pred$t + p$b2 * (base_pred$t^2)
      pred_list[["quadratic"]] <- base_pred %>% mutate(model = "quadratic", yhat = yhat)
    }
  }
  
  if (any(f_this$model == "cubic")) {
    p <- param_wide %>% filter(curve_num == curve_id_num, model == "cubic")
    if (nrow(p) == 1 && all(c("b0", "b1", "b2", "b3") %in% names(p))) {
      yhat <- p$b0 + p$b1 * base_pred$t + p$b2 * (base_pred$t^2) + p$b3 * (base_pred$t^3)
      pred_list[["cubic"]] <- base_pred %>% mutate(model = "cubic", yhat = yhat)
    }
  }
  
  if (any(f_this$model == "logistic")) {
    p <- param_wide %>% filter(curve_num == curve_id_num, model == "logistic")
    if (nrow(p) == 1 && all(c("N0", "r", "K") %in% names(p))) {
      yhat <- logistic_fun(base_pred$t, p$N0, p$r, p$K)
      pred_list[["logistic"]] <- base_pred %>% mutate(model = "logistic", yhat = yhat)
    }
  }
  
  if (any(f_this$model == "gompertz")) {
    p <- param_wide %>% filter(curve_num == curve_id_num, model == "gompertz")
    if (nrow(p) == 1 && all(c("y0", "A", "mu", "lambda") %in% names(p))) {
      yhat_log <- gompertz_fun(base_pred$t, p$y0, p$A, p$mu, p$lambda)
      yhat <- exp(yhat_log)
      pred_list[["gompertz"]] <- base_pred %>% mutate(model = "gompertz", yhat = yhat)
    }
  }
  
  bind_rows(pred_list)
}

curve_ids <- sort(unique(dat$curve_num))
if (is.finite(MAX_PLOTS) && MAX_PLOTS < length(curve_ids)) {
  set.seed(SET_SEED)
  curve_ids <- sample(curve_ids, size = MAX_PLOTS, replace = FALSE)
}

plot_one_curve <- function(curve_id_num) {
  df_curve <- dat %>% filter(curve_num == curve_id_num) %>% arrange(Time)
  df_pred <- make_pred_for_curve(curve_id_num)
  
  title_txt <- paste0("Curve ", curve_id_num,
                      " | Units: ", df_curve$PopBio_units[1],
                      " | Temp: ", df_curve$Temp[1])
  
  p <- ggplot(df_curve, aes(x = Time, y = PopBio)) +
    geom_point(size = 1, alpha = 0.85) +
    theme_bw() +
    labs(title = title_txt, x = "Time", y = "PopBio")
  
  if (nrow(df_pred) > 0) {
    p <- p +
      geom_line(data = df_pred,
                aes(x = Time, y = yhat, color = model, linetype = model),
                linewidth = 0.7, na.rm = TRUE)
  }
  
  out_file <- file.path(fig_dir, paste0("curve_", curve_id_num, ".pdf"))
  ggsave(filename = out_file, plot = p, width = PLOT_WIDTH, height = PLOT_HEIGHT)
}

purrr::walk(curve_ids, plot_one_curve)

message("03_analyse_plot.R finished.")
message("Figures: results/figures/fits/")
message("Summary figures: results/figures/summary/")
message("Tables: results/tables/")