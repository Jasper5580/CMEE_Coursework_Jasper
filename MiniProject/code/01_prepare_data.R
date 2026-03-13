source(here::here("code", "00_setup.R"))

library(readr)
library(dplyr)
library(stringr)

infile <- here::here("data", "logistic_growth_data.csv")

dat_raw <- readr::read_csv(infile, show_col_types = FALSE)

# Trim potential whitespace in column names (safe)
names(dat_raw) <- stringr::str_trim(names(dat_raw))

required_cols <- c(
  "Time", "PopBio", "Temp", "Time_units", "PopBio_units",
  "Species", "Medium", "Rep", "Citation"
)

missing_cols <- setdiff(required_cols, names(dat_raw))
if (length(missing_cols) > 0) {
  stop("Missing columns in logistic_growth_data.csv: ", paste(missing_cols, collapse = ", "))
}

dat <- dat_raw %>%
  mutate(
    Time = readr::parse_number(as.character(Time)),
    PopBio = readr::parse_number(as.character(PopBio)),
    Temp = readr::parse_number(as.character(Temp)),
    Rep = as.character(Rep),
    Species = as.character(Species),
    Medium = as.character(Medium),
    Citation = as.character(Citation),
    Time_units = as.character(Time_units),
    PopBio_units = as.character(PopBio_units)
  ) %>%
  filter(is.finite(Time), is.finite(PopBio)) %>%
  mutate(
    # Each unique growth curve is identified by Species + Temp + Medium + Citation + Rep
    curve_id = paste(Species, Temp, Medium, Citation, Rep, sep = "_")
  ) %>%
  group_by(curve_id) %>%
  mutate(curve_num = cur_group_id()) %>%
  ungroup()

# If there are repeated measurements at the same Time for a curve, average them
dat <- dat %>%
  group_by(curve_num, Time) %>%
  summarise(
    PopBio = mean(PopBio, na.rm = TRUE),
    Temp = dplyr::first(Temp),
    Time_units = dplyr::first(Time_units),
    PopBio_units = dplyr::first(PopBio_units),
    Species = dplyr::first(Species),
    Medium = dplyr::first(Medium),
    Rep = dplyr::first(Rep),
    Citation = dplyr::first(Citation),
    curve_id = dplyr::first(curve_id),
    .groups = "drop"
  ) %>%
  arrange(curve_num, Time)

curve_lookup <- dat %>%
  distinct(curve_num, curve_id, Species, Temp, Medium, Rep, Citation, Time_units, PopBio_units) %>%
  arrange(curve_num)

curve_summary <- dat %>%
  group_by(curve_num) %>%
  summarise(
    n_points = n(),
    n_unique_time = n_distinct(Time),
    time_min = min(Time),
    time_max = max(Time),
    pop_min = min(PopBio),
    pop_max = max(PopBio),
    PopBio_units = dplyr::first(PopBio_units),
    .groups = "drop"
  ) %>%
  arrange(curve_num)

readr::write_csv(dat, here::here("results", "clean", "growth_clean.csv"))
readr::write_csv(curve_lookup, here::here("results", "clean", "curve_lookup.csv"))
readr::write_csv(curve_summary, here::here("results", "tables", "curve_summary.csv"))

message("01_prepare_data.R finished.")
message("Wrote: results/clean/growth_clean.csv")
message("Wrote: results/clean/curve_lookup.csv")
message("Wrote: results/tables/curve_summary.csv")