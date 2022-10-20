# imagemagick-build

This repo is building ImageMagick v7 packages for Rocky Linux 8, Centos7, Ubuntu-18.04 & Ubuntu20.04  that are
not available elsewhere and that are required by
[Alfresco](https://docs.alfresco.com/content-services/latest/support/) to work properly.

Notes:- 

* ImageMagick v7 for Centos7 & Rockylinux 8 are the generic packages which can be used for Redhat7 & Redhat8 respectively.
* Ghostscript,gslibs & gsfonts are disabled in all the deb packages during the build whereas rpm packages conatins them due to there dependencies.

Packages are published under [Releases](https://github.com/Alfresco/imagemagick-build/releases) section and on our [Nexus](https://nexus.alfresco.com/nexus/service/local/repositories/thirdparty/content/org/imagemagick/imagemagick-distribution/) instance.

## Release a new version

* Bump ImageMagick env var version in [imagemagick-version](https://github.com/Alfresco/imagemagick-build/blob/main/.github/actions/imagemagick-version)
* Tag the commit via `git tag -s v7.1.0-16 -m v7.1.0-16`
* Push it `git push --tags origin v7.1.0-16`