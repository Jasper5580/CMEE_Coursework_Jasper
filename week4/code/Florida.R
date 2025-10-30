set.seed(1)

# 1.
cand_paths <- c("data/KeyWestAnnualMeanTemperature.RData",
                "../data/KeyWestAnnualMeanTemperature.RData")
data_path <- cand_paths[file.exists(cand_paths)][1]
if (is.na(data_path)) stop("can`t find the file")

# 2. output dir（results/figs）
out_root <- if (dir.exists("results")) "results" else "../results"
fig_dir  <- file.path(out_root, "figs")
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)

# 3.
load(data_path)
class(ats); head(ats)

# 4.Scatter plot
png(file.path(fig_dir, "scatter_year_temp.png"), width = 900, height = 650)
plot(ats$Year, ats$Temp,
     xlab = "Year", ylab = "Temp (°C)",
     main = "Key West annual mean temperature")
dev.off()

# 5.correlation
r_obs <- cor(ats$Year, ats$Temp)
r_obs

# 6.Displacement test
B <- 10000
rand_r <- numeric(B)
for (i in 1:B) rand_r[i] <- cor(ats$Year, sample(ats$Temp))

# 7.One-sided p-value
p_val <- mean(rand_r >= r_obs)
p_val

# 8.
png(file.path(fig_dir, "permutation_correlations.png"), width = 900, height = 650)
hist(rand_r, breaks = 50,
     main = "Permutation distribution of r",
     xlab = "Correlation (Year vs. shuffled Temp)")
abline(v = r_obs, col = "red", lwd = 2)
legend("topleft",
       legend = paste0("Observed r = ", round(r_obs, 3),
                       "\nOne-sided p = ", signif(p_val, 3)),
       bty = "n")
dev.off()

cat("\nObserved r =", round(r_obs, 3),
    "| One-sided permutation p =", signif(p_val, 3), "\n")
if (p_val < 0.05 && r_obs > 0) {
  cat("Conclusion: key west is on warmer。\n")
} else {
  cat("Conclusion: No upward trend。\n")
}

vals_tex <- file.path(out_root, "values.tex")
cat(sprintf("\\newcommand{\\robserved}{%.3f}\n\\newcommand{\\pvalue}{%.3g}\n",
            r_obs, p_val),
    file = vals_tex)