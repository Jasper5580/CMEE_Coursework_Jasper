# MiniProject Assessment for Yian Liu

## Computing

### A1 — Project Organisation

The repository is easy to navigate: `code/`, `data/`, `results/`, `report/`, `run_MiniProject.sh`, `README.md`, and `.gitignore` are all present, and the README is unusually thorough in documenting language versions, dependencies, package purposes, script roles, and expected outputs. That level of documentation matters because it lowers the barrier to rerunning and inspecting the workflow on another machine. The main organisational weakness is that `results/` contains committed outputs across `tables`, `figures`, `clean`, and `fits`, alongside a very large number of generated PDFs; under the rubric this costs marks directly and also makes it harder to distinguish source from product in the repository. Future submissions would benefit from keeping `results/` empty in version control and regenerating all outputs from the run script, while retaining only source files and perhaps a minimal example output if explicitly justified.

### A2 — Single-Script Reproducibility

#### Workflow & Solution Quality
`run_MiniProject.sh` runs successfully end to end: it restores `renv` where available, executes `code/01_prepare_data.R`, `code/02_explore_vis.R`, `code/02_fit_models.R`, `code/03_analyse_plot.R`, and `code/04_pick_figures.R`, then compiles `report/main.tex` to `report/Yian.Liu_MiniProject.pdf`. The script is well structured, uses `set -euo pipefail`, checks for `Rscript`, and includes sensible fallbacks for `texcount`, `latexmk`, and `pdflatex`/`bibtex`, which makes the pipeline robust across different Linux setups. The workflow also uses project-relative paths through `here::here()` and writes outputs in a consistent staged order, so the analysis is genuinely reproducible from a single entry point. The main deduction here is not failure but hygiene: because outputs were already committed, the post-run check could not verify newly generated PDFs, so a cleaner submission would make the successful rerun more transparent.

### A3 — Code Quality & Style

#### Script-level Technical Feedback
The analytical code is modular and task-separated across `code/01_prepare_data.R`, `code/02_fit_models.R`, `code/03_analyse_plot.R`, and `code/04_pick_figures.R`, with the strongest decomposition in `code/02_fit_models.R`, where functions such as `fit_quadratic`, `fit_cubic`, `fit_logistic`, `calc_metrics`, and `fit_one_curve` keep the fitting logic readable and reusable. `code/03_analyse_plot.R` continues that pattern with `make_pred_for_curve` and `plot_one_curve`, which cleanly separate prediction from plotting, and the shell entry script `run_MiniProject.sh` wraps repeated `Rscript` calls through `run_r`. The raw aggregate metrics look stronger than the student-written code alone because `renv/activate.R` dominates the totals, but even excluding that, the project shows clear modular structure; the weaker point is documentation, since `code/02_fit_models.R` has 350 lines and zero detected comment lines, so several non-obvious fitting choices rely on the reader inferring intent from code rather than being told directly. A next step would be to add short comments or function headers in `code/02_fit_models.R` and `code/03_analyse_plot.R` explaining the start-value heuristics, bounds, and prediction reconstruction logic.

### A4 — Model Fitting & Statistical Analysis

#### NLLS
The project fits three active candidate models—quadratic, cubic, and logistic—with an optional Gompertz branch left disabled, so it comfortably exceeds the minimum requirement of comparing at least two models and includes a mechanistic nonlinear model. NLLS is used appropriately for the logistic model through `nlsLM()` in `code/02_fit_models.R`, with explicit `start =` values for `N0`, `r`, and `K`, lower and upper bounds, `maxiter = 200`, and `tryCatch()` wrappers so failed fits are recorded rather than crashing the pipeline. The fitting strategy is technically sound: curves are screened for minimum data requirements, AIC and BIC are used as primary comparison metrics, and RSS/R² are retained as secondary summaries, while the report gives concrete convergence rates of 100.0% for quadratic, 98.0% for cubic, and 93.4% for logistic across 305 curves. A next step would be to export or summarise the actual starting values used for each logistic fit so that the heuristic initialisation strategy is fully auditable alongside the fitted parameters.

### A5 — Version Control & Workflow Discipline

The Git history is the weakest part of the computing submission. The repository has 15 commits in total but only one commit touching the MiniProject, `b4e2405 Add MiniProject folder`, which reads as a bulk upload rather than iterative development. That makes it difficult to see how the analysis evolved or whether debugging and writing progressed in stages. Future work would benefit from smaller, descriptive commits tied to concrete milestones such as data cleaning, model fitting, figure generation, and report drafting.

## Report

### B1 — Report Format & Presentation

The report meets the main formal requirements well: `article` class at 11pt, 1.5 spacing, `lineno`, a title page with title/author/affiliation/word count, a non-numeric bibliography style via `apalike`, and an abstract of about 185 words, which is close to the target. The body word count of 3080 is comfortably within the 3500-word limit, and the LaTeX file compiles successfully in the grading environment. The automated structural check did not detect figures or tables because they are inserted via `\input{}` files, but the compiled log shows `fig_spaghetti.tex`, `table_model_summary.tex`, `fig_model_wins.tex`, and `fig_rep_curves.tex` being included, so there is no reason to deduct for missing display-item structure here. Presentation is therefore strong, with only minor room to tighten phrasing and polish a few typographical slips such as “growth odel”.

### B2 — Introduction & Objectives

The Introduction gives a clear biological setup around microbial growth curves, nonlinear trajectory shape, and the contrast between mechanistic and phenomenological models, and it uses citations effectively to motivate why logistic and polynomial models are worth comparing. The narrative also funnels reasonably well toward the stated question of whether logistic performs best overall and whether cubic becomes advantageous when post-peak decline is present. The main gap is alignment with the specific course framing: the text does not strongly anchor the project in temperature-dependent single-population metabolism and growth, and the objectives remain mostly model-comparison focused rather than clearly separating biological aims from methodological aims. Future submissions would benefit from making the temperature dimension central from the outset and stating, in separate sentences, the biological question and the modelling objective used to answer it.

### B3 — Methods (including Computing Tools)

The Methods section is one of the stronger parts of the report. It describes data provenance and preprocessing clearly, states the candidate model equations explicitly, explains how curves are identified, and gives a reproducible account of the fitting procedure, including `lm()` for quadratic and cubic models, `nlsLM()` for logistic fitting, start-value heuristics, parameter bounds, iteration limits, and `tryCatch()` handling of failed fits. The `Computing tools` subsection is present and well judged: R, Bash, LaTeX, BibTeX, and key packages such as `readr`, `dplyr`, `ggplot2`, `here`, and `minpack.lm` are named with brief justification for why they were used. One improvement would be to state even more explicitly how outputs from each script feed into the next stage, so the computational pipeline described in prose mirrors the staged workflow already implemented in code.

### B4 — Results & Display Items

The Results section is logically organised into dataset heterogeneity, overall model comparison, and representative fitted curves, which matches the project objectives well and makes the narrative easy to follow. Although the structural parser reported zero display items, the LaTeX compilation log shows one spaghetti figure, one model-summary table, one model-wins figure, and one representative-curves figure being included through `\input{}` files, giving four display items in total and meeting the rubric target. The section reports concrete numerical outcomes—305 curves, logistic wins under AIC and BIC, and convergence rates by model—and the representative examples help connect the aggregate summary to individual curve shapes. The main weakness is that some interpretive language leaks into Results, especially phrases such as “This pattern matters” and “This made it useful to examine representative fitted curves in more detail,” which edge toward Discussion rather than strictly factual reporting.

### B5 — Discussion, Conclusions & Abstract

The Discussion interprets the main findings biologically in a sensible way, especially the argument that logistic wins on sigmoidal curves while cubic becomes competitive when decline phases are present, and it also acknowledges several concrete limitations of the dataset and candidate model set. The abstract is self-contained and effective: it states the background, objective, dataset size, methods, main comparison criteria, and headline findings clearly. The major mark cap here comes from the required advanced-methods engagement, which is missing: the Discussion does not meaningfully address MLE, Bayesian inference, or machine-learning approaches, nor explain what extra biological insight they might provide for heterogeneous microbial growth curves. A next step would be to add a substantive paragraph on how, for example, Bayesian hierarchical modelling could capture between-curve heterogeneity across species, media, and temperatures, or how likelihood-based approaches could support richer uncertainty quantification than the current NLLS comparison.

## Summary

Final classification (student-facing):

- Part A (Computing): Distinction
- Part B (Report): Distinction
- Overall: Distinction
