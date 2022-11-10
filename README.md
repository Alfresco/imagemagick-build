# imagemagick-build

This repo is building ImageMagick v7 packages for [RockyLinux8](https://github.com/Alfresco/imagemagick-build/tree/main/.github/actions/rockylinux-build), [Centos7](https://github.com/Alfresco/imagemagick-build/tree/main/.github/actions/centos-build), [Ubuntu-18.04](https://github.com/Alfresco/imagemagick-build/tree/main/.github/actions/Ubuntu18.04-build), [Ubuntu20.04](https://github.com/Alfresco/imagemagick-build/tree/main/.github/actions/Ubuntu20.04-build) & [Ubuntu22.04](https://github.com/Alfresco/imagemagick-build/tree/main/.github/actions/Ubuntu22.04-build) that are
not available elsewhere and that are required by
[Alfresco](https://docs.alfresco.com/content-services/latest/support/) to work properly.

Notes:- 

* ImageMagick v7 for [Centos7](https://github.com/Alfresco/imagemagick-build/tree/main/.github/actions/centos-build) & [Rockylinux8](https://github.com/Alfresco/imagemagick-build/tree/main/.github/actions/rockylinux-build) are the generic packages which can be used for Redhat7 & Redhat8 respectively.

Packages are published under [Releases](https://github.com/Alfresco/imagemagick-build/releases) section and on our [Nexus](https://nexus.alfresco.com/nexus/service/local/repositories/thirdparty/content/org/imagemagick/imagemagick-distribution/) instance.

## Release a new version

* Bump ImageMagick env var version in [imagemagick-version file](https://github.com/Alfresco/imagemagick-build/blob/main/.github/actions/imagemagick-version) via PR
* Create a new tag `git tag -s vN.N.N -m vN.N.N` following semantic versioning
* Push it `git push --tags origin vN.N.N`
* Draft a [new release](https://github.com/Alfresco/imagemagick-build/releases/new) using the previous tag as source and use the `Generate release notes` function to generate the changelog.