#!/usr/bin/env bash
# sanitize-check.sh — fail-closed public-safety gate for Raegis Labs public repos.
#
# Exit 0 = clean. Exit 1 = forbidden pattern found in a tracked file.
#
# Patterns live in config/forbidden-patterns.txt (data, not code):
#   - one extended regex (grep -E) per line
#   - "pattern || exclusion" form: matching lines that ALSO match the exclusion
#     are ignored (used for e.g. loopback IPs inside the IPv4 rule)
#   - blank lines and # comments are skipped
#
# macOS-portable by design: no grep -P, no GNU-only flags. Word boundaries are
# avoided in favour of broad-match-then-exclude, because the gate must run on
# a Mac before every push.
#
# Run before every push, and again against a fresh clone after pushing.
set -uo pipefail
cd "$(git rev-parse --show-toplevel)" || exit 2

PATTERNS="config/forbidden-patterns.txt"
SELF_EXCLUDE='^config/forbidden-patterns\.txt$'   # the pattern file matches itself by design

if [ ! -f "$PATTERNS" ]; then
  echo "sanitize-check: missing $PATTERNS" >&2
  exit 2
fi

# Tracked files, minus the pattern file itself. Filenames here contain no
# spaces or newlines, so newline -> NUL translation is safe.
mapfile_list() { git ls-files | grep -v "$SELF_EXCLUDE" | tr '\n' '\0'; }

if [ -z "$(git ls-files)" ]; then
  echo "sanitize-check: no tracked files yet — nothing to scan"
  exit 0
fi

FAIL=0
SCANNED=$(git ls-files | grep -v "$SELF_EXCLUDE" | wc -l | tr -d ' ')

while IFS= read -r line || [ -n "$line" ]; do
  case "$line" in ""|\#*) continue ;; esac

  pattern="$line"
  exclusion=""
  case "$line" in
    *"||"*)
      pattern="${line%%||*}"
      exclusion="${line#*||}"
      ;;
  esac
  # trim surrounding whitespace on both halves
  pattern="${pattern%"${pattern##*[![:space:]]}"}"
  pattern="${pattern#"${pattern%%[![:space:]]*}"}"
  exclusion="${exclusion%"${exclusion##*[![:space:]]}"}"
  exclusion="${exclusion#"${exclusion%%[![:space:]]*}"}"
  [ -z "$pattern" ] && continue

  hits=$(git ls-files | grep -v "$SELF_EXCLUDE" | tr '\n' '\0' \
         | xargs -0 grep -InE -- "$pattern" 2>/dev/null || true)
  if [ -n "$exclusion" ] && [ -n "$hits" ]; then
    hits=$(printf '%s\n' "$hits" | grep -vE -- "$exclusion" || true)
  fi

  if [ -n "$hits" ]; then
    echo "FAIL  /$pattern/"
    printf '%s\n' "$hits" | sed 's/^/      /'
    echo
    FAIL=1
  fi
done < "$PATTERNS"

if [ "$FAIL" -eq 0 ]; then
  echo "sanitize-check: clean ($SCANNED tracked files scanned)"
fi
exit "$FAIL"
