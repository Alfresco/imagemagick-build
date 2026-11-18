#!/bin/bash -e
# Tests for fixed-advisories.jq and advisory-summary.jq against a small advisory fixture, no network needed.
set -o pipefail

BASE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
SCRIPTS="$BASE_DIR/../scripts"
FIXTURE="$BASE_DIR/fixtures/advisories.json"
# shellcheck source=SCRIPTDIR/lib.sh
source "$BASE_DIR/lib.sh"

report() {
  jq -r -L "$SCRIPTS" --arg old "$2" --arg new "$3" -f "$SCRIPTS/$1" "$FIXTURE"
}

rows() { report fixed-advisories.jq "$@"; }
summary() { report advisory-summary.jq "$@"; }

ordered_ids() {
  rows "$1" "$2" | grep -o '^| \[GHSA-[a-z0-9-]*' | cut -c4- | tr '\n' ' '
}

ids() {
  ordered_ids "$1" "$2" | tr ' ' '\n' | sort | tr '\n' ' '
}

assert_eq "lists advisories fixed after the old version, up to and including the new one" \
  "GHSA-new1 GHSA-new2 " "$(ids 7.1.2-31 7.1.2-35)"
assert_eq "compares revisions as numbers, not text" \
  "GHSA-ten-vs-nine " "$(ids 7.1.2-8 7.1.2-9)"
assert_eq "lists nothing when no advisory falls in the range" "" "$(ids 7.1.2-36 7.1.2-39)"
assert_eq "uses the 7.x entry when an advisory patches several lines" \
  "GHSA-new2 " "$(ids 7.1.2-33 7.1.2-34)"

assert_eq "matches an advisory patched on several 7.x lines against the line being bumped" \
  "GHSA-multi-entries GHSA-multi-string " "$(ids 7.1.2-36 7.1.2-40)"
assert_eq "also matches an older 7.x line when the bump crosses it" \
  "GHSA-multi-entries GHSA-multi-string " "$(ids 7.0.10 7.0.11)"

ROWS=$(rows 7.1.2-31 7.1.2-35)
assert_eq "renders a table row with link, CVE, severity, summary and fixed version" \
  "| [GHSA-new1](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-new1) | CVE-2026-0001 | high | Heap overflow \\| in PNG | 7.1.2-35 |" "$(grep GHSA-new1 <<< "$ROWS")"
assert_eq "shows a dash when an advisory has no CVE" \
  "| [GHSA-new2](https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-new2) | - | low | Leak in TIFF | 7.1.2-34 |" "$(grep GHSA-new2 <<< "$ROWS")"

assert_eq "lists the most severe advisories first, then by fixed version" \
  "GHSA-critical GHSA-new1 GHSA-ten-vs-nine GHSA-at-old GHSA-multi-string GHSA-multi-entries GHSA-new2 GHSA-too-new " \
  "$(ordered_ids 7.1.2-8 7.1.2-40)"

assert_eq "summarizes the fixed advisories per severity, with a total" \
  "| Severity | Count |
| --- | ---: |
| critical | 0 |
| high | 1 |
| medium | 0 |
| low | 1 |
| **Total** | **2** |" "$(summary 7.1.2-31 7.1.2-35)"
assert_eq "counts every severity in the summary" \
  "| critical | 1 |
| high | 1 |
| medium | 4 |
| low | 2 |
| **Total** | **8** |" "$(summary 7.1.2-8 7.1.2-40 | tail -n 5)"

finish
