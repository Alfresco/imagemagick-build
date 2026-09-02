#!/bin/bash
set -e -o pipefail -x

# Bundle the HEVC decoder (libheif + libde265) into the ImageMagick-heic RPM so
# HEIC images decode without any extra repos on the consumer. Decode-only: the
# GPL x265 encoder is omitted. el9 uses libheif's plugin model (bundle the
# libde265 plugin too); el8's older libheif links libde265 directly.
#
# Run from the ImageMagick source directory (patches ImageMagick.spec.in).

source /etc/os-release
if [[ "$VERSION_ID" != 8* && "$VERSION_ID" != 9* ]]; then
    exit 0
fi

cat > /tmp/heic-install.txt <<'EOF'
cp -aP %{_libdir}/libheif.so.1* %{buildroot}%{_libdir}/
cp -aP %{_libdir}/libde265.so.0* %{buildroot}%{_libdir}/
EOF
cat > /tmp/heic-files.txt <<'EOF'
%{_libdir}/libheif.so.1*
%{_libdir}/libde265.so.0*
EOF
if [[ "$VERSION_ID" == 9* ]]; then
    cat >> /tmp/heic-install.txt <<'EOF'
install -d %{buildroot}%{_libdir}/libheif
cp -aP %{_libdir}/libheif/libheif-libde265.so %{buildroot}%{_libdir}/libheif/
EOF
    cat >> /tmp/heic-files.txt <<'EOF'
%dir %{_libdir}/libheif
%{_libdir}/libheif/libheif-libde265.so
EOF
fi

# Avoid duplicate build-id link errors when packaging prebuilt libraries.
sed -i '1i %global _build_id_links none' ImageMagick.spec.in
# Copy the runtime libraries into the buildroot at the end of %install ...
sed -i '\#multilibFileVersions .*MagickCore/version.h#r /tmp/heic-install.txt' ImageMagick.spec.in
# ... and let ImageMagick-heic own them (inside its %if %{with libheif} block).
sed -i '\#modules-Q16HDRI/coders/heic\.\*#r /tmp/heic-files.txt' ImageMagick.spec.in
