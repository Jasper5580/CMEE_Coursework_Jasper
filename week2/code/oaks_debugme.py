import csv
import sys
import re
from pathlib import Path

OAK_RE = re.compile(r'^\s*quercus\b', re.IGNORECASE)

def is_an_oak(name):
    """Return True if name starts with genus 'Quercus' (word-boundary)."""
    if not isinstance(name, str):
        return False
    return bool(OAK_RE.search(name.strip()))

def main(argv):
    in_path = Path("../data/TestOaksData.csv")
    out_path = Path("../results/JustOaksData.csv")

    with in_path.open(newline="", encoding="utf-8") as f, out_path.open("w", newline="", encoding="utf-8") as g:
        taxa = csv.reader(f)
        csvwrite = csv.writer(g)
        for row in taxa:
            if is_an_oak(row[0]):
                csvwrite.writerow([row[0], row[1]])
    return 0

if __name__ == "__main__":
    sys.exit(main(sys.argv))