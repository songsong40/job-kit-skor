---
description: Summarize SKOR scores across all reviewed applications
---

Summarize my SKOR score history from `batch/skor-log.csv`.

$ARGUMENTS

## Behavior

1. Read `batch/skor-log.csv`. If it doesn't exist or has no data rows
   (header only), report: "No SKOR data yet. Run /resume-review on an
   application to start tracking." and stop.

2. Parse each row: `date,company,role,S_score,K_score,O_score,R_score,total,top_gaps`.
   A row where `total` is the literal string `SKIPPED` (S/K/O/R blank) is a
   **skip row** — logged by `/resume-analyze` when a job was rejected at
   gate-check, before any resume was tailored. It's valid, not malformed;
   handle it separately from scored rows (see steps 3a and 5a below).

3. Compute and show the average across **scored rows only** (exclude skip
   rows) for S, K, O, R, and total (one decimal place).

3a. Count the skip rows separately (`N skipped`). If there are zero scored
    rows but at least one skip row, report the skip count and the top
    blockers (step 5a), skip steps 3-6, and stop.

4. Identify the single lowest-scoring category on average (S, K, O, or R —
   compare each as a percentage of its max, since S/K are out of 40 and
   O/R are out of 10, e.g. `avg_S / 40` vs `avg_O / 10`). Name it and give
   one sentence on what it means in practice (e.g. low O = formatting/ATS
   issues keep recurring; low K = bullets keep lacking numbers).

5. List the 3 most frequently recurring gaps across **scored rows only**:
   - Split each row's `top_gaps` field on `|`, trim whitespace.
   - Treat near-duplicate phrasings as the same gap where the intent is
     clearly identical (use judgment, don't over-merge distinct gaps).
   - Rank by frequency, show the count next to each
     (e.g. "no quantified leadership metric (4x)").
   - If there are fewer than 3 distinct gaps, list what's there — don't
     pad the list.

5a. Separately, report on skip rows:
   - Show the total skip count (e.g. "5 applications skipped at gate-check").
   - Split each skip row's `top_gaps` on `|`, trim whitespace, rank by
     frequency the same way as step 5, and list the most common blockers
     (e.g. "language required for delivery: German (3x)").
   - If there are zero skip rows, state "0 skipped" and omit the blocker
     list.

6. Show a simple trend:
   - Sort rows by date.
   - Compare the average total score of the most recent third of
     applications against the earliest third (or first vs. last row if
     there are fewer than 3 rows).
   - Report "improving", "declining", or "flat" with the delta
     (e.g. "improving: +12 pts avg, oldest batch 58 -> newest batch 70").

7. Display as a short report:

   ```
   SKOR Summary (N scored, M skipped)

   Averages:  S 28.4/40   K 22.1/40   O 8.2/10   R 9.5/10   Total 68.2/100
   Weakest:   K — Kejayaan KPI (55% of max) — bullets are consistently light on numbers.

   Top recurring gaps (scored applications):
   1. no quantified leadership metric (4x)
   2. missing required certification X (3x)
   3. limited direct experience with tool Y (2x)

   Trend: improving (+12 pts avg, oldest batch 58 -> newest batch 70)

   Skipped at gate-check: 3
   Top blockers:
   1. language required for delivery: German (2x)
   2. missing work authorization: US (1x)
   ```

   If there are zero skip rows, show "Skipped at gate-check: 0" and omit
   the blockers list.

## Notes
- This command is read-only. It never modifies `batch/skor-log.csv` or any
  application files.
- Skip rows (`total` = `SKIPPED`, S/K/O/R blank) are valid and expected —
  do not treat them as malformed. Exclude them from score averages and the
  recurring-gaps ranking, but include them in the skip count and blocker
  list (steps 3a, 5a).
- If a row is genuinely malformed (wrong column count, or a non-`SKIPPED`
  non-numeric score), skip it and note how many rows were skipped for that
  reason at the end of the report — keep this count separate from the
  gate-check skip count.
