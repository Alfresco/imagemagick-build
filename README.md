# imagemagick-build

This repo is building ImageMagick v7.1 RPM packages for Rocky Linux 8 that are
not available elsewhere and that are required by
[Alfresco](https://docs.alfresco.com/content-services/latest/support/) to work properly.

Packages are published under [Releases](https://github.com/Alfresco/imagemagick-build/releases) section.

## Release a new version

* Bump ImageMagick env var version in [Dockerfile](https://github.com/Alfresco/imagemagick-build/blob/main/.github/actions/rockylinux-build/Dockerfile#L3)
* Tag the commit via `git tag -s v7.1.0-16 -m v7.1.0-16`
* Push it `git push --tags origin v7.1.0-16`
