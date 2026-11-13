#!/bin/bash -e
# Bumps imagemagick-version, resets release-version to 1 and copies the old
# version's after-checkout-*.sh overrides to the new name (entrypoints only look
# for an override named after the version they build). Prints "<old> -> <new>".

NEW="${1:?usage: bump-imagemagick.sh NEW_VERSION [REPO_ROOT]}"
ROOT="${2:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." &> /dev/null && pwd)}"

OLD=$(tr -d '[:space:]' < "$ROOT/imagemagick-version")
[ "$OLD" = "$NEW" ] && exit 0

printf '%s\n' "$NEW" >| "$ROOT/imagemagick-version"
printf '1\n' >| "$ROOT/release-version"

for override in "$ROOT"/debs/after-checkout-*-"$OLD".sh "$ROOT"/rpms/after-checkout-*-"$OLD".sh; do
  [ -f "$override" ] || continue
  target="${override%-"$OLD".sh}-$NEW.sh"
  [ -e "$target" ] || cp -p "$override" "$target"
done

echo "$OLD -> $NEW"
