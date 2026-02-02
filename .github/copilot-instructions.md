# Copilot Instructions for ImageMagick Build

## Repository Overview

This repository builds ImageMagick v7 deb/rpm packages for multiple Linux distributions:
- **RPM packages**: RockyLinux 8 and 9 (x86_64 and aarch64)
- **DEB packages**: Ubuntu 18.04, 20.04, 22.04, and 24.04 (x86_64 and aarch64)

The packages are required by Alfresco Content Services and are published to the Alfresco Nexus repository. The build process uses Docker containers and GitHub Actions workflows.

## Project Structure

### Root Files
- `imagemagick-version`: Contains the ImageMagick version to build (e.g., `7.1.2-6`)
- `release-version`: Contains the package release number (starts at `1` for each new ImageMagick version)
- `README.md`: Main documentation with release instructions
- `.github/workflows/build.yml`: Main CI/CD workflow that builds, tests, and deploys packages
- `.github/copilot-instructions.md`: This file (repository custom instructions)

### Directory Structure
- `debs/`: Contains Debian package build configuration
  - `Dockerfile`: Build environment for DEB packages
  - `entrypoint.sh`: Main build script for DEB packages
  - `config.json`: Matrix configuration for Ubuntu versions and architectures
  - `debian/`: Debian packaging control files (control, rules, changelog, etc.)
  - `after-checkout-*.sh`: Version and OS-specific override scripts
  - `tests/`: Test scripts and Dockerfile for package validation
- `rpms/`: Contains RPM package build configuration
  - `Dockerfile`: Build environment for RPM packages
  - `entrypoint.sh`: Main build script for RPM packages
  - `config.json`: Matrix configuration for RockyLinux versions and architectures
  - `tests/`: Test scripts and Dockerfile for package validation

## Build Process

### Building Packages (No Local Build Required)

**IMPORTANT**: This repository does NOT support local builds. All builds are performed in Docker containers via GitHub Actions workflows. Do not attempt to run build commands directly on the host system.

The build process is fully automated through GitHub Actions:
1. Workflow reads version from `imagemagick-version` and `release-version` files
2. Matrix jobs are generated from `debs/config.json` and `rpms/config.json`
3. For each combination of OS and architecture:
   - Docker build environment is created from the appropriate Dockerfile
   - `entrypoint.sh` script clones ImageMagick from GitHub at the specified version tag
   - Version-specific override scripts (e.g., `after-checkout-ubuntu2404-7.1.2-6.sh`) are executed if present
   - Packages are built using native package managers (`dpkg-buildpackage` for DEBs, `rpmbuild` for RPMs)
   - Built packages are uploaded as GitHub Actions artifacts

### Testing Process

After packages are built, automated tests run for each package:
1. Test Docker environment is created
2. Packages are installed in a clean container
3. Tests verify:
   - Package installation succeeds
   - `convert` command is available and works
   - Basic image conversion operations (PNG to JPG)
   - Library dependencies are correct (especially checking for unexpected ghostscript dependencies)

### Deployment Process

On tagged releases (tags matching `refs/tags/v*`):
- Packages are deployed to Alfresco Nexus repository
- Maven coordinates: `org.imagemagick:imagemagick-distribution`
- Version format: `{imagemagick-version}-ci-{release-version}`
- Different classifiers for each OS/arch combination (e.g., `ub2204-amd64`, `el9-aarch64`)

## Version Management Guidelines

### When updating the `imagemagick-version` file with a new version:

1. **Check for override scripts**: Remember that additional `debs/after-checkout-*.sh` override files may need to be created or updated for the new version.
   - These files follow the pattern: `after-checkout-{os}{version}-{imagemagick-version}.sh`
   - Examples: `after-checkout-ubuntu2404-7.1.2-6.sh`, `after-checkout-ubuntu2004-7.1.2-6.sh`
   - Override scripts modify package dependencies (e.g., changing `libtiff5` to `libtiff6` for Ubuntu 24.04)
   - Ensure compatibility with different Ubuntu versions (18.04, 20.04, 22.04, 24.04)

2. **Reset release version**: The `release-version` file needs to be reset to `1` when updating to a new ImageMagick version.

3. **Increment release version**: If the ImageMagick version remains the same, the `release-version` file needs to be increased (incremented by 1).

### Override Script Examples

Override scripts patch package control files for OS-specific compatibility:
- Ubuntu 24.04: Changes `libtiff5` to `libtiff6`, `mime-support` to `mailcap,media-types`, removes `libraw-dev`
- RockyLinux: Removes BuildRequires for lqr, raqm, ghostscript-devel, and LibRaw from `ImageMagick.spec.in`

## CI/CD Workflow

The `.github/workflows/build.yml` workflow:
- **Triggers**: Pushes to the repository (excluding changes to README.md, copilot-instructions.md, and dependabot.yml)
- **Concurrency**: Cancels in-progress runs for the same branch
- **Jobs**:
  1. `configure`: Reads matrix configuration from JSON files
  2. `build_rpms` / `build_deb`: Builds packages for each OS/arch combination
  3. `test_rpms` / `test_deb`: Tests installed packages
  4. `deploy_rpms` / `deploy_deb`: Deploys to Nexus (only on tagged releases)
- **Runners**: Uses `ubuntu-24.04-arm` for aarch64 builds, `ubuntu-latest` for x86_64 builds

## Release Process

To release a new version:
1. Create a PR that updates `imagemagick-version` and `release-version` files
2. Ensure any necessary `after-checkout-*.sh` scripts are created/updated
3. Once merged, create and push a signed tag: `git tag -s vN.N.N -m vN.N.N && git push --tags origin vN.N.N`
4. Draft a GitHub release using the tag and generate release notes
5. The workflow will automatically build and deploy packages to Nexus

## Key Dependencies

- Docker (for containerized builds)
- GitHub Actions (for CI/CD)
- ImageMagick source code (cloned from https://github.com/ImageMagick/ImageMagick.git)
- Build tools:
  - DEB: `dpkg-buildpackage`, `mk-build-deps`
  - RPM: `rpmbuild`, `yum-builddep`
- Test tools: `convert` command from ImageMagick

## Important Notes

- The workflow intentionally excludes certain dependencies from RPM builds (LQR, Raqm, ghostscript, LibRaw) to avoid compatibility issues
- Tests specifically check that packages do NOT depend on ghostscript (`libgs`)
- Packages are installed to custom paths:
  - DEB: `/opt/imagemagick-7/`
  - RPM: Standard system paths (`/usr/bin/`)
- arm64 (aarch64) builds run on dedicated ARM runners for native compilation