# Project rules for this job-search workspace

OpenCode reads this file automatically at the start of every session.
These rules apply to every command and every generated document.

## Dual command directories
Slash commands are duplicated in two places: `.claude/commands/` (read by
Claude Code) and `.opencode/commands/` (read by OpenCode). `.claude/commands/`
is the single source of truth. When editing any command file, make the
change in `.claude/commands/` first, then copy the same content into the
matching file in `.opencode/commands/` in the same step. Never edit only one
side — the two must stay identical or the tools drift out of sync silently.

## Multiple candidates
This workspace supports more than one job seeker. Each candidate has their
own master resume, and applications are grouped per candidate:

```
candidates/<candidate>/master-resume.tex     ground truth for that person
applications/<candidate>/<company-slug>/     one folder per application
styles/skorresume.sty                        shared styling for every document
build.sh                                     compile + ATS-check everything
```

Rules that follow from this:
- A tailored resume may ONLY draw on the master resume of its own
  candidate. Never mix facts between candidates.
- Where these rules say `master-resume.tex`, read it as "the master resume
  of the candidate this application belongs to".
- Each master resume keeps an OPEN QUESTIONS comment block at the top,
  listing things not yet confirmed by that candidate. Items there are NOT
  facts and must never appear on a tailored resume until confirmed.
- Compile with `./build.sh` (all documents) or `./build.sh <path>` (one
  folder). It runs xelatex, then checks every PDF for page count, empty
  text extraction, and non-ASCII hyphens.
- Poppins stays the design font. `styles/skorresume.sty` falls back to Lato
  automatically when Poppins is not installed, with no edit to any `.tex`.

## Ground truth
- `master-resume.tex` is the ONLY source of truth about the candidate.
- NEVER invent, exaggerate, or assume jobs, titles, dates, skills, tools,
  metrics, or achievements. If information is missing, ASK the user.
- If a job requirement is not covered by the master resume, report it as a
  gap. Do not paper over it. Honest gaps are useful; fabrication is not.
- Never fabricate, exaggerate, or imply skills, tools, or experience that
  are not in `master-resume.tex`. If something is missing, report it as a
  gap; do not invent a workaround.
- Keep job titles exactly as they appear in `master-resume.tex`. Never
  adjust a title to match the target job posting's title.

## Visual design (matches Resume_base.pptx)
The template uses the Poppins font family with an accent color scheme.
Every generated resume must follow these styling rules:

- **Fonts:** Poppins (requires system install: Light, Regular, Medium, Bold).
  Download from https://fonts.google.com/specimen/Poppins
- **Colors:** body text #394349, accent #7798A7 (section rules, role titles).
- **Name:** 23 pt, Poppins Bold, centered.
- **Title/headline:** 11 pt, Poppins Light, accent color, centered.
- **Contact line:** 8 pt, Poppins Light, " | " separators, centered.
- **Section titles:** 13 pt, Poppins Medium, all caps, #394349, with a thin
  (0.75 pt) #7798A7 horizontal rule immediately below.
- **Role titles:** 9 pt, Poppins Medium, accent color.
- **Company name:** 9 pt, Poppins Light italic, #394349 (line below role).
- **Location | dates:** 9 pt, Poppins Light italic, right-aligned on the same
  line as the role title.
- **Bullet text:** 8 pt, Poppins Light, justified. Emphasize the first key
  phrase of each bullet with Poppins Bold (use \textbf{} inside \item).
- Use the `\job{ROLE}{LOCATION | DATES}{COMPANY}` command from the master
  template for all work experience, project, and education entries.

## ATS-safe formatting rules (apply to every generated resume)
- Single column only. No tables, no text boxes, no images, no icons.
- Skills section must be plain text (comma- or line-separated). Never a
  table -- tables break ATS parsing.
- Contact info in the document body, not in a page header/footer.
- Standard section names only: Summary, Skills, Work Experience,
  Projects, Education, Certifications.
- Reverse-chronological order (most recent first).
- One consistent date format, e.g. "Jan 2023 - Present".
- No em dashes. Use " | " as a separator in the contact line and in
  location/date lines; inside sentences, restructure or use a colon or
  hyphen.
- Keep the tailored resume to ONE page (two only if 10+ years experience).
- Compile with **xelatex** (not pdflatex). If xelatex is not available,
  lualatex works but may concatenate words in text extraction (an ATS risk).
  After compiling, run a text-extraction check: prefer `pdftotext` (faster),
  fall back to `pdfplumber` (Python). Confirm the text reads top-to-bottom
  in the correct order with no word concatenation.
- If using lualatex and fonts are not found, refresh the cache:
  `luaotfload-tool --update --force`.

## Writing style for bullets
- Start with an action verb. Include a real number where the master resume
  provides one. Never fabricate numbers.
- Mirror the job description's exact wording ONLY when it truthfully
  describes the candidate's experience.

## Banned words
- Do not use these words, or similar AI-sounding buzzwords, in any
  generated content (resumes, cover letters, analyses, prep notes):
  leverage, seamless, spearhead, foster, harness, pivotal, synergy.
- Write in plain, human language instead.

## Cover letter format
- Use Swiss/British business letter format.
- Open with "Dear [Name],". Close with "Yours sincerely,".

## Resume review: the SKOR method
Score every tailored resume out of 100 using SKOR (keep the Malay labels
as-is):
- **S - Sasaran Kerja** (40 pts): how well the experience targets the job's
  core responsibilities.
- **K - Kejayaan KPI** (40 pts): quantified achievements and metrics.
- **O - Optimum Look** (10 pts): ATS-safe formatting and scannability.
- **R - Real & Raw** (10 pts): authenticity, no fabrication.

When reviewing a tailored resume, act as a senior recruiter with 10+ years
of experience plus an ATS specialist:
- Give an upfront, honest fit verdict and a "7-second scan" read: what a
  recruiter would notice in the first pass.
- Gate-check hard requirements from the job posting (must-have years,
  certifications, tools, work authorization, etc.).
- Flag real gaps candidly. Never soften or hide a gap to make the fit look
  better than it is.

`/resume-review` appends each application's SKOR result as one row to
`batch/skor-log.csv` (never overwrites existing rows). Use `/skor-summary`
to see average scores, the weakest SKOR category, recurring gaps, and the
trend over time across all logged applications.

## Distinguishing education, work, and projects
- Bootcamps, academies, and training programmes are EDUCATION, not work
  experience — even if intensive or full-time. Place them under Education.
- Capstone or course projects belong under Projects, where strong technical
  work can still stand out. Do not duplicate the same project in two
  sections.

## File organization
Each application lives in `applications/<company-name>/`:
- `job-description.md` — the original posting text
- `job-analysis.md` — output of /resume-analyze
- `resume.tex` + `resume.pdf`
- `cover-letter.tex` + `cover-letter.pdf`
- `changelog.md` — every change vs. master resume, with a one-line reason
- `review.md` — output of /resume-review
- `interview-prep.md` — output of /resume-prep

## Multi-job batch workflow
- The batch job queue lives at `batch/queue.yaml`. Each entry has a `url`
  and an optional `notes` field. There is no stage column — pipeline
  stage is always detected from which files exist in the application
  directory.
- Use `/resume-queue` (or `/queue`) to add, remove, list, or clean entries
  in the queue. Use `/resume-batch` (or `/batch`) to process queued jobs
  through the pipeline. Use `/resume-status` (or `/status`) for a
  dashboard view across all applications.
- During batch processing, delegate each job to a subagent (Task tool)
  so multiple jobs run in parallel. Each subagent works in its own
  `applications/<company>/` directory — no file conflicts.
- Default parallelism is 4. The user may override with `--parallel N`.
- After the analyze phase, always pause and show a ranked fit summary
  before proceeding. Continue through tailor, review, and prep only
  for jobs the user selects.
- Pipeline stages (auto-detected from filesystem):
  queued (<3 files) → analyzed (job-analysis.md) → tailored (resume.pdf)
  → reviewed (review.md) → prepped (interview-prep.md).
- After batch processing, clean up the queue: remove entries that reached
  "prepped" (completed successfully) AND entries that were analyzed but
  skipped by the user (fit too low, hard blockers, excluded by threshold).
  End states = prepped or skipped. Dead entries should never linger.
- The batch workflow is additive. Existing single-job commands
  (`/resume-analyze`, `/resume-tailor`, etc.) continue to work as before.
- Batch commands live in `.opencode/commands/resume-batch.md`,
  `.opencode/commands/resume-queue.md`, and
  `.opencode/commands/resume-status.md`.

## Language
- Explain things in simple, clear language. Some users are not native
  English speakers. Avoid jargon, or explain it when unavoidable.

## Quality assurance: triple-check
Before presenting any deliverable (resume, cover letter, analysis, prep
notes), run three passes:
1. **Accuracy pass** - every fact matches `master-resume.tex`.
2. **Humanise pass** - reads naturally, not AI-generated.
3. **Tone-match pass** - matches the target company/role's tone.

## Handling blocked job sites

Many job boards block automated access (Cloudflare, captcha, 403).
Before any `/resume-queue add`, read `batch/blocked-sites.yaml` to
get the current list. When the URL matches a listed domain:

1. **Skip the fetch** — do not attempt to HTTP GET the URL.
2. **Ask for paste** — prompt the user to paste the full job description.
3. **Parse from paste** — extract company name and role title from the
   pasted text, derive the kebab-case slug, and proceed.

For domains NOT in the list: attempt the fetch as normal. If it fails
with 403, **append the domain to `batch/blocked-sites.yaml`** and then
ask the user to paste.

This turns a 3-message flow (fetch → fail → ask) into a 1-message flow
(add → paste) for all known-blocked domains, and auto-discovers new
ones.
