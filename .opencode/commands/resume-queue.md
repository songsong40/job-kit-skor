---
description: Manage the job queue for batch processing
---

Manage the batch job queue (`batch/queue.yaml`).

$ARGUMENTS

## Subcommands

### add
```
/resume-queue add <url> [--note "text"]
```
Fetch the URL to confirm it works and extract the company name. Append
the entry to `batch/queue.yaml`. Show a confirmation line:
  Added: <company-name> — <url>

If --note is given, include it in the entry.

### remove
```
/resume-queue remove <index>
```
Remove the entry at the 1-based index from the queue. Show the removed
entry for confirmation.

### list
```
/resume-queue list
```
Read `batch/queue.yaml` and display every queued job in a table:

  #  | Company        | Stage    | Notes
  ───┼────────────────┼──────────┼────────────────────────
  1  | acme-corp      | prepped  | referred by Alex
  2  | globex         | queued   |
  3  | initech        | analyzed | deadline Aug 1

Stage is detected from the filesystem (which files exist in
`applications/<company>/`). See the pipeline stage rules in
`batch/README.md`.

### clean
```
/resume-queue clean
```
Remove all entries that have reached an end state (prepped or skipped).
- **Prepped** (interview-prep.md exists): the full pipeline completed.
  Remove the queue entry. Keep the `applications/<company>/` directory
  unless the user explicitly asks to delete it.
- **Skipped** (< 3 files, no resume.pdf): job was analyzed but not
  pursued. Remove the queue entry AND delete the
  `applications/<company>/` directory (contains only auto-generated
  analysis files).
Ask for confirmation first and show which entries and directories would
be removed.

## Behavior rules
- Always read `batch/queue.yaml` before making changes.
- Company names should be lowercase, kebab-case slugs.
- If a URL fails to fetch, warn but still add it to the queue with a note:
  "[WARNING: could not fetch]".
- If no subcommand is given, default to `list`.
