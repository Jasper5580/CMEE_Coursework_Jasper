source(here::here("code", "00_setup.R"))

library(readr)
library(dplyr)
library(purrr)
library(stringr)
library(minpack.lm)

DO_GOMPERTZ <- FALSE   # TRUE/FALSE (optional extension)
MAXITER_NLS <- 200

infile <- here::here("results", "clean", "growth_clean.csv")

logistic_fun <- function(t, N0, r, K) {
  K / (1 + ((K - N0) / N0) * exp(-r * t))
}

gompertz_fun <- function(t, y0, A, mu, lambda) {
  y0 + A * exp(-exp((mu * exp(1) / A) * (lambda - t) + 1))
}

safe_aic <- function(fit) {
  tryCatch(as.numeric(AIC(fit)), error = function(e) NA_real_)
}

safe_bic <- function(fit) {
  tryCatch(as.numeric(BIC(fit)), error = function(e) NA_real_)
}

calc_metrics <- function(y, yhat, k) {
  rss <- sum((y - yhat)^2)
  tss <- sum((y - mean(y))^2)
  r2 <- ifelse(is.finite(tss) && tss > 0, 1 - rss / tss, NA_real_)
  list(RSS = rss, R2 = r2, k = k)
}

fit_quadratic <- function(df) {
  n <- nrow(df)
  n_unique <- n_distinct(df$t)
  k <- 3
  
  if (n_unique <= k) {
    return(list(
      fit_row = tibble(model = "quadratic", n = n, n_unique_time = n_unique, k = k,
                       AIC = NA_real_, BIC = NA_real_, RSS = NA_real_, R2 = NA_real_,
                       converged = 0L, message = "Insufficient unique time points"),
      params = tibble()
    ))
  }
  
  out <- tryCatch({
    fit <- lm(PopBio ~ t + I(t^2), data = df)
    y <- df$PopBio
    yhat <- fitted(fit)
    m <- calc_metrics(y, yhat, length(coef(fit)))
    co <- coef(fit)
    
    params <- tibble(
      model = "quadratic",
      param = c("b0", "b1", "b2"),
      estimate = c(unname(co["(Intercept)"]), unname(co["t"]), unname(co["I(t^2)"]))
    )
    
    list(
      fit_row = tibble(model = "quadratic", n = n, n_unique_time = n_unique, k = m$k,
                       AIC = safe_aic(fit), BIC = safe_bic(fit),
                       RSS = m$RSS, R2 = m$R2, converged = 1L, message = ""),
      params = params
    )
  }, error = function(e) {
    list(
      fit_row = tibble(model = "quadratic", n = n, n_unique_time = n_unique, k = k,
                       AIC = NA_real_, BIC = NA_real_, RSS = NA_real_, R2 = NA_real_,
                       converged = 0L, message = e$message),
      params = tibble()
    )
  })
  
  out
}

fit_cubic <- function(df) {
  n <- nrow(df)
  n_unique <- n_distinct(df$t)
  k <- 4
  
  if (n_unique <= k) {
    return(list(
      fit_row = tibble(model = "cubic", n = n, n_unique_time = n_unique, k = k,
                       AIC = NA_real_, BIC = NA_real_, RSS = NA_real_, R2 = NA_real_,
                       converged = 0L, message = "Insufficient unique time points"),
      params = tibble()
    ))
  }
  
  out <- tryCatch({
    fit <- lm(PopBio ~ t + I(t^2) + I(t^3), data = df)
    y <- df$PopBio
    yhat <- fitted(fit)
    m <- calc_metrics(y, yhat, length(coef(fit)))
    co <- coef(fit)
    
    params <- tibble(
      model = "cubic",
      param = c("b0", "b1", "b2", "b3"),
      estimate = c(unname(co["(Intercept)"]), unname(co["t"]), unname(co["I(t^2)"]), unname(co["I(t^3)"]))
    )
    
    list(
      fit_row = tibble(model = "cubic", n = n, n_unique_time = n_unique, k = m$k,
                       AIC = safe_aic(fit), BIC = safe_bic(fit),
                       RSS = m$RSS, R2 = m$R2, converged = 1L, message = ""),
      params = params
    )
  }, error = function(e) {
    list(
      fit_row = tibble(model = "cubic", n = n, n_unique_time = n_unique, k = k,
                       AIC = NA_real_, BIC = NA_real_, RSS = NA_real_, R2 = NA_real_,
                       converged = 0L, message = e$message),
      params = tibble()
    )
  })
  
  out
}

fit_logistic <- function(df) {
  df2 <- df %>% arrange(t)
  n <- nrow(df2)
  n_unique <- n_distinct(df2$t)
  k <- 3
  
  if (n_unique <= k || n < 6) {
    return(list(
      fit_row = tibble(model = "logistic", n = n, n_unique_time = n_unique, k = k,
                       AIC = NA_real_, BIC = NA_real_, RSS = NA_real_, R2 = NA_real_,
                       converged = 0L, message = "Insufficient data for logistic"),
      params = tibble()
    ))
  }
  
  out <- tryCatch({
    y <- df2$PopBio
    
    y_pos <- y[y > 0]
    N0_start <- ifelse(length(y_pos) > 0, max(min(y_pos), 1e-12), 1e-12)
    
    K_start <- max(y)
    if (!is.finite(K_start) || K_start <= 0) K_start <- N0_start * 2
    if (K_start <= N0_start) K_start <- N0_start * 2
    
    r_start <- 0.1
    tmp <- df2 %>% filter(PopBio > 0) %>% mutate(logN = log(PopBio))
    if (nrow(tmp) >= 4) {
      slopes <- diff(tmp$logN) / diff(tmp$t)
      slopes <- slopes[is.finite(slopes)]
      if (length(slopes) > 0) r_start <- max(slopes, na.rm = TRUE)
    }
    if (!is.finite(r_start) || r_start <= 0) r_start <- 0.1
    r_start <- min(r_start, 10)
    
    upper_N0 <- max(K_start * 10, N0_start * 10)
    upper_K  <- max(K_start * 100, N0_start * 100)
    upper_r  <- 50
    
    fit <- nlsLM(
      PopBio ~ logistic_fun(t, N0, r, K),
      data = df2,
      start = list(N0 = N0_start, r = r_start, K = K_start),
      lower = c(N0 = 1e-12, r = 0, K = 1e-12),
      upper = c(N0 = upper_N0, r = upper_r, K = upper_K),
      control = nls.lm.control(maxiter = MAXITER_NLS)
    )
    
    yhat <- predict(fit)
    m <- calc_metrics(df2$PopBio, yhat, length(coef(fit)))
    
    params <- tibble(
      model = "logistic",
      param = names(coef(fit)),
      estimate = unname(coef(fit))
    )
    
    list(
      fit_row = tibble(model = "logistic", n = n, n_unique_time = n_unique, k = m$k,
                       AIC = safe_aic(fit), BIC = safe_bic(fit),
                       RSS = m$RSS, R2 = m$R2, converged = 1L, message = ""),
      params = params
    )
  }, error = function(e) {
    list(
      fit_row = tibble(model = "logistic", n = n, n_unique_time = n_unique, k = k,
                       AIC = NA_real_, BIC = NA_real_, RSS = NA_real_, R2 = NA_real_,
                       converged = 0L, message = e$message),
      params = tibble()
    )
  })
  
  out
}

fit_gompertz <- function(df) {
  df2 <- df %>% filter(PopBio > 0) %>% arrange(t)
  n <- nrow(df2)
  n_unique <- n_distinct(df2$t)
  k <- 4
  
  if (n_unique <= k || n < 7) {
    return(list(
      fit_row = tibble(model = "gompertz", n = n, n_unique_time = n_unique, k = k,
                       AIC = NA_real_, BIC = NA_real_, RSS = NA_real_, R2 = NA_real_,
                       converged = 0L, message = "Insufficient data for gompertz or PopBio<=0"),
      params = tibble()
    ))
  }
  
  out <- tryCatch({
    df3 <- df2 %>% mutate(y = log(PopBio)) %>% arrange(t)
    y <- df3$y
    
    y0_start <- min(y)
    A_start <- max(y) - min(y)
    if (!is.finite(A_start) || A_start <= 0) A_start <- 0.1
    
    mu_start <- 0.1
    slopes <- diff(y) / diff(df3$t)
    slopes <- slopes[is.finite(slopes)]
    if (length(slopes) > 0) mu_start <- max(slopes, na.rm = TRUE)
    if (!is.finite(mu_start) || mu_start <= 0) mu_start <- 0.1
    
    t_mid <- (df3$t[-1] + df3$t[-nrow(df3)]) / 2
    t_inf <- ifelse(length(slopes) > 0, t_mid[which.max(slopes)], 0)
    lambda_start <- max(0, t_inf - A_start / (mu_start * exp(1)))
    
    upper_A <- max(5 * A_start + 1, 1)
    upper_mu <- 50
    upper_lambda <- max(df3$t)
    
    fit <- nlsLM(
      y ~ gompertz_fun(t, y0, A, mu, lambda),
      data = df3,
      start = list(y0 = y0_start, A = A_start, mu = mu_start, lambda = lambda_start),
      lower = c(y0 = y0_start - 10 * abs(A_start) - 1, A = 1e-8, mu = 0, lambda = 0),
      upper = c(y0 = max(y), A = upper_A, mu = upper_mu, lambda = upper_lambda),
      control = nls.lm.control(maxiter = MAXITER_NLS)
    )
    
    yhat <- predict(fit)
    m <- calc_metrics(df3$y, yhat, length(coef(fit)))
    
    params <- tibble(
      model = "gompertz",
      param = names(coef(fit)),
      estimate = unname(coef(fit))
    )
    
    list(
      fit_row = tibble(model = "gompertz", n = n, n_unique_time = n_unique, k = m$k,
                       AIC = safe_aic(fit), BIC = safe_bic(fit),
                       RSS = m$RSS, R2 = m$R2, converged = 1L, message = ""),
      params = params
    )
  }, error = function(e) {
    list(
      fit_row = tibble(model = "gompertz", n = n, n_unique_time = n_unique, k = k,
                       AIC = NA_real_, BIC = NA_real_, RSS = NA_real_, R2 = NA_real_,
                       converged = 0L, message = e$message),
      params = tibble()
    )
  })
  
  out
}

dat <- readr::read_csv(infile, show_col_types = FALSE) %>%
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

curve_list <- split(dat, dat$curve_num)

fit_one_curve <- function(df_curve) {
  curve_id <- df_curve$curve_id[1]
  unit <- df_curve$PopBio_units[1]
  
  quad <- fit_quadratic(df_curve)
  cub  <- fit_cubic(df_curve)
  logi <- fit_logistic(df_curve)
  
  fits <- bind_rows(quad$fit_row, cub$fit_row, logi$fit_row) %>%
    mutate(curve_num = df_curve$curve_num[1],
           curve_id = curve_id,
           PopBio_units = unit)
  
  params <- bind_rows(quad$params, cub$params, logi$params) %>%
    mutate(curve_num = df_curve$curve_num[1],
           curve_id = curve_id,
           PopBio_units = unit) %>%
    select(curve_num, curve_id, PopBio_units, model, param, estimate)
  
  if (DO_GOMPERTZ) {
    gomp <- fit_gompertz(df_curve)
    fits <- bind_rows(fits, gomp$fit_row %>%
                        mutate(curve_num = df_curve$curve_num[1],
                               curve_id = curve_id,
                               PopBio_units = unit))
    params <- bind_rows(params, gomp$params %>%
                          mutate(curve_num = df_curve$curve_num[1],
                                 curve_id = curve_id,
                                 PopBio_units = unit) %>%
                          select(curve_num, curve_id, PopBio_units, model, param, estimate))
  }
  
  list(fits = fits, params = params)
}

all_res <- purrr::map(curve_list, fit_one_curve)

model_fits <- bind_rows(purrr::map(all_res, "fits")) %>%
  select(curve_num, curve_id, PopBio_units, model, n, n_unique_time, k,
         AIC, BIC, RSS, R2, converged, message) %>%
  arrange(curve_num, model)

model_params <- bind_rows(purrr::map(all_res, "params")) %>%
  arrange(curve_num, model, param)

readr::write_csv(model_fits, here::here("results", "fits", "model_fits.csv"))
readr::write_csv(model_params, here::here("results", "fits", "model_params.csv"))

cfg <- tibble(
  DO_GOMPERTZ = DO_GOMPERTZ,
  FIT_SCOPE = "full_curve",
  MAXITER_NLS = MAXITER_NLS,
  timestamp = as.character(Sys.time())
)
readr::write_csv(cfg, here::here("results", "fits", "fit_config.csv"))

message("02_fit_models.R finished.")
message("Wrote: results/fits/model_fits.csv")
message("Wrote: results/fits/model_params.csv")
message("Wrote: results/fits/fit_config.csv")
message("DO_GOMPERTZ = ", DO_GOMPERTZ)