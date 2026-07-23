Forked from [yapsancode/job-kit](https://github.com/yapsancode/job-kit) via [AdamZikriZailani/job-kit-opencode](https://github.com/AdamZikriZailani/job-kit-opencode).

This fork adds:
- **SKOR scoring** — every tailored resume scored out of 100 across four dimensions
- **Append-only score log** (`batch/skor-log.csv`) tracking every application
- **Tiered fit check** — separates hard blockers from soft gaps, so winnable stretch roles aren't discarded
- **`/skor-summary`** — analytics across all applications: averages, weakest category, recurring gaps, score trend
# Job Kit - A Resume Tailor

Turn one master resume into a job-specific, ATS-safe resume and cover letter
in minutes — using [OpenCode](https://opencode.ai) and LaTeX.

You keep **one** master resume with everything you have ever done. For each
job, you paste the posting and run a few commands. OpenCode reads the job,
picks your most relevant experience, and generates a tailored one-page
resume and cover letter as PDFs — then stress-tests them like a real
recruiter and an ATS robot.

## One-time setup

### 1. Install OpenCode

Follow the instructions at [opencode.ai](https://opencode.ai). Set up an API
key with `/connect` inside OpenCode, or configure a provider in `opencode.json`.

### 2. Install LaTeX and PDF tools

**Linux (Debian/Ubuntu):**
```bash
sudo apt install texlive-latex-recommended texlive-latex-extra texlive-xetex poppler-utils
```

**macOS:**
```bash
brew install --cask mactex-no-gui
brew install poppler
```

**Windows:**
Install [MiKTeX](https://miktex.org) (full installer) and
[poppler for Windows](http://blog.alivate.com.au/poppler-windows/).

### 3. Install the Poppins fonts

Download from [Google Fonts](https://fonts.google.com/specimen/Poppins) and install:

**Linux:** Place the `.ttf` files in `~/.fonts/`, then:
```bash
fc-cache -fv
# If using lualatex as fallback, also refresh its cache:
luaotfload-tool --update --force
```

**macOS:** Double-click each `.ttf` file, then click "Install Font".

**Windows:** Right-click each `.ttf` file, then "Install for all users".

### 4. Verify your setup

```bash
# Confirm the compiler is available
xelatex --version

# Confirm the PDF text extractor is available
pdftotext -v

# Do a test compile of the master resume
xelatex master-resume.tex
# Should produce master-resume.pdf with no errors

# Verify text extraction is clean (no concatenated words)
pdftotext master-resume.pdf - | head -20
# Look for proper spaces between words — not "AIEngineer" etc.
```

### 5. Fill in your master resume

Edit `master-resume.tex` with your real experience. Put **everything** in
here — all jobs, all projects, all skills, all numbers. It can be several
pages. It is never sent anywhere.

If you already have a resume (PDF or Word), inside OpenCode tell it:
> Read my resume file and expand it into master-resume.tex. Then interview
> me one question at a time to fill in missing numbers and details.

The template uses the `\job{ROLE}{DATES}{COMPANY}` command for all entries
and `\bbullet{BOLD LEADIN}{light body text}` for bullet points.

## Single-job workflow

Inside OpenCode, for each job you want to apply to:

```
/resume-analyze  [paste the job posting text or URL]
/resume-tailor   [company-name]
/resume-review   [company-name]
```

All files land in `applications/<company-name>/`. Then, before the interview:

```
/resume-prep [company-name]
```

To keep your master resume current as you ship and learn:

```
/resume-log finished eval harness for my project, accuracy went from 70% to 91%
```

### What each command does

| Command | What it does |
|---------|-------------|
| `/resume-analyze` | Fetches the job posting, extracts requirements ranked by priority, maps each to your master resume (strong match, partial match, or honest gap), researches the company, and saves a report. Writes nothing else yet. |
| `/resume-tailor` | Builds `resume.tex` and `cover-letter.tex` from your master resume. Selects only the most relevant experience, reorders for impact, compiles both to PDF with `xelatex`, and writes a changelog of what changed and why. |
| `/resume-review` | Two strict reviews: a skeptical recruiter scans the top third in 10 seconds, and an ATS robot checks keyword coverage and text extraction order. Scores both out of 10 and gives a numbered fix list. |
| `/resume-prep` | Generates 10 likely interview questions with STAR answers built from your real experience, honest ways to address skill gaps, and 5 smart questions to ask them. Can run a mock interview. |
| `/resume-log` | Files a new achievement into `master-resume.tex` as a proper bullet. Keeps your facts exact and ready for the next application. |

The commands are Markdown files in `.opencode/commands/`. Open and edit them
to match your workflow.

## Batch processing (multi-job)

Queue up 5-20 job posting URLs and let OpenCode process them in parallel.

### Step 1: Add jobs to the queue

```
/resume-queue add https://boards.greenhouse.io/acme/jobs/123
/resume-queue add https://linkedin.com/jobs/view/456 --note "referred by Alex"
```

The queue lives in `batch/queue.yaml`. You can also edit it directly.

### Step 2: Run the pipeline

```
/resume-batch
```

This runs analyze on every job in parallel, shows a ranked fit table, and
pauses for you to choose which jobs to continue. Reply with "all", "1,3,5",
or ">=6" for a minimum fit score.

### Step 3: Check progress

```
/resume-status
```

Shows a dashboard of all applications and their pipeline stage: queued,
analyzed, tailored, reviewed, or prepped.

### Batch commands

| Command | What it does |
|---------|-------------|
| `/resume-queue add <url>` | Add a job to the queue |
| `/resume-queue remove <index>` | Remove a job by its number |
| `/resume-queue list` | Show all queued jobs with their current stage |
| `/resume-queue clean` | Remove all finished (prepped) jobs from the queue |
| `/resume-batch` | Process all queued jobs in parallel (default 4 at a time) |
| `/resume-status` | Dashboard of all applications and stages |

### Batch options

```
/resume-batch --analyze-only       stop after the fit ranking
/resume-batch --jobs 1,3,5         process only specific queue entries
/resume-batch --parallel 6         override default parallelism (default: 4)
```

Completed jobs are automatically removed from `batch/queue.yaml` after
successful processing — no manual cleanup needed.

### Pipeline stages

Each application directory auto-detects its stage from which files exist:

| Stage | Files present |
|-------|--------------|
| queued | `< 3 files` |
| analyzed | `job-analysis.md` |
| tailored | `resume.pdf` |
| reviewed | `review.md` |
| prepped | `interview-prep.md` |

## File structure

```
job-kit/
  master-resume.tex           your single source of truth
  opencode.json               OpenCode config (permissions, model)
  CLAUDE.md                   project rules (read automatically)
  batch/
    queue.yaml                your job queue
  applications/
    acme-corp/
      job-description.md      raw posting
      job-analysis.md         requirement-to-experience map
      resume.tex              tailored resume source
      resume.pdf              ready-to-send PDF
      cover-letter.tex        cover letter source
      cover-letter.pdf        ready-to-send PDF
      changelog.md            what changed vs master, and why
      review.md               recruiter + ATS scores and fixes
      interview-prep.md       questions, STAR answers, mock prep
```

## The core rules

OpenCode follows these rules from `CLAUDE.md` every session:

1. **Only `master-resume.tex` is truth.** Nothing is ever invented,
   exaggerated, or guessed. If a skill is missing, it is reported as a gap.
2. **ATS-safe formatting** — single column, standard headings, no tables or
   graphics. Contact info in the body, not a header/footer.
3. **Visual consistency** — Poppins fonts, #7798A7 accent color, " | "
   separators, no em dashes. Compiles with `xelatex`.
4. **One page** per tailored resume (two only if 10+ years experience).

## Troubleshooting

**"Font Poppins not found" or compile errors:**
Make sure the Poppins `.ttf` files are installed system-wide (not just in
a user directory that LaTeX cannot see). Run `fc-cache -fv` and try again.
If using lualatex, also run `luaotfload-tool --update --force`.

**Words concatenated in PDF text extraction:**
This is a `lualatex` artifact. Install `texlive-xetex` and recompile with
`xelatex` — it produces clean, separable text that ATS parsers read correctly.

**xelatex not found:**
```bash
sudo apt install texlive-xetex     # Linux
brew install --cask mactex-no-gui  # macOS
```

**pdftotext not found:**
```bash
sudo apt install poppler-utils     # Linux
brew install poppler               # macOS
```

**Approval prompts during batch processing:**
The project's `opencode.json` pre-approves external directory access for
system tools like `xelatex` and `pdftotext`. If you still see prompts,
run OpenCode with `--auto`.

## License

MIT — see [LICENSE](LICENSE). Free to use, fork, and share.
