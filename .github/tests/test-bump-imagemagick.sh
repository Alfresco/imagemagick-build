#!/bin/bash -e
# Tests for bump-imagemagick.sh in a throwaway copy of the repo layout.
set -o pipefail

BASE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
BUMP="$BASE_DIR/../scripts/bump-imagemagick.sh"
WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT
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

new_root() {
  local root
  root=$(mktemp -d -p "$WORK_DIR")
  mkdir -p "$root/debs" "$root/rpms"
  printf '7.1.2-31\n' > "$root/imagemagick-version"
  printf '3\n' > "$root/release-version"
  echo "patch 31" > "$root/debs/after-checkout-ubuntu2404-7.1.2-31.sh"
  echo "patch 13" > "$root/debs/after-checkout-ubuntu2404-7.1.2-13.sh"
  echo "rpm patch 31" > "$root/rpms/after-checkout-rockylinux8-7.1.2-31.sh"
  echo "$root"
}

ROOT=$(new_root)
OUT=$("$BUMP" 7.1.2-35 "$ROOT")
assert_eq "the version file holds the new version" "7.1.2-35" "$(cat "$ROOT/imagemagick-version")"
assert_eq "the release version resets to 1" "1" "$(cat "$ROOT/release-version")"
assert_eq "a deb override of the old version is copied for the new one" \
  "patch 31" "$(cat "$ROOT/debs/after-checkout-ubuntu2404-7.1.2-35.sh")"
assert_eq "an rpm override of the old version is copied for the new one" \
  "rpm patch 31" "$(cat "$ROOT/rpms/after-checkout-rockylinux8-7.1.2-35.sh")"
assert_eq "only the override of the old version is carried over, not those of older ones" \
  "1" "$(ls "$ROOT/debs" | grep -c -- '-7.1.2-35.sh$')"
assert_eq "the old override stays in place" "patch 31" "$(cat "$ROOT/debs/after-checkout-ubuntu2404-7.1.2-31.sh")"
assert_eq "the command reports the bump" "7.1.2-31 -> 7.1.2-35" "$OUT"

ROOT=$(new_root)
OUT=$("$BUMP" 7.1.2-31 "$ROOT")
assert_eq "the release version is kept when the version does not change" "3" "$(cat "$ROOT/release-version")"
assert_eq "nothing is copied when the version does not change" \
  "2" "$(ls "$ROOT/debs" | wc -l | tr -d ' ')"
assert_eq "the command prints nothing when the version does not change" "" "$OUT"

ROOT=$(new_root)
echo "hand-edited" > "$ROOT/debs/after-checkout-ubuntu2404-7.1.2-35.sh"
"$BUMP" 7.1.2-35 "$ROOT" > /dev/null
assert_eq "an existing override of the new version is not overwritten" \
  "hand-edited" "$(cat "$ROOT/debs/after-checkout-ubuntu2404-7.1.2-35.sh")"

if [ "$FAILURES" -gt 0 ]; then
  echo "$FAILURES test(s) failed"
  exit 1
fi
echo "All tests passed."
