#!/usr/bin/env bash
# Compile every .tex in the workspace with xelatex and run a text-extraction
# check on each PDF, as required by the ATS rules in CLAUDE.md.
#
#   ./build.sh              compile everything
#   ./build.sh applications/adam/citi-kyc-operations-analyst
#                           compile only the .tex files under that path
#
# Poppins is the design font. If it is not installed, styles/skorresume.sty
# falls back to Lato automatically and prints a note below.

set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export TEXINPUTS="${REPO}/styles:"

TARGET="${1:-$REPO}"

if ! command -v xelatex >/dev/null 2>&1; then
  echo "xelatex not found. Install texlive-xetex, then run this again." >&2
  exit 1
fi

if fc-list 2>/dev/null | grep -qi poppins; then
  echo "Font: Poppins found, using the intended design font."
else
  echo "Font: Poppins NOT installed, falling back to Lato."
  echo "      Install from https://fonts.google.com/specimen/Poppins and"
  echo "      re-run to get the exact intended look. No .tex edits needed."
fi
echo

status=0

while IFS= read -r -d '' tex; do
  dir="$(dirname "$tex")"
  base="$(basename "$tex" .tex)"

  # Two passes so hyperref page labels settle.
  ( cd "$dir" && xelatex -interaction=nonstopmode -halt-on-error "$base.tex" \
      >/dev/null 2>&1 \
    && xelatex -interaction=nonstopmode -halt-on-error "$base.tex" \
      >/dev/null 2>&1 )

  pdf="$dir/$base.pdf"
  if [[ ! -f "$pdf" ]]; then
    echo "FAIL  $tex (see $dir/$base.log)"
    status=1
    continue
  fi

  pages=$(pdfinfo "$pdf" 2>/dev/null | awk '/^Pages:/ {print $2}')

  # Text-extraction check: a PDF whose text comes out empty, or whose hyphens
  # come out as U+2010, will be misread by an ATS.
  words=$(pdftotext "$pdf" - 2>/dev/null | wc -w)
  badhyphen=$(pdftotext "$pdf" - 2>/dev/null | grep -c $'‐')

  note=""
  [[ "$words" -lt 50 ]] && { note="$note  TEXT-EXTRACTION-EMPTY"; status=1; }
  [[ "$badhyphen" -gt 0 ]] && { note="$note  NON-ASCII-HYPHEN"; status=1; }
  if [[ "$base" == resume* && "$pages" -gt 1 ]]; then
    note="$note  OVER-ONE-PAGE"
    status=1
  fi

  printf 'ok    %-58s %s page(s), %s words%s\n' \
    "${tex#$REPO/}" "$pages" "$words" "$note"

  ( cd "$dir" && rm -f "$base".{aux,log,out,fls,fdb_latexmk} )
done < <(find "$TARGET" -name '*.tex' -not -path '*/.git/*' -print0 | sort -z)

echo
if [[ "$status" -eq 0 ]]; then
  echo "All documents compiled and passed the extraction check."
else
  echo "Some documents need attention (see flags above)."
fi
exit "$status"
