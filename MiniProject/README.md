# MiniProject

## Project overview

This project analyses microbial population growth data from `data/logistic_growth_data.csv` and compares alternative mathematical models for individual growth curves inferred from the raw dataset. The final chosen dataset for the MiniProject is `logistic_growth_data.csv`.

The workflow is organised so that raw data are cleaned first, then explored visually, then fitted with multiple candidate models, and finally summarised into tables and figures for use in the report. The executable analysis code is R-based, with a shell launcher at the project root (`run_MiniProject.sh`) and a LaTeX report expected in `report/`.

## Biological question

**Which mathematical models best describe empirical microbial population growth curves across different species, temperatures, media, and studies?**

## Coursework requirements addressed by this repository

This repository is organised to match the MiniProject brief:

- the project is intended to be fully reproducible from a single launcher script;
- at least two alternative mathematical models are fitted and compared;
- the workflow starts with raw data and ends with a LaTeX report;
- the README records software, dependencies, and the purpose of each package;
- the report is expected to include a Methods subsection called **Computing tools**.

## Dataset

### Main input files

- `data/logistic_growth_data.csv` — main population growth dataset used in the project.
- `data/logistic_growth_meta_data.csv` — metadata describing the variables in the dataset.

### Key variables used

- `Time` — time of measurement.
- `PopBio` — population or biomass measurement.
- `Temp` — temperature.
- `Time_units` — units of time.
- `PopBio_units` — units of abundance or biomass.
- `Species` — focal microbial species or strain.
- `Medium` — growth medium.
- `Rep` — replicate identifier.
- `Citation` — source study.

### Growth-curve definition used in this project

Because the raw dataset does not contain a single pre-made curve identifier, each unique curve is reconstructed by concatenating:

`Species + Temp + Medium + Citation + Rep`

The resulting string is saved as `curve_id`, and a numeric identifier `curve_num` is assigned for downstream fitting and plotting.

### Data-cleaning rules

The data-preparation script:

- trims whitespace in column names;
- checks that all required columns are present;
- parses `Time`, `PopBio`, and `Temp` as numeric values;
- removes rows with non-finite `Time` or `PopBio` values;
- averages repeated measurements taken at the same `Time` within the same curve;
- writes cleaned data and lookup tables into `results/clean/` and `results/tables/`.

## Models fitted

The active workflow fits three candidate models to each curve:

1. **Quadratic polynomial**
2. **Cubic polynomial**
3. **Logistic growth model**

An additional **modified Gompertz model** is implemented in `code/02_fit_models.R`, but it is currently switched off by default because `DO_GOMPERTZ <- FALSE`.

### Why these models were chosen

The coursework suggestions for the population-growth dataset explicitly motivate comparing simple polynomial models with nonlinear population-growth models such as logistic and Gompertz. The current workflow therefore compares quadratic and cubic polynomials against a nonlinear logistic model, while keeping Gompertz as an optional extension.

### Model comparison

For each fitted model, the workflow records:

- number of observations (`n`)
- number of unique time points (`n_unique_time`)
- number of fitted parameters (`k`)
- AIC
- BIC
- RSS
- R2
- convergence status
- an error message, if fitting fails

Best models are summarised primarily using **AIC** and **BIC**. Although `R2` is also written to output files, model selection in this workflow is based on AIC/BIC rather than on `R2`.

## Project structure

```text
MiniProject/
├── code/
│   ├── 00_setup.R
│   ├── 01_prepare_data.R
│   ├── 02_explore_vis.R
│   ├── 02_fit_models.R
│   ├── 03_analyse_plot.R
│   └── 04_pick_figures.R
├── data/
│   ├── logistic_growth_data.csv
│   └── logistic_growth_meta_data.csv
├── renv/
├── report/
│   ├── main.tex
├── results/
│   ├── clean/
│   │   ├── curve_lookup.csv
│   │   └── growth_clean.csv
│   ├── figures/
│   │   ├── explore/
│   │   ├── fits/
│   │   └── summary/
│   ├── fits/
│   │   ├── fit_config.csv
│   │   ├── model_fits.csv
│   │   └── model_params.csv
│   └── tables/
│       ├── best_model_by_curve_AIC.csv
│       ├── best_model_by_curve_BIC.csv
│       ├── convergence_summary.csv
│       ├── curve_summary.csv
│       ├── eda_curve_flags.csv
│       ├── eda_units_summary.csv
│       ├── figure_candidates.csv
│       ├── fit_config_copied.csv
│       ├── model_win_counts_AIC.csv
│       ├── model_win_counts_BIC.csv
│       └── sessionInfo.txt
├── MiniProject.Rproj
├── renv.lock
└── run_MiniProject.sh
```

## Script-by-script description

### `code/00_setup.R`

Purpose:

- sets global R options;
- fixes the random seed for reproducibility;
- sets the language to English;
- creates the required output directories if they do not already exist;
- writes `sessionInfo()` to `results/tables/sessionInfo.txt`.

### `code/01_prepare_data.R`

Purpose:

- imports the raw growth dataset;
- checks the required columns;
- converts relevant variables to the correct types;
- reconstructs unique growth-curve IDs;
- averages duplicate time points within a curve;
- saves cleaned data and lookup tables.

Main outputs:

- `results/clean/growth_clean.csv`
- `results/clean/curve_lookup.csv`
- `results/tables/curve_summary.csv`

### `code/02_explore_vis.R`

Purpose:

- creates basic exploratory summaries of the cleaned data;
- counts rows by `PopBio_units`;
- flags curves with non-positive observations or apparent decline phases;
- saves exploratory figures for a random sample of 20 curves and a full spaghetti overview.

Main outputs:

- `results/tables/eda_units_summary.csv`
- `results/tables/eda_curve_flags.csv`
- `results/figures/explore/eda_sample20_points.pdf`
- `results/figures/explore/eda_sample20_log_points.pdf`
- `results/figures/explore/eda_all_spaghetti.pdf`

### `code/02_fit_models.R`

Purpose:

- reads the cleaned dataset;
- defines model functions and helper functions;
- fits the quadratic, cubic, and logistic models to each curve;
- optionally fits the Gompertz model if enabled;
- records convergence, fit statistics, and parameter estimates.

Design choices:

- quadratic and cubic models are fitted with `lm()`;
- the logistic model is fitted with `nlsLM()` from `minpack.lm`;
- model fitting is protected with `tryCatch()` so that failures are recorded rather than crashing the workflow;
- logistic starting values are estimated from the observed curve itself;
- upper and lower bounds are used for the nonlinear optimisation.

Main outputs:

- `results/fits/model_fits.csv`
- `results/fits/model_params.csv`
- `results/fits/fit_config.csv`

### `code/03_analyse_plot.R`

Purpose:

- summarises convergence rates by model;
- identifies the best model per curve by AIC and BIC;
- counts overall model wins;
- generates summary bar plots of AIC/BIC winners;
- reconstructs fitted curves from saved parameters;
- creates one PDF fit plot per curve.

Main outputs:

- `results/tables/convergence_summary.csv`
- `results/tables/best_model_by_curve_AIC.csv`
- `results/tables/best_model_by_curve_BIC.csv`
- `results/tables/model_win_counts_AIC.csv`
- `results/tables/model_win_counts_BIC.csv`
- `results/figures/summary/model_wins_AIC.pdf`
- `results/figures/summary/model_wins_BIC.pdf`
- `results/figures/fits/curve_*.pdf`

### `code/04_pick_figures.R`

Purpose:

- selects representative example curves for use in the written report;
- identifies strong and borderline model wins;
- joins model-selection results with curve metadata and quality-control flags.

Main output:

- `results/tables/figure_candidates.csv`

## Software, language versions, and dependencies

### Languages and tools used

| Language / tool | Role in the project | Version information |
|---|---|---|
| Bash | Single-entry workflow launcher via `run_MiniProject.sh` | Record on the final submission machine using `bash --version` |
| R | Data cleaning, exploratory analysis, model fitting, plotting, and table generation | `R 4.3.3` is recorded in `renv.lock`; an executed session is also written to `results/tables/sessionInfo.txt` |
| renv | R environment management and restoration | `renv 1.1.8` is recorded in `renv.lock` |
| LaTeX | Writing and compiling the report in `report/` | Record on the final submission machine using `pdflatex --version` |
| BibTeX | Bibliography compilation for the report | Record on the final submission machine using `bibtex --version` |
| latexmk | Preferred automated LaTeX build tool used by the launcher when available | Record on the final submission machine using `latexmk --version` |
| texcount | Word-count support for the report | Record on the final submission machine using `texcount -v` |
| Git | Version control for the repository | Use repository history / local Git installation |
| Python | Not used in the final executable analysis workflow in `code/` | No Python script is currently called by `run_MiniProject.sh` |

### R package dependencies and what they are used for

| Package | Used in | Purpose |
|---|---|---|
| `here` | `00_setup.R` and indirectly all scripts | Builds paths relative to the project root, making the workflow portable |
| `readr` | all analysis scripts except `00_setup.R` | Fast import and export of CSV files |
| `dplyr` | `01_prepare_data.R`, `02_explore_vis.R`, `02_fit_models.R`, `03_analyse_plot.R`, `04_pick_figures.R` | Data wrangling, grouping, summarising, joining, filtering |
| `stringr` | `01_prepare_data.R`, `02_explore_vis.R`, `02_fit_models.R` | String handling, especially column-name cleaning and general text handling |
| `ggplot2` | `02_explore_vis.R`, `03_analyse_plot.R` | Produces exploratory plots, fitted-curve plots, and summary figures |
| `purrr` | `02_fit_models.R`, `03_analyse_plot.R` | Iterates over lists of curves and plotting tasks |
| `tidyr` | `03_analyse_plot.R` | Reshapes parameter tables with `pivot_wider()` for prediction |
| `minpack.lm` | `02_fit_models.R` | Provides `nlsLM()` for bounded nonlinear least-squares fitting of the logistic model and optional Gompertz model |
| `renv` | project root / `run_MiniProject.sh` | Manages and restores a project-local R environment |
| base `stats` | implicit | Provides `lm()`, `AIC()`, `BIC()`, `predict()`, and core modelling functions |
| base `utils` | implicit | Provides helper functions such as `capture.output()` |

### Dependency management with `renv`

The project root contains both `renv/` and `renv.lock`. The current `renv.lock` records:

- **R version:** 4.3.3
- **renv version:** 1.1.8

The launcher script checks for `renv.lock` and, if available, attempts to activate and restore the project environment before running the analysis. However, in the current lockfile the only explicitly recorded package entry is `renv` itself, so on a fresh machine you may still need to install the main analysis packages manually if they are not restored automatically.

Recommended restore command:

```bash
Rscript -e "if (!requireNamespace('renv', quietly = TRUE)) install.packages('renv', repos = 'https://cloud.r-project.org')"
Rscript -e "renv::restore(prompt = FALSE)"
```

If needed, install the main analysis packages manually in R:

```r
install.packages(c(
  "here", "readr", "dplyr", "stringr",
  "ggplot2", "purrr", "tidyr", "minpack.lm"
))
```

## How to run the project

### Recommended full run

From the project root:

```bash
bash run_MiniProject.sh
```

This is the intended single-entry point for the marker.

### What `run_MiniProject.sh` does

The launcher script:

1. moves to the project root;
2. checks that `Rscript` is available;
3. if `renv.lock` exists, tries to activate and restore the `renv` environment;
4. runs the R scripts in this order:
   - `code/01_prepare_data.R`
   - `code/02_explore_vis.R`
   - `code/02_fit_models.R`
   - `code/03_analyse_plot.R`
   - `code/04_pick_figures.R`
5. if `report/main.tex` exists, compiles the report using `latexmk`, or falls back to `pdflatex` + `bibtex`;
6. otherwise prints a warning that analysis finished but the report was not compiled.

Note that `00_setup.R` is not called as a separate step in the launcher because each R script sources it internally at the start.

### Manual step-by-step run

If you need to run the workflow manually, the normal order is:

```bash
Rscript code/01_prepare_data.R
Rscript code/02_explore_vis.R
Rscript code/02_fit_models.R
Rscript code/03_analyse_plot.R
Rscript code/04_pick_figures.R
```

Because each script begins by sourcing `code/00_setup.R`, you do not need to run `00_setup.R` separately unless you are testing it on its own.

## Expected outputs

After a successful run, the following types of output should be present:

- cleaned datasets in `results/clean/`
- model fit summaries and parameter tables in `results/fits/`
- EDA tables in `results/tables/`
- model-selection summary tables in `results/tables/`
- exploratory PDF figures in `results/figures/explore/`
- per-curve fitted-model PDFs in `results/figures/fits/`
- model-win summary PDFs in `results/figures/summary/`
- session information in `results/tables/sessionInfo.txt`
- if `report/main.tex` is present and a LaTeX toolchain is installed, a compiled report PDF in `report/`

## Reproducibility notes

- The workflow uses project-relative paths via `here::here()`.
- `00_setup.R` sets `set.seed(1)` and writes session information to file.
- Model-fitting failures are caught and recorded instead of stopping the workflow.
- The project includes a single shell launcher, which is the recommended entry point for marking.
- `renv.lock` records the intended R environment baseline.
- The report is expected to compile from `report/main.tex`, so all report assets should be organised to support local compilation from that location.

## Notes on interpretation

- The current active comparison is between quadratic, cubic, and logistic models.
- The Gompertz model is coded but not enabled in the current configuration.
- Some curves may not be fit successfully because of insufficient unique time points or other optimisation issues; these cases are recorded in the `message` column of `results/fits/model_fits.csv`.
- `figure_candidates.csv` provides a small set of representative curves for inclusion in the final report.

## How the Overleaf `main.tex` should be placed into `report/`

To satisfy both the coursework requirements and the local reproducible workflow, the final LaTeX source should be organised so that **the main entry file is exactly `MiniProject/report/main.tex`**.

### Recommended report layout

```text
MiniProject/
├── report/
│   ├── main.tex
│   ├── references.bib
│   ├── sections/
│   │   ├── abstract.tex
│   │   ├── introduction.tex
│   │   ├── methods.tex
│   │   ├── results.tex
│   │   └── discussion.tex
│   ├── figures/            # optional, only if you copy selected figures here
│   └── tables/             # optional, if you export any tables for LaTeX input
```

### Important placement rules

1. `main.tex` must sit **directly inside** `report/`, not inside a nested subfolder such as `report/overleaf_project/main.tex`.
2. Your `.bib` file should also be inside `report/`, for example `report/references.bib`.
3. Any files used by `\input{}` or `\include{}` should be inside `report/` subfolders such as `report/sections/`.
4. Do not rely on absolute paths from your own computer.
5. After moving files out of Overleaf, re-check every `\includegraphics{}`, `\input{}`, and `\bibliography{}` path.

### Best way to move an Overleaf project into this repository

1. In Overleaf, download the **source** as a zip file.
2. Extract it locally.
3. Copy the LaTeX source files into `MiniProject/report/`.
4. Rename the top-level Overleaf file to `main.tex` if needed.
5. Copy the `.bib` file into `report/`.
6. Keep only source files you need for compilation; auxiliary files such as `.aux`, `.log`, `.out`, and `.synctex.gz` do not need to be committed.

### How to handle figures in `main.tex`

You have two workable options.

**Option A: reference the figures generated by the workflow directly**

This is the most reproducible local setup, because your report will use the exact figures created by the analysis scripts. In that case, from `report/main.tex`, use paths such as:

```tex
\includegraphics[width=0.8\textwidth]{../results/figures/summary/model_wins_AIC.pdf}
\includegraphics[width=0.8\textwidth]{../results/figures/fits/curve_133.pdf}
```

This works well for the local repository because `run_MiniProject.sh` runs the analysis first and then compiles `report/main.tex`.

**Option B: copy selected figures into `report/figures/`**

This is convenient while writing in Overleaf, because everything stays inside the same Overleaf project tree. In that case, use paths such as:

```tex
\includegraphics[width=0.8\textwidth]{figures/model_wins_AIC.pdf}
```

However, if you choose this route, you must make sure the copied figures are updated before submission, otherwise your report may not reflect the latest workflow outputs.

### Final checks for `main.tex`

Before submission, check that `report/main.tex`:

- uses `\documentclass[11pt]{article}`;
- is 1.5-spaced;
- has continuous line numbers;
- has a separate title page with title, author, affiliation, and word count;
- includes a Methods subsection named **Computing tools**;
- uses BibTeX with a non-numeric citation style such as `apalike`;
- compiles successfully from the command line when called through `run_MiniProject.sh`.

## Report-related note

The coursework instructions require the written report to include a Methods subsection called **Computing tools**, explaining briefly how each scripting language was used, what packages were used, and why they were chosen. This README is designed to support that requirement by documenting the computational workflow, dependencies, and package purposes clearly.

## Author / submission note

Before final submission, check that the README, report, run script, and directory structure are consistent, and that the exact language and tool versions reported here match those on the machine used for the final run.
