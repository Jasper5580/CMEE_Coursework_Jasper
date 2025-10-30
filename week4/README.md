week4/
├── code/
│   ├── Florida.R        # Florida warming: correlation + permutation test → figures in results/figs
│   ├── PP_Regress.R     # Predator–Prey regressions (log–log) → PDF plot + CSV summary
│   └── TreeHeight.R     # Tree heights from distance & angle → CSV
│
├── data/
│   ├── EcolArchives-E089-51-D1.csv            # Predator–prey dataset
│   ├── KeyWestAnnualMeanTemperatureData.RData # Key West annual temperatures
│   └── trees.csv                              # Tree measurements
│
├── results/
│   ├── PP_Regress.pdf             # Faceted regression figure
│   ├── PP_Regress_Results.csv     # Regression table
│   ├── TreeHts.csv                # Tree heights
│   ├── report.tex / report.pdf / values.tex  # LaTeX outputs
│   └── figs/
│       ├── scatter_year_temp.png            # Year vs Temperature scatter
│       └── permutation_correlations.png     # Null distribution (permutation)
│
└── sandbox/
    ├── report.aux
    └── report.log
