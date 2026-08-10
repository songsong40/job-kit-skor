# Candidates

One folder per job seeker. Each folder holds that person's master resume,
which is the only source of truth for their applications.

```
candidates/
  <candidate>/
    master-resume.tex     everything true about this person
applications/
  <candidate>/
    <company-slug>/
      job-description.md  the posting as pasted
      job-analysis.md     requirements, matches, gaps, verdict
      resume.tex/.pdf     tailored, one page
      cover-letter.tex/.pdf
      changelog.md        every change vs the master, with a reason
      review.md           /resume-review output
      interview-prep.md   /resume-prep output
```

## Privacy

`candidates/*` and `applications/*` are both in `.gitignore`. They contain
real names, emails and phone numbers, so they stay on your machine and are
never committed. Only this README, the tooling and the workspace rules are
tracked in git.

If you are working on behalf of someone else, keep it that way. Their
contact details are not yours to publish.

## Adding a candidate

1. Create `candidates/<name>/master-resume.tex`.
2. Put **everything** true about them in it, including detail that would not
   fit on a one-page resume. The tailoring step picks what is relevant per
   job; over-sharing here is good.
3. Keep an `OPEN QUESTIONS` comment block at the top for anything not yet
   confirmed. Items listed there are not facts and must not appear on a
   tailored resume until the candidate confirms them.
4. Use `\usepackage{skorresume}` and the `\job`, `\edu`, `\jobbullets`,
   `\skillline` and `\plainblock` commands, so every document in the
   workspace looks the same.

## Building

```
./build.sh                                  compile everything
./build.sh applications/adam/citi-kyc-operations-analyst
                                            compile one folder
```

The script runs xelatex and then checks every PDF for page count, empty text
extraction, and non-ASCII hyphens, which are the three things that quietly
break an ATS.

Poppins is the design font. If it is not installed, `styles/skorresume.sty`
falls back to Lato automatically and the build prints a note. Install Poppins
from https://fonts.google.com/specimen/Poppins and rebuild to get the exact
intended look; no `.tex` file needs editing.
