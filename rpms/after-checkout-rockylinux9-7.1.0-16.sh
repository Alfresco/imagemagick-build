#!/bin/bash -e
# Drop LibRaw support which is not compatible with the current version of ImageMagick
sed -i '/BuildRequires.*LibRaw/d; /--with-raw/d' ImageMagick.spec.in
