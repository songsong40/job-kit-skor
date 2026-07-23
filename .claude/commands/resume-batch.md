---
description: Run the full resume pipeline on queued jobs in parallel
---

Process all queued jobs from `batch/queue.yaml` through the resume
pipeline in parallel batches.

$ARGUMENTS

## Options

```
/resume-batch                          full pipeline (analyze → pause → finish)
/resume-batch --analyze-only           only run analyze, then stop
/resume-batch --from tailored          skip analyze, go straight to tailor+review+prep
/resume-batch --jobs 1,3,5             process only specific queue entries
/resume-batch --parallel 6             override default parallelism (default: 4)
```

## Preflight

1. Read `batch/queue.yaml`. If empty or no URLs, stop and tell the user
   to add jobs with `/resume-queue add <url>`.
2. For `--jobs N,M`, filter to those 1-based entries only.
3. Skip any job whose stage is already "prepped" (already done).
4. If no jobs remain after filtering, report it and stop.

## Phase 1 — Analyze (parallel)

For each job that is queued or not yet analyzed:

1. **Fetch the job posting URL**. If it fails, mark the job as errored
   and continue to the next.

2. **Launch a subagent** to run the analyze step. The subagent prompt
   must include:
   - The full fetched job description text
   - Instructions from `.opencode/commands/resume-analyze.md`
   - A requirement to return: company name, role title, fit score
     (X/10), and the top 3 requirements with match levels.

3. **Run all subagents in parallel** (up to `--parallel` count).
   Launch them all at once in a single message with multiple Task
   tool calls. Each subagent works in its own
   `applications/<company>/` directory — no conflicts.

4. **Collect results.** For each completed subagent, read the
   `job-analysis.md` it produced to extract the fit score.

5. **Show the ranking table** sorted by fit score (highest first):

   ```
   #   Company        Role                     Fit   Top Match
   ─── ────────────── ──────────────────────── ────  ──────────────────────
   1   acme-corp      Sr Backend Engineer       7/10  Python, FastAPI, GCP
   2   globex         ML Ops Lead               5/10  PyTorch, MLOps, K8s
   3   initech        Full Stack Developer      4/10  React, Node, Postgres
   ```

   Show any errored jobs below the table.

6. **PAUSE.** Ask the user which jobs to continue with. Default:
   all jobs with fit >= 4/10. The user can reply with:
   - "all" — continue all successfully analyzed jobs
   - "1,3,5" — continue specific jobs by index number
   - ">=5" — continue jobs with fit >= 5/10
   - "stop" — end here, review the analyses manually

   If `--analyze-only` was passed, skip the pause and stop.

## Phase 2 — Finish (parallel)

For each job the user selected:

1. **Launch a subagent** to run tailor + review + prep sequentially.
   The subagent prompt must include:
   - Company name and directory path
   - Instructions from:
     - `.opencode/commands/resume-tailor.md`
     - `.opencode/commands/resume-review.md`
     - `.opencode/commands/resume-prep.md`
   - Requirement: run all three steps in order, stopping if a step
     fails irrecoverably.

2. **Run all subagents in parallel** (up to `--parallel` count).

3. **Show the final summary:**

   ```
   ─── Batch complete ───
   ✓ 2 succeeded
   ✗ 1 failed  (acme-corp: xelatex compilation error)
   ⏭ 2 skipped  (already prepped)
   ─────────────────────
   ```

   For failures, show the specific error so the user can fix it.

## Phase 3 — Queue cleanup

After the final summary, clean up the queue and orphaned directories:

1. Read `batch/queue.yaml`.
2. For each job that completed successfully (application directory reached
   "prepped" stage), remove its entry from the queue. Keep the
   `applications/<company>/` directory — the user may want the files.
3. For each job that was skipped by the user (fit too low, excluded by
   threshold, or a SKIP verdict in `job-analysis.md`): **before deleting
   anything**, log the skip — no skip is ever deleted without being logged
   first. Same format as the single-job `/resume-analyze` skip path:
   - Append one row to `batch/skor-log.csv` (create it with the header
     `date,company,role,S_score,K_score,O_score,R_score,total,top_gaps`
     first if the file is missing):
     ```
     YYYY-MM-DD,<company>,<role>,,,,,SKIPPED,"<reason>"
     ```
   - Leave `S_score`, `K_score`, `O_score` blank, `total` is the literal
     string `SKIPPED`.
   - `<company>`/`<role>`: read from `job-analysis.md` (role title as
     extracted there). If `job-analysis.md` is missing, use `unknown` for
     role.
   - `<reason>`: if `job-analysis.md` has a SKIP verdict, use its exact
     HARD BLOCKER category and detail. Otherwise use the batch-specific
     reason the job was excluded (e.g. `"fit 3/10, below threshold"` or
     `"excluded by user selection"`).
   - Append to the end of the file — don't rewrite or reorder existing
     rows.

   Only after that row is appended: remove the job's entry from the queue
   AND delete the `applications/<company>/` directory entirely. These
   folders contain only auto-generated analysis files.
4. Write the updated queue back to `batch/queue.yaml`.
5. Show what was cleaned:
   ```
   Cleaned 2 completed, 1 skipped from queue. 0 remaining.
   Removed 1 orphaned directory: applications/initech/
   Logged 1 skip to batch/skor-log.csv.
   ```

## Concurrency rules

- Each subagent works in its own `applications/<company>/` directory.
  xelatex compiles in that directory — no shared temp files.
- Default 4 parallel subagents. Use `--parallel` to override.
- Subagents are isolated. A crash in one does not affect others.
- Track job status in memory during this run. Do not write status to
  the queue file — stage is always detected from the filesystem.

## Edge cases

- **URL unreachable**: Log "could not fetch <url>" and skip that job.
- **Company name conflict**: If `applications/<company>/` already
  exists from a previous run, the subagent should proceed anyway
  (it will overwrite/update files).
- **Resume longer than one page**: The tailor step handles this per
  standard rules. The batch does not re-check — the review step will
  catch it.
- **No jobs selected after pause**: Stop cleanly, no error.
