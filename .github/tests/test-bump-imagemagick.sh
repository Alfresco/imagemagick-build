#!/bin/bash -e
# Tests for bump-imagemagick.sh in a throwaway copy of the repo layout.
set -o pipefail

BASE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
BUMP="$BASE_DIR/../scripts/bump-imagemagick.sh"
WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT
# shellcheck source=SCRIPTDIR/lib.sh
source "$BASE_DIR/lib.sh"

new_root() {
  local root
  root=$(mktemp -d -p "$WORK_DIR")
  mkdir -p "$root/debs" "$root/rpms"
  printf '7.1.2-31\n' > "$root/imagemagick-version"
  printf '3\n' > "$root/release-version"
  echo "os patch" > "$root/debs/after-checkout-ubuntu2404.sh"
  echo "version patch" > "$root/debs/after-checkout-ubuntu2404-7.1.2-31.sh"
  echo "$root"
}

ROOT=$(new_root)
OUT=$("$BUMP" 7.1.2-35 "$ROOT")
assert_eq "the version file holds the new version" "7.1.2-35" "$(cat "$ROOT/imagemagick-version")"
assert_eq "the release version resets to 1" "1" "$(cat "$ROOT/release-version")"
assert_eq "the bump leaves the hooks alone" \
  "after-checkout-ubuntu2404-7.1.2-31.sh after-checkout-ubuntu2404.sh " "$(ls "$ROOT/debs" | tr '\n' ' ')"
assert_eq "the command reports the bump" "7.1.2-31 -> 7.1.2-35" "$OUT"

ROOT=$(new_root)
OUT=$("$BUMP" 7.1.2-31 "$ROOT")
assert_eq "the release version is kept when the version does not change" "3" "$(cat "$ROOT/release-version")"
assert_eq "the command prints nothing when the version does not change" "" "$OUT"

finish
