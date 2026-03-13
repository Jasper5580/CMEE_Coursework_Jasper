source(here::here("code", "00_setup.R"))

library(readr)
library(dplyr)

fits  <- readr::read_csv(here::here("results","fits","model_fits.csv"), show_col_types = FALSE)
meta  <- readr::read_csv(here::here("results","clean","curve_lookup.csv"), show_col_types = FALSE)
flags <- readr::read_csv(here::here("results","tables","eda_curve_flags.csv"), show_col_types = FALSE)

# 1) compute deltaAIC between best and 2nd best among converged models
delta_tbl <- fits %>%
  filter(converged == 1, is.finite(AIC)) %>%
  arrange(curve_num, AIC) %>%
  group_by(curve_num) %>%
  summarise(
    best_model_AIC = first(model),
    best_AIC = first(AIC),
    second_AIC = if_else(n() >= 2, nth(AIC, 2), NA_real_),
    deltaAIC_2nd = second_AIC - best_AIC,
    .groups = "drop"
  )

# 2) join meta + flags
# IMPORTANT: drop PopBio_units from flags to avoid PopBio_units.x / PopBio_units.y
cand <- delta_tbl %>%
  left_join(meta, by = "curve_num") %>%
  left_join(flags %>% dplyr::select(-PopBio_units), by = "curve_num")

# 3) helper: pick one curve for each case
pick_one <- function(df, model_name, strong = TRUE) {
  x <- df %>% filter(best_model_AIC == model_name, !is.na(deltaAIC_2nd))
  if (nrow(x) == 0) return(tibble())
  if (strong) x <- x %>% arrange(desc(deltaAIC_2nd)) else x <- x %>% arrange(deltaAIC_2nd)
  x %>% slice(1)
}

strong_logistic <- cand %>%
  filter(has_decline == FALSE, has_nonpositive == FALSE) %>%
  pick_one("logistic", strong = TRUE) %>%
  mutate(reason = "Logistic strong win (clean S-shape candidate)")

borderline_logistic <- cand %>%
  pick_one("logistic", strong = FALSE) %>%
  mutate(reason = "Logistic borderline (uncertainty case)")

strong_cubic <- cand %>%
  filter(has_decline == TRUE, has_nonpositive == FALSE) %>%
  pick_one("cubic", strong = TRUE) %>%
  mutate(reason = "Cubic strong win (decline/death phase case)")

borderline_quadratic <- cand %>%
  pick_one("quadratic", strong = FALSE) %>%
  mutate(reason = "Quadratic borderline (simple/limited-data case)")

out <- bind_rows(strong_logistic, borderline_logistic, strong_cubic, borderline_quadratic) %>%
  select(
    reason, curve_num, best_model_AIC, deltaAIC_2nd,
    PopBio_units, Temp, Species, Medium,
    has_decline, has_nonpositive, n_points, n_unique_time
  )

readr::write_csv(out, here::here("results","tables","figure_candidates.csv"))
message("Wrote: results/tables/figure_candidates.csv")