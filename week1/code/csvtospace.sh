#/bin/bash
# Author: Yian.Liu25@imperial.ac.uk
# Script: tabtocsv.sh
# Date: Oct 2025

# Check if the user gave an input file name
if [ $# -lt 1 ]; then
  echo "bash csvtospace.sh"
  exit 1
fi

# Save the first argument (the file name) in a variable
infile="$1"

# Check if the file exists
if [ ! -f "$infile" ]; then
  echo "Error: file not found: $infile"
  exit 1
fi

outfile="${infile}_space.txt"

# Use 'tr' to replace commas with spaces
echo "Changing commas to spaces in $infile ..."
tr ',' ' ' < "$infile" > "$outfile"

echo "Done! Created file: $outfile"