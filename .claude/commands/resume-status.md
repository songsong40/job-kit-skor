---
description: Show pipeline progress across all applications
---

Show a dashboard of all applications and their pipeline stage.

$ARGUMENTS

## Behavior

1. Scan `applications/` for all company directories (skip `EXAMPLE/` and
   `.gitkeep`).
2. For each directory, detect the pipeline stage by checking which files
   exist:

   | Files present              | Stage    |
   |----------------------------|----------|
   | < 3 files                  | queued   |
   | `job-analysis.md`          | analyzed |
   | `resume.pdf`               | tailored |
   | `review.md`                | reviewed |
   | `interview-prep.md`        | prepped  |

3. Extract the fit score from `job-analysis.md` if it exists. Look for
   patterns like "fit score: X/10" or "Overall fit:".
4. Determine the last modified date from the newest file in the directory.
5. Display a table:

   ```
   #   Company        Role                     Stage     Fit   Last Updated
   ─── ────────────── ──────────────────────── ───────── ────  ────────────
   1   dhl-express    Jr Automation Developer   prepped   2/10  Jul 20 14:23
   2   acme-corp      Sr Backend Engineer       tailored  7/10  Jul 21 09:15
   3   globex         ML Ops Lead               analyzed  5/10  Jul 21 10:02
   4   initech        Full Stack Developer      queued    -     -
   ```

   If role cannot be determined, show "—".
   Sort by stage (prepped > reviewed > tailored > analyzed > queued)
   then by last updated (newest first).

6. After the table, show a summary line:
   ```
   1 prepped | 1 tailored | 1 analyzed | 1 queued (4 total)
   ```

## Options

```
/resume-status --detail <company>
```
Show the full breakdown for one company: all files present, fit score
details, and the changelog summary if available.

```
/resume-status --queue
```
Show only entries that are also in `batch/queue.yaml` (omit any
applications created outside the batch workflow).

## Notes
- This command is read-only. It never modifies files.
- If `applications/` is empty (or only has EXAMPLE/), report:
  "No applications yet. Run /resume-analyze on a job posting to start."
