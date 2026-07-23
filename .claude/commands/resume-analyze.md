---
description: Analyze a job posting against your master resume
---

Analyze this job posting. The job description (or a URL to it) follows:

$ARGUMENTS

Steps:
1. If I gave a URL, fetch it. If I gave nothing, ask me to paste the job description.
2. Identify the company name and role. Create the folder `applications/<company-name>/`
   and save the raw posting as `job-description.md`.
3. Extract the requirements and rank each by priority 1-10 based on how much
   the posting emphasizes it (mentioned in title/first lines = high; "nice to
   have" = low).
4. List the exact keywords and phrases the posting uses (skills, tools,
   methods, certifications). These matter for ATS keyword matching.
5. Read `master-resume.tex` and map each requirement to my real experience:
   - STRONG match (I clearly have it)
   - PARTIAL match (related experience, needs careful wording)
   - GAP (I don't have it — be honest, do not invent)

## Step 6: Classify every GAP as HARD BLOCKER or SOFT GAP

Gate-checking is tiered, not binary. For every requirement marked GAP in
Step 5, classify it as exactly one of the two:

**HARD BLOCKER** — only these four categories count, nothing else:
1. Missing work authorization for the job's location.
2. A legally required licence or certification for the role.
3. A language required for day-to-day delivery of the role (not "nice to
   have" or "a plus" — stated as a requirement to actually do the job).
4. A regulated qualification the role cannot legally be performed without.

**SOFT GAP** — everything else that isn't one of the four above: years of
experience short of the stated minimum, an industry mismatch, a specific
tool or platform not used before, a nice-to-have skill, fewer direct years
in a function, a certification that's preferred but not legally required,
etc.

Be strict about this split — don't let a SOFT GAP get inflated into a HARD
BLOCKER just because it looks important in the posting. Only the four listed
categories block the pipeline.

## Step 7: Compensating-strength analysis for every SOFT GAP

For each SOFT GAP identified in Step 6, check `master-resume.tex` for a
credible adjacent substitute and state it explicitly. Examples of what
counts as a credible substitute:
- Account management or retention experience in a different industry
  substituting for direct experience in the posting's industry.
- Experience with one CRM/tool substituting for fluency in a different but
  comparable one named in the posting.
- Strong quantified performance (a real number from the master resume)
  substituting for slightly fewer years of experience than the posting asks
  for.

For each SOFT GAP, write either:
- "Compensating strength: <specific thing from master-resume.tex>, because
  <why it's a credible substitute>", or
- "No compensating strength found" if nothing in the master resume offsets
  it honestly. Do not invent one.

## Step 8: Company research

If you have web access, briefly research the company: what they do, recent
news, culture signals. 5-8 lines maximum.

## Step 9: Verdict

Give exactly one of three verdicts, based on Steps 6-7:

- **STRONG FIT** — meets most requirements (mostly STRONG/PARTIAL matches,
  no more than minor SOFT GAPS). Tailor normally.
- **STRETCH, APPLY ANYWAY** — no HARD BLOCKERS, but one or more SOFT GAPS
  exist alongside real compensating strengths. Tailor normally, but
  explicitly list in `job-analysis.md`:
  - which SOFT GAPS the cover letter must address head-on, and
  - how (which compensating strength from Step 7 to lead with, and how to
    phrase it honestly — name the gap directly rather than hoping it goes
    unnoticed).
  Note in the analysis that the resume should lead with the compensating
  strengths (reorder the top third of the page around them) when
  `/resume-tailor` runs.
- **SKIP** — one or more HARD BLOCKERS are present. Recommend not
  proceeding. This is the only verdict that stops the pipeline before
  tailoring.

## Step 10: Save and summarize

Save everything as `applications/<company-name>/job-analysis.md`:
requirement/priority table, ATS keyword list, STRONG/PARTIAL/GAP match
table, the HARD BLOCKER vs. SOFT GAP breakdown with compensating-strength
notes, company research, and the verdict (with cover-letter guidance if
STRETCH).

Show me a short summary: top 5 requirements, my match level for each, the
verdict, and:
- if STRETCH: the specific gaps the cover letter needs to name and the
  compensating strength to pair with each,
- if SKIP: the exact hard blocker(s) found.

Do not write the resume yet. That is the /resume-tailor step — for STRONG
FIT and STRETCH verdicts I can proceed there directly; for SKIP, see Step 11.

## Step 11: If I decide to skip this job

If I tell you to skip/reject this job — whether because of a SKIP verdict
(hard blocker) or any other reason I give — log the skip instead of just
dropping it:

1. Append one row to `batch/skor-log.csv` (create it with the header
   `date,company,role,S_score,K_score,O_score,R_score,total,top_gaps` first
   if the file is missing).
2. Row format:
   ```
   YYYY-MM-DD,<company>,<role>,,,,,SKIPPED,"<blocking requirement(s)>"
   ```
   - Leave `S_score`, `K_score`, `O_score` blank — no scoring happened,
     nothing was tailored.
   - `total` is the literal string `SKIPPED`.
   - `top_gaps` holds the specific blocking requirement(s) that caused the
     skip (pipe-separated if more than one), wrapped in double quotes. For a
     SKIP verdict, use the exact HARD BLOCKER category and detail (e.g.
     "language required for delivery: fluent German").
3. Append to the end of the file — don't rewrite the whole CSV, don't touch
   existing rows.
4. Also note the skip at the top of `job-analysis.md` (status + date +
   reason), as already done for this application.
5. Confirm to me: "Logged as skipped in batch/skor-log.csv."

This keeps a record of jobs rejected at the gate-check stage, separate from
`/resume-review` rows for jobs that were actually tailored and scored. See
`/skor-summary` for how skip rows are reported.
