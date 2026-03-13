#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_ROOT"

PDF_NAME="Yian.Liu_MiniProject"

run_r() {
  local script="$1"
  echo "[RUN] $script"
  Rscript "$script"
}

if ! command -v Rscript >/dev/null 2>&1; then
  echo "[ERROR] Rscript not found in PATH."
  exit 1
fi

if [ -f "renv.lock" ]; then
  echo "[RUN] activating/restoring renv if available"
  Rscript -e "if (requireNamespace('renv', quietly = TRUE)) {renv::activate(); renv::restore(prompt = FALSE)} else {message('renv not installed; using current R library.')}"
fi

run_r "code/01_prepare_data.R"
run_r "code/02_explore_vis.R"
run_r "code/02_fit_models.R"
run_r "code/03_analyse_plot.R"
run_r "code/04_pick_figures.R"

if [ -f "report/main.tex" ]; then
  echo "[RUN] preparing word count and compiling report/main.tex"

  (
    cd report

    if command -v texcount >/dev/null 2>&1; then
      texcount -1 -sum=1,1,0,0,0,1,1 -merge main.tex > wordcount.txt
      echo "[RUN] word count written to report/wordcount.txt"
    else
      echo "[WARN] texcount not found. Writing placeholder word count."
      echo "WORD COUNT NOT AVAILABLE" > wordcount.txt
    fi

    if command -v latexmk >/dev/null 2>&1; then
      latexmk -pdf -interaction=nonstopmode -halt-on-error -jobname="$PDF_NAME" main.tex
    elif command -v pdflatex >/dev/null 2>&1 && command -v bibtex >/dev/null 2>&1; then
      pdflatex -interaction=nonstopmode -halt-on-error -jobname="$PDF_NAME" main.tex
      bibtex "$PDF_NAME" || true
      pdflatex -interaction=nonstopmode -halt-on-error -jobname="$PDF_NAME" main.tex
      pdflatex -interaction=nonstopmode -halt-on-error -jobname="$PDF_NAME" main.tex
    else
      echo "[WARN] LaTeX compiler not found. R analysis finished, but the report was not compiled."
    fi
  )

  if [ -f "report/${PDF_NAME}.pdf" ]; then
    echo "[DONE] PDF created: report/${PDF_NAME}.pdf"
  else
    echo "[WARN] PDF compilation step finished, but ${PDF_NAME}.pdf was not found in report/."
  fi
else
  echo "[WARN] report/main.tex not found. R analysis finished, but the report was not compiled."
fi

echo "[DONE] MiniProject workflow completed."