#!/bin/bash -e
# Tests for fixed-advisories.jq against a small advisory fixture, no network needed.
#
#   ./.github/scripts/test-fixed-advisories.sh
set -o pipefail

BASE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
FILTER="$BASE_DIR/fixed-advisories.jq"
FIXTURE="$BASE_DIR/fixtures/advisories.json"
FAILURES=0

assert_eq() {
  local desc="$1" expected="$2" actual="$3"
  if [ "$expected" = "$actual" ]; then
    echo "ok - $desc"
  else
    echo "FAIL - $desc"
    echo "  expected: $expected"
    echo "  actual:   $actual"
    FAILURES=$((FAILURES + 1))
  fi
}

ids() {
  jq -r --arg old "$1" --arg new "$2" -f "$FILTER" "$FIXTURE" | grep -o '^| \[GHSA-[a-z0-9-]*' | cut -c4- | sort | tr '\n' ' '
}

assert_eq "lists advisories fixed after the old version, up to and including the new one" \
  "GHSA-new1 GHSA-new2 " "$(ids 7.1.2-31 7.1.2-35)"
assert_eq "compares revisions as numbers, not text" \
  "GHSA-ten-vs-nine " "$(ids 7.1.2-8 7.1.2-9)"
assert_eq "lists nothing when no advisory falls in the range" "" "$(ids 7.1.2-35 7.1.2-36 | sed 's/GHSA-too-new //')"
assert_eq "uses the 7.x entry when an advisory patches several lines" \
  "GHSA-new2 " "$(ids 7.1.2-33 7.1.2-34)"

ROW=$(jq -r --arg old 7.1.2-31 --arg new 7.1.2-35 -f "$FILTER" "$FIXTURE" | grep GHSA-new1)
assert_eq "renders a table row with link, CVE, severity, summary and fixed version" \
  "| [GHSA-new1](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-new1) | CVE-2026-0001 | high | Heap overflow \\| in PNG | 7.1.2-35 |" "$ROW"
ROW=$(jq -r --arg old 7.1.2-31 --arg new 7.1.2-35 -f "$FILTER" "$FIXTURE" | grep GHSA-new2)
assert_eq "shows a dash when an advisory has no CVE" \
  "| [GHSA-new2](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-new2) | - | low | Leak in TIFF | 7.1.2-34 |" "$ROW"

if [ "$FAILURES" -gt 0 ]; then
  echo "$FAILURES test(s) failed"
  exit 1
fi
echo "All tests passed."
