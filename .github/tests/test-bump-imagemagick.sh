#!/bin/bash -e
# Tests for bump-imagemagick.sh in a throwaway copy of the repo layout.
#
#   ./.github/tests/test-bump-imagemagick.sh
set -o pipefail

BASE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
BUMP="$BASE_DIR/../scripts/bump-imagemagick.sh"
WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT
FAILURES=0

assert_ok() {
  local desc="$1"
  shift
  if "$@"; then
    echo "ok - $desc"
  else
    echo "FAIL - $desc"
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
assert_ok "the version file holds the new version" test "$(cat "$ROOT/imagemagick-version")" = "7.1.2-35"
assert_ok "the release version resets to 1" test "$(cat "$ROOT/release-version")" = "1"
assert_ok "a deb override of the old version is copied for the new one" \
  test "$(cat "$ROOT/debs/after-checkout-ubuntu2404-7.1.2-35.sh")" = "patch 31"
assert_ok "an rpm override of the old version is copied for the new one" \
  test "$(cat "$ROOT/rpms/after-checkout-rockylinux8-7.1.2-35.sh")" = "rpm patch 31"
assert_ok "only the override of the old version is carried over, not those of older ones" \
  test "$(ls "$ROOT/debs" | grep -c -- '-7.1.2-35.sh$')" = "1"
assert_ok "the old override stays in place" test -f "$ROOT/debs/after-checkout-ubuntu2404-7.1.2-31.sh"
assert_ok "the command reports the bump" test "$OUT" = "7.1.2-31 -> 7.1.2-35"

ROOT=$(new_root)
OUT=$("$BUMP" 7.1.2-31 "$ROOT")
assert_ok "the release version is kept when the version does not change" test "$(cat "$ROOT/release-version")" = "3"
assert_ok "nothing is copied when the version does not change" \
  test "$(ls "$ROOT/debs" | wc -l | tr -d ' ')" = "2"
assert_ok "the command prints nothing when the version does not change" test -z "$OUT"

ROOT=$(new_root)
echo "hand-edited" > "$ROOT/debs/after-checkout-ubuntu2404-7.1.2-35.sh"
"$BUMP" 7.1.2-35 "$ROOT" > /dev/null
assert_ok "an existing override of the new version is not overwritten" \
  test "$(cat "$ROOT/debs/after-checkout-ubuntu2404-7.1.2-35.sh")" = "hand-edited"

if [ "$FAILURES" -gt 0 ]; then
  echo "$FAILURES test(s) failed"
  exit 1
fi
echo "All tests passed."
