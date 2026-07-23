---
description: Recruiter and ATS review of an application, scored with SKOR
---

Review the application for: $ARGUMENTS
(If no company name given, use the most recent folder in `applications/`.)

Act as a senior recruiter with 10+ years of experience, plus an ATS
specialist. Be strict and candid. Save results as `review.md` in the
company folder, append a row to `batch/skor-log.csv`, and show me the
summary.

## Step 1: Upfront verdict

Before the detailed review, give:
- An honest fit verdict in one or two sentences.
- A "7-second scan" read: what a recruiter actually notices skimming
  resume.pdf top-to-bottom for 7 seconds. If the match with the job isn't
  obvious in that window, say exactly what to move up.

## Step 2: Gate-check hard requirements

Read `job-analysis.md` (or `job-description.md` if analysis doesn't exist)
and list the posting's hard requirements (minimum years, required
certifications/tools, work authorization, language, etc.). For each, mark
PASS or FAIL against `master-resume.tex` and resume.pdf. Do not soften a
FAIL to make the fit look better than it is.

## Step 3: Recruiter read

- Flag anything vague, exaggerated, or buzzword-empty (see the banned
  words list in CLAUDE.md).
- Flag any bullet without a concrete result where the master resume
  actually contains a number we forgot to use.
- Read the cover letter: would a tired recruiter finish it? Flag cliches
  and confirm it uses the Swiss/British format ("Dear [Name]," /
  "Yours sincerely,").

## Step 4: ATS robot test

- Extract raw text from resume.pdf. Use `pdftotext` (poppler-utils) for
  fast, reliable extraction. If pdftotext is not installed, fall back to
  `python3 -c "import pdfplumber; ..."` or similar.
- Check: does the text read top-to-bottom in correct order? Are name,
  email, and phone present in the extracted text? Are section headings
  standard? Is the date format consistent? Is the skills section plain
  text (not a table)?
- Flag any word concatenation (e.g. "AIEngineer" instead of "AI Engineer").
  This is a lualatex artifact; recompile with xelatex to fix.
- Compare extracted text against the keyword list in job-analysis.md.
  Report keywords covered and keywords missing. For each missing keyword,
  classify honestly: (a) wording problem — I have the experience, we can
  rephrase truthfully, or (b) real gap — do NOT add it.

## Step 5: Score with SKOR

Score out of 100 using SKOR (see CLAUDE.md for full definitions):
- **S — Sasaran Kerja** (0-40): how well the experience targets the job's
  core responsibilities.
- **K — Kejayaan KPI** (0-40): quantified achievements and metrics actually
  present in the resume.
- **O — Optimum Look** (0-10): ATS-safe formatting and scannability
  (from Step 4).
- **R — Real & Raw** (0-10): authenticity — no fabrication, no implied
  skills not in `master-resume.tex`.

Report each sub-score, the total, and a short numbered fix list. Ask me if
I want you to apply the fixes.

## Step 6: Log the result

Append exactly one row to `batch/skor-log.csv` (create it with the header
`date,company,role,S_score,K_score,O_score,R_score,total,top_gaps` first if
the file is missing). Never overwrite or reorder existing rows — only
append.

Row format:
```
YYYY-MM-DD,<company>,<role>,<S>,<K>,<O>,<R>,<total>,"<gap1 | gap2 | gap3>"
```
- `date`: today's date, ISO format (`YYYY-MM-DD`).
- `company`: the `applications/<company-name>/` slug.
- `role`: the role title from `job-analysis.md`/`job-description.md`.
- `top_gaps`: the 1-3 most significant gaps or FAILs from Steps 2-4,
  pipe-separated, wrapped in double quotes (so commas inside a gap
  description don't break the CSV). If there are no real gaps, use
  `"none"`.

Append the line to the end of the file — don't rewrite the whole CSV.
