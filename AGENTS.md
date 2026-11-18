# AGENTS.md

This file provides guidance to AI coding agents (Claude Code, GitHub Copilot, etc.) when working with code in this repository.

## Repository purpose

This repo builds ImageMagick v7 `.deb`/`.rpm` packages required by Alfresco Content Services, for:

- RockyLinux 9 and 8 (x86_64 and aarch64) → RPMs
- Ubuntu 24.04 and 22.04 (x86_64 and aarch64) → DEBs

Packages are published to Alfresco's Nexus (`org.imagemagick:imagemagick-distribution`).

## No local builds

**This repo does not support local builds.** All building/testing happens in Docker containers driven by `.github/workflows/build.yml`. Don't attempt to run `dpkg-buildpackage`, `rpmbuild`, etc. directly on the host — reproduce a build/test by running the same `docker build`/`docker run` steps the workflow uses (see below), not by inventing a native flow.

## Architecture

Two parallel, near-identical build pipelines, one per packaging format:

- `debs/` — Debian packaging. `Dockerfile` builds a container with `dpkg-dev`/`devscripts`/`equivs`; `entrypoint.sh` clones ImageMagick at the tag from `imagemagick-version`, copies in `debs/debian/*` control files, runs an optional `after-checkout-*.sh` hook, then `mk-build-deps -Bi && dpkg-buildpackage -b -uc`.
- `rpms/` — RPM packaging. `Dockerfile` builds a container with `rpm-build`/`yum-utils` (plus RPM Fusion repos on EL8 for `libheif`); `entrypoint.sh` clones ImageMagick, strips `BuildRequires`/configure flags for LQR, Raqm, ghostscript (`gslib`), and LibRaw and the `.tar.xz.asc` signature `Source` from `ImageMagick.spec.in`, runs an optional `after-checkout-*.sh` hook, builds an `.src.rpm` via `./configure && make dist-xz && make srpm`, then `yum-builddep` + `rpmbuild --rebuild`. It also asserts the built `ImageMagick-libs` RPM has no `libgs` (ghostscript) dependency before handing off to the test entrypoint.

Each pipeline has its own `tests/` subdirectory (`Dockerfile` + `entrypoint.sh`) that installs the built package into a clean container and verifies `convert` works (PNG→JPG) and dependencies are sane.

Each format's `config.json` (`{base_image, target_arch, nexus_classifier}` list) is the build matrix consumed by `.github/workflows/build.yml`'s `configure` job — add a new OS/arch combination there.

### OS-specific hooks

`{debs,rpms}/after-checkout-{os}.sh` patch the packaging for one OS, whatever the ImageMagick version. `{os}` is the base image name without its registry path, `:` or `.` (`ubuntu2404`, `rockylinux8`). `debs/after-checkout-ubuntu2404.sh` patches `debian/control` for package names that differ on Ubuntu 24.04 (`libtiff5`→`libtiff6`, dropping `libraw-dev`, swapping `mime-support` for `mailcap,media-types`). When a patch applies to one ImageMagick version only, put it in `after-checkout-{os}-{imagemagick-version}.sh`; it runs after the OS-wide hook. On the RPM side, add a hook only if an OS needs more than the common LQR/Raqm/ghostscript/LibRaw strip already in `rpms/entrypoint.sh`. All hooks are optional. The entrypoints run them with `bash -e` when the file exists, so the exec bit doesn't matter.

## Release process

1. Updatecli opens a PR for each new ImageMagick 7 release (see "Automated bumps" below). Otherwise, raise a PR by hand bumping [`imagemagick-version`](imagemagick-version) (adjusting the `after-checkout-*.sh` hooks if the new version needs it) and [`release-version`](release-version) — reset `release-version` to `1` when `imagemagick-version` changes, otherwise increment it.
2. Once merged, tag: `git tag -s vN.N.N -m vN.N.N && git push --tags origin vN.N.N`.
3. Draft a [new release](https://github.com/Alfresco/imagemagick-build/releases/new) from that tag using "Generate release notes".
4. The tag push triggers `deploy_rpms`/`deploy_deb` in the workflow (gated on `refs/tags/v*`), publishing to Nexus with version `{imagemagick-version}-ci-{release-version}`.

## CI workflow (`.github/workflows/build.yml`)

Triggered on push (except changes to README.md, AGENTS.md, CLAUDE.md, .github/dependabot.yml, or the updatecli files: `updatecli.d/`, `.github/scripts/`, `.github/tests/`, `.github/workflows/updatecli.yml`). Per format: `configure` (reads `config.json`) → `build_{rpms,deb}` (matrix, ARM jobs run on `ubuntu-24.04-arm`, x86_64 on `ubuntu-latest`) → `test_{rpms,deb}` → `deploy_{rpms,deb}` (tag-gated, `max-parallel: 1`). GitHub Actions are SHA-pinned.

## Automated bumps

- `.github/workflows/updatecli.yml` runs [`updatecli.d/imagemagick.yml`](updatecli.d/imagemagick.yml) every Monday. It opens a PR, ready for review, titled with the target version and with review requested from `Alfresco/ops-readiness-performance`, when ImageMagick publishes a newer 7.x tag. `.github/scripts/bump-imagemagick.sh` does the file changes: it writes `imagemagick-version`, resets `release-version` to `1`, and copies the `after-checkout-*-{old version}.sh` overrides to the new version name (the entrypoints only look for an override named after the version they build). CI on that PR shows whether the copied overrides still apply.
- The `advisories` job of the same workflow runs on any PR that changes `imagemagick-version`. It posts one comment listing the ImageMagick security advisories fixed between the old and new version, and adds the `security` label when there are any. On PRs from forks the token is read-only, so it writes the report to the job summary instead. The comment opens with a per-severity count (`.github/scripts/advisory-summary.jq`) followed by the advisories, most severe first (`.github/scripts/fixed-advisories.jq`). Both share the matching logic in `.github/scripts/advisories.jq`.
- Both scripts have tests in `.github/tests/`, run by the `test_scripts` job of `updatecli.yml` on PRs.

## Packaging install paths

- DEB packages install to `/opt/imagemagick-7/` (custom prefix, avoids clobbering distro ImageMagick).
- RPM packages install to standard system paths (`/usr/bin/`, etc.).
