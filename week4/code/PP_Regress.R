#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
})

infile  <- file.path("..", "data", "EcolArchives-E089-51-D1.csv")
out_pdf <- file.path("..", "results", "PP_Regress.pdf")
out_csv <- file.path("..", "results", "PP_Regress_Results.csv")

if (!dir.exists(file.path("..", "results"))) dir.create(file.path("..", "results"), recursive = TRUE)

d <- read.csv(infile, stringsAsFactors = FALSE)

dat <- d %>%
  mutate(
    # Standardize units: mg -> g
    Prey.mass.g = ifelse(Prey.mass.unit == "mg", Prey.mass / 1000, Prey.mass),
    Feeding.type = Type.of.feeding.interaction,
    Lifestage    = gsub("\\s*/\\s*", "/", Predator.lifestage)  # 去掉“larva / juvenile”中的空格，便于图例整洁
  ) %>%
  select(Feeding.type, Lifestage, Predator.mass, Prey.mass.g) %>%
  filter(!is.na(Feeding.type), !is.na(Lifestage),
         !is.na(Predator.mass), !is.na(Prey.mass.g)) %>%
  mutate(
    logPred = log10(Predator.mass),
    logPrey = log10(Prey.mass.g),
    Feeding.type = factor(
      Feeding.type,
      levels = c("insectivorous", "piscivorous", "planktivorous", "predacious", "predacious/piscivorous")
    )
  )

# Draw and write to PDF
p <- ggplot(dat, aes(x = Prey.mass.g, y = Predator.mass,
                     colour = Lifestage, fill = Lifestage)) +
  geom_point(alpha = 0.5, size = 1) +
  geom_smooth(method = "lm", se = TRUE, size = 0.6) +
  scale_x_log10() +
  scale_y_log10() +
  facet_grid(Feeding.type ~ .) +
  labs(x = "Prey Mass in grams", y = "Predator mass in grams") +
  theme_bw(base_size = 11) +
  theme(legend.position = "bottom",
        strip.background = element_rect(colour = NA, fill = "grey90"))

pdf(out_pdf, width = 7, height = 10)
print(p) 
dev.off()

## Model： log10(Predator.mass) ~ log10(Prey.mass.g)
regress_results <- dat %>%
  group_by(Feeding.type, Lifestage) %>%
  do({
    dd <- .
    n  <- nrow(dd)

    # If there are too few data points (<3) or the independent variable has insufficient values ​​(<2 distinct x), then NA is given.
    if (n < 3 || dplyr::n_distinct(dd$logPrey) < 2) {
      data.frame(n = n, intercept = NA_real_, slope = NA_real_,
                 r.squared = NA_real_, f.statistic = NA_real_,
                 df1 = NA_integer_, df2 = NA_integer_, p.value = NA_real_)
    } else {
      fit <- lm(logPred ~ logPrey, data = dd)
      s   <- summary(fit)
      f   <- unname(s$fstatistic)
      pv  <- if (length(f) == 3) pf(f[1], f[2], f[3], lower.tail = FALSE) else NA_real_
      co  <- coef(s)

      data.frame(
        n          = n,
        intercept  = unname(co["(Intercept)", "Estimate"]),
        slope      = unname(co["logPrey"   , "Estimate"]),
        r.squared  = unname(s$r.squared),
        f.statistic= if (length(f) >= 1) f[1] else NA_real_,
        df1        = if (length(f) >= 2) f[2] else NA_integer_,
        df2        = if (length(f) >= 3) f[3] else NA_integer_,
        p.value    = pv
      )
    }
  }) %>%
  arrange(Feeding.type, Lifestage)

write.csv(regress_results, out_csv, row.names = FALSE)

cat("\nDone.\n",
    "Figure  : ", out_pdf, "\n",
    "Results : ", out_csv, "\n", sep = "")
