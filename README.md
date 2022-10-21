# imagemagick-build

This repo is building ImageMagick v7 packages for [RockyLinux8](https://github.com/Alfresco/imagemagick-build/tree/main/.github/actions/rockylinux-build), [Centos7](https://github.com/Alfresco/imagemagick-build/tree/main/.github/actions/centos-build), [Ubuntu-18.04](https://github.com/Alfresco/imagemagick-build/tree/main/.github/actions/Ubuntu18.04-build), [Ubuntu20.04](https://github.com/Alfresco/imagemagick-build/tree/main/.github/actions/Ubuntu20.04-build) & [Ubuntu22.04](https://github.com/Alfresco/imagemagick-build/tree/main/.github/actions/Ubuntu22.04-build)that are
not available elsewhere and that are required by
[Alfresco](https://docs.alfresco.com/content-services/latest/support/) to work properly.

Notes:- 

* ImageMagick v7 for [Centos7](https://github.com/Alfresco/imagemagick-build/tree/main/.github/actions/centos-build) & [Rockylinux8] (https://github.com/Alfresco/imagemagick-build/tree/main/.github/actions/rockylinux-build) are the generic packages which can be used for Redhat7 & Redhat8 respectively.
* We are building the rpm packages with ghostscript,gslibs & gsfonts wheras same has been disabled in the deb packges.

Packages are published under [Releases](https://github.com/Alfresco/imagemagick-build/releases) section and on our [Nexus](https://nexus.alfresco.com/nexus/service/local/repositories/thirdparty/content/org/imagemagick/imagemagick-distribution/) instance.

## Release a new version

* Bump ImageMagick version in [imagemagick-version](https://github.com/Alfresco/imagemagick-build/blob/main/.github/actions/imagemagick-version)
* Tag the commit via `git tag -s v7.1.0-16 -m v7.1.0-16`
* Push it `git push --tags origin v7.1.0-16`