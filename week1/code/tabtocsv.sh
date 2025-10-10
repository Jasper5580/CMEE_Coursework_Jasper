#!/bin/sh
# Author: Yian.Liu25@imperial.ac.uk
# Script: tabtocsv.sh
# Date: Oct 2025
# Check if the user gave an input file name
if [ $# -lt 1 ]; then
  echo "bash tabtocsv.sh"
  exit 1
fi

# Save the first argument (the file name) in a variable
infile="$1"

# Check if the file really exists
if [ ! -f "$infile" ]; then
  echo "Error: file not found: $infile"
  exit 1
fi

# Use 'tr' to replace TABs with commas and save to a new file
echo "Changing TABs to commas in $infile ..."
tr '\t' ',' < "$infile" > "$infile.csv"

echo "Done! Created file: $infile.csv"
