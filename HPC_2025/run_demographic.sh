#!/bin/bash
#PBS -N demo_q3
#PBS -l walltime=01:00:00
#PBS -l select=1:ncpus=1:mem=4gb
#PBS -j oe

cd $HOME/HPC_2025

module purge
module load tools/prod
module load R/4.2.2-foss-2022b

Rscript code/Yian.Liu_HPC_2025_demographic_cluster.R

