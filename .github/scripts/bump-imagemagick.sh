#!/bin/bash -e
# Bumps imagemagick-version and resets release-version to 1. Prints "<old> -> <new>".

NEW="${1:?usage: bump-imagemagick.sh NEW_VERSION [REPO_ROOT]}"
ROOT="${2:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." &> /dev/null && pwd)}"

OLD=$(tr -d '[:space:]' < "$ROOT/imagemagick-version")
[ "$OLD" = "$NEW" ] && exit 0

printf '%s\n' "$NEW" >| "$ROOT/imagemagick-version"
printf '1\n' >| "$ROOT/release-version"

echo "$OLD -> $NEW"
