source(here::here("code", "00_setup.R"))

library(readr)
library(dplyr)
library(ggplot2)
library(stringr)

infile <- here::here("results", "clean", "growth_clean.csv")
dat <- readr::read_csv(infile, show_col_types = FALSE)

# output dir
out_dir <- here::here("results", "figures", "explore")
if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)

# ---------- (1) Basic dataset overview ----------
units_summary <- dat %>%
  count(PopBio_units, name = "n_rows") %>%
  arrange(desc(n_rows))

readr::write_csv(units_summary, here::here("results", "tables", "eda_units_summary.csv"))

# ---------- (2) Curve-level QC flags ----------
curve_flags <- dat %>%
  group_by(curve_num) %>%
  summarise(
    n_points = n(),
    n_unique_time = n_distinct(Time),
    time_min = min(Time),
    time_max = max(Time),
    pop_min = min(PopBio),
    pop_max = max(PopBio),
    PopBio_units = first(PopBio_units),
    has_nonpositive = any(PopBio <= 0),
    # simple "decline" flag: last value < 0.9 * max value (rough indicator of death phase)
    has_decline = (dplyr::last(PopBio[order(Time)]) < 0.9 * max(PopBio)),
    .groups = "drop"
  ) %>%
  arrange(curve_num)

readr::write_csv(curve_flags, here::here("results", "tables", "eda_curve_flags.csv"))

# ---------- (3) Random sample: 20 curves scatter, faceted by units ----------
# ---------- (3) Random sample: 20 curves scatter, faceted by units ----------
set.seed(1)

sample_candidates <- curve_flags %>%
  group_by(PopBio_units) %>%
  group_modify(~ slice_sample(.x, n = min(20, nrow(.x)), replace = FALSE)) %>%
  ungroup()

sample_curves <- sample_candidates %>%
  slice_sample(n = min(20, nrow(sample_candidates)), replace = FALSE) %>%
  pull(curve_num)

p_sample <- dat %>%
  filter(curve_num %in% sample_curves) %>%
  ggplot(aes(x = Time, y = PopBio)) +
  geom_point(size = 1, alpha = 0.8) +
  facet_grid(PopBio_units ~ curve_num, scales = "free_y") +
  theme_bw() +
  labs(title = "Random sample of 20 growth curves (points only)",
       x = "Time", y = "PopBio")

ggsave(filename = file.path(out_dir, "eda_sample20_points.pdf"),
       plot = p_sample, width = 14, height = 8)

# ---------- (4) Spaghetti overview: all curves (free y by units) ----------
p_spaghetti <- dat %>%
  ggplot(aes(x = Time, y = PopBio, group = curve_num)) +
  geom_line(alpha = 0.08) +
  facet_wrap(~ PopBio_units, scales = "free_y") +
  theme_bw() +
  labs(title = "All curves overview (spaghetti plot)",
       x = "Time", y = "PopBio")

ggsave(filename = file.path(out_dir, "eda_all_spaghetti.pdf"),
       plot = p_spaghetti, width = 10, height = 6)

# ---------- (5) Log-scale look (only where PopBio > 0) ----------
p_log <- dat %>%
  filter(PopBio > 0, curve_num %in% sample_curves) %>%
  ggplot(aes(x = Time, y = log(PopBio))) +
  geom_point(size = 1, alpha = 0.8) +
  facet_grid(PopBio_units ~ curve_num, scales = "free_y") +
  theme_bw() +
  labs(title = "Same 20 curves on log scale (only PopBio > 0)",
       x = "Time", y = "log(PopBio)")

ggsave(filename = file.path(out_dir, "eda_sample20_log_points.pdf"),
       plot = p_log, width = 14, height = 8)

message("02_explore_vis.R finished.")
message("Figures -> results/figures/explore/")
message("Tables  -> results/tables/eda_units_summary.csv, eda_curve_flags.csv")