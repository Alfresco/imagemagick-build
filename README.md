# imagemagick-build

This repo is building ImageMagick v7 deb/rpm packages for multiple distributions:

* Centos 7 (x86_64 only)
* RockyLinux 9 (x86_64 and aarch64)
* RockyLinux 8 (x86_64 and aarch64)
* Ubuntu 22.04 (x86_64 only)
* Ubuntu 20.04 (x86_64 only)
* Ubuntu 18.04 (x86_64 only)

that are required by
[Alfresco](https://docs.alfresco.com/content-services/latest/support/) to work
properly.

Notes:

ImageMagick packages built on Centos 7 and RockyLinux 8 are tested also on
Redhat7 and Redhat8 on the [Alfresco Ansible
playbook](https://github.com/Alfresco/alfresco-ansible-deployment).

Packages are published under our
[Nexus](https://nexus.alfresco.com/nexus/#nexus-search;quick~imagemagick-distribution)
instance.

## Release a new version

Raise a PR to:

* Bump the ImageMagick version you want to build in [imagemagick-version
  file](imagemagick-version)
* Bump the version of the package in [release-version file](release-version)
  (restart from 1 when increasing imagemagick version)

Once merged, trigger the release workflow:

* Create a new tag `git tag -s vN.N.N -m vN.N.N` following semantic versioning
* Push it `git push --tags origin vN.N.N`
* Draft a [new
  release](https://github.com/Alfresco/imagemagick-build/releases/new) using the
  previous tag as source and use the `Generate release notes` function to
  generate the changelog.
