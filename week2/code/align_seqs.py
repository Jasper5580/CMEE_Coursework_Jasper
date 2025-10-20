#!/usr/bin/env python3
"""

A very basic DNA aligner:
- read two sequences from a tiny CSV/TXT file
- slide the shorter over the longer
- choose the start position with the highest match score
- print and save the best alignment

"""

INPUT_PATH  = "../data/two_seqs.csv"
OUTPUT_PATH = "../results/best_alignment.txt" 

def read_two_seqs(path):
    items = []
    with open(path, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            # If there is a comma in the line, split it by the comma first
            parts = [p.strip() for p in line.split(",") if p.strip()]
            items.extend(parts if parts else [line])

            if len(items) < 2:
                raise ValueError(f"Fewer than two sequences in the input file：{path}")

    # Take only the first two, remove spaces and capitalize them
    s1 = items[0].replace(" ", "").upper()
    s2 = items[1].replace(" ", "").upper()
    return s1, s2

def calculate_score(longer, shorter, start):
    """Append shorter to longer starting from start and return (score, matching marker line)."""
    score = 0
    marks = []
    for i, base in enumerate(shorter):
        j = start + i
        if j >= len(longer):
            break
        if longer[j] == base:
            score += 1
            marks.append("|")   # Matches are marked with a vertical line
        else:
            marks.append(" ")
    return score, (" " * start) + "".join(marks)

def best_alignment(seq1, seq2):
        # Make "longer" always the longer line, 
        # and use "top" to save the "top line" when displaying.”
    if len(seq2) > len(seq1):
        longer, shorter = seq2, seq1
        top = seq2
    else:
        longer, shorter = seq1, seq2
        top = seq1

    best_score = -1
    best_start = 0
    best_matchline = ""
    best_align = ""

    for start in range(len(longer)):
        score, matchline = calculate_score(longer, shorter, start)
        if score > best_score:
            best_score = score
            best_start = start
            best_matchline = matchline
            best_align = ("." * start) + shorter 

    lines = [
        "Best alignment",
        "--------------",
        f"Score : {best_score}",
        f"Start : {best_start}",
        "",
        top,
        best_matchline,
        best_align,
        ""
    ]
    return "\n".join(lines)


def main():
    # Read Sequence
    s1, s2 = read_two_seqs(INPUT_PATH)
    # Calculate the best alignment
    report = best_alignment(s1, s2)
    # Print
    print(report)
    # Write file
    with open(OUTPUT_PATH, "w", encoding="utf-8") as f:
        f.write(report)
    print(f"Saved to: {OUTPUT_PATH}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())