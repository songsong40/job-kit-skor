# Batch processing

Process 10-20 job postings at once instead of one at a time.

## Quick start

1. Add job URLs to `batch/queue.yaml` (or use `/resume-queue add <url>`).
   For blocked sites (Indeed, Glassdoor, LinkedIn), just paste the job
   description when prompted — no URL fetch needed.
2. Run `/resume-batch`.
3. Phase 1 runs analyze on every job in parallel and shows a ranked table.
4. You pick which jobs to continue. Phase 2 runs tailor → review → prep
   for each selected job in parallel.
5. Use `/resume-status` anytime to see where everything stands.

## Files

| File | Purpose |
|---|---|
| `queue.yaml` | Your job queue. Add URLs here. |
| `queue.yaml.example` | Annotated example showing the format. |
| `README.md` | This file. |

## Commands

| Command | What it does |
|---|---|
| `/resume-queue` | Add, remove, or list jobs in the queue. |
| `/resume-batch` | Run the full pipeline on queued jobs in parallel. |
| `/resume-status` | Dashboard showing all applications and their pipeline stage. |

## Blocked sites

Some job boards block automated access. The blocked domain list lives
in `blocked-sites.yaml` — it's auto-updated whenever a new site
returns a 403. For listed domains, the tool skips the fetch and asks you
to paste the job description directly.

See the current list: `batch/blocked-sites.yaml`

If you encounter a 403 on a site not yet in the list, it will be added
automatically on that first failure.

## Pipeline stages (auto-detected from filesystem)

| Stage | Files that must exist |
|---|---|
| queued | < 3 files in the company folder |
| analyzed | `job-analysis.md` |
| tailored | `resume.pdf` |
| reviewed | `review.md` |
| prepped | `interview-prep.md` |

## Queue lifecycle

Entries are automatically removed from `queue.yaml` when they reach
one of these end states during `/resume-batch`:

| End state | When | Directory cleanup |
|---|---|---|
| prepped | Job completed full pipeline (resume, cover letter, review, prep) | Kept — user may want the files |
| skipped | Job was analyzed but user rejected it (fit too low, hard blockers, or excluded by threshold during the pause) | Deleted — contains only auto-generated analysis |

If a job was skipped, the `applications/<company>/` directory is
automatically deleted during cleanup. Only `job-description.md` and
`job-analysis.md` exist there — nothing the user wrote manually.

## Parallelism

Default is 4 parallel agents per phase. Override with `--parallel N`.
Each job runs in its own `applications/<company>/` directory, so there
are no file conflicts or shared state.
