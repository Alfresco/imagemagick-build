# AGENTS.md

This file provides guidance to AI coding agents (Claude Code, GitHub Copilot, etc.) when working with code in this repository.

## Repository purpose

This repo builds ImageMagick v7 `.deb`/`.rpm` packages required by Alfresco Content Services, for:

- RockyLinux 9 and 8 (x86_64 and aarch64) → RPMs
- Ubuntu 24.04, 22.04, 20.04 (x86_64 and aarch64) → DEBs

Packages are published to Alfresco's Nexus (`org.imagemagick:imagemagick-distribution`).

## No local builds

**This repo does not support local builds.** All building/testing happens in Docker containers driven by `.github/workflows/build.yml`. Don't attempt to run `dpkg-buildpackage`, `rpmbuild`, etc. directly on the host — reproduce a build/test by running the same `docker build`/`docker run` steps the workflow uses (see below), not by inventing a native flow.

## Architecture

Two parallel, near-identical build pipelines, one per packaging format:

- `debs/` — Debian packaging. `Dockerfile` builds a container with `dpkg-dev`/`devscripts`/`equivs`; `entrypoint.sh` clones ImageMagick at the tag from `imagemagick-version`, copies in `debs/debian/*` control files, runs an optional `after-checkout-*.sh` hook, then `mk-build-deps -Bi && dpkg-buildpackage -b -uc`.
- `rpms/` — RPM packaging. `Dockerfile` builds a container with `rpm-build`/`yum-utils` (plus RPM Fusion repos on EL8 for `libheif`); `entrypoint.sh` clones ImageMagick, strips `BuildRequires`/configure flags for LQR, Raqm, ghostscript (`gslib`), and LibRaw from `ImageMagick.spec.in`, runs an optional `after-checkout-*.sh` hook, builds an `.src.rpm` via `./configure && make dist-xz && make srpm`, then `yum-builddep` + `rpmbuild --rebuild`. It also asserts the built `ImageMagick-libs` RPM has no `libgs` (ghostscript) dependency before handing off to the test entrypoint.

Each pipeline has its own `tests/` subdirectory (`Dockerfile` + `entrypoint.sh`) that installs the built package into a clean container and verifies `convert` works (PNG→JPG) and dependencies are sane.

Each format's `config.json` (`{base_image, target_arch, nexus_classifier}` list) is the build matrix consumed by `.github/workflows/build.yml`'s `configure` job — add a new OS/arch combination there.

### Version-specific overrides

`debs/after-checkout-{os}{ver}-{imagemagick-version}.sh` (e.g. `after-checkout-ubuntu2404-7.1.2-13.sh`) patch `debian/control`/`debian/rules` for OS-specific package name differences (e.g. `libtiff5`→`libtiff6` on Ubuntu 24.04, dropping `libraw-dev`, swapping `mime-support` for `mailcap,media-types`). RPM side uses the same naming convention (`after-checkout-{base_image sans colons}-{imagemagick-version}.sh`) if an OS needs a patch beyond the common LQR/Raqm/ghostscript/LibRaw strip already in `rpms/entrypoint.sh`. These scripts are optional — the entrypoints only run them `if [ -x ... ]`.

## Release process

1. Raise a PR bumping [`imagemagick-version`](imagemagick-version) (and creating/updating any needed `after-checkout-*.sh` overrides for the new version) and [`release-version`](release-version) — reset `release-version` to `1` when `imagemagick-version` changes, otherwise increment it.
2. Once merged, tag: `git tag -s vN.N.N -m vN.N.N && git push --tags origin vN.N.N`.
3. Draft a [new release](https://github.com/Alfresco/imagemagick-build/releases/new) from that tag using "Generate release notes".
4. The tag push triggers `deploy_rpms`/`deploy_deb` in the workflow (gated on `refs/tags/v*`), publishing to Nexus with version `{imagemagick-version}-ci-{release-version}`.

## CI workflow (`.github/workflows/build.yml`)

Triggered on push (except changes to README/copilot-instructions/dependabot). Per format: `configure` (reads `config.json`) → `build_{rpms,deb}` (matrix, ARM jobs run on `ubuntu-24.04-arm`, x86_64 on `ubuntu-latest`) → `test_{rpms,deb}` → `deploy_{rpms,deb}` (tag-gated, `max-parallel: 1`). GitHub Actions are SHA-pinned.

## Packaging install paths

- DEB packages install to `/opt/imagemagick-7/` (custom prefix, avoids clobbering distro ImageMagick).
- RPM packages install to standard system paths (`/usr/bin/`, etc.).
