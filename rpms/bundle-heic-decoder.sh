#!/bin/bash
set -e -o pipefail -x

# Bundle the HEVC decoder (libheif + libde265) into the ImageMagick-heic RPM
# on el9 so HEIC images decode without any extra repos on the consumer
# (decode-only: the GPL x265 encoder is omitted).
#
# El8's libheif is only available via RPM Fusion and links libde265 (and the
# GPL x265 encoder) directly into libheif.so, so bundling it would still force
# consumers onto RPM Fusion just to satisfy that dependency. HEIC support is
# dropped there entirely instead.
#
# Run from the ImageMagick source directory (patches ImageMagick.spec.in).

source /etc/os-release
if [[ "$VERSION_ID" != 9* ]]; then
    sed -i 's/%bcond_without libheif/%bcond_with libheif/' ImageMagick.spec.in
    exit 0
fi

cat > /tmp/heic-install.txt <<'EOF'
cp -aP %{_libdir}/libheif.so.1* %{buildroot}%{_libdir}/
cp -aP %{_libdir}/libde265.so.0* %{buildroot}%{_libdir}/
install -d %{buildroot}%{_libdir}/libheif
cp -aP %{_libdir}/libheif/libheif-libde265.so %{buildroot}%{_libdir}/libheif/
EOF
cat > /tmp/heic-files.txt <<'EOF'
%{_libdir}/libheif.so.1*
%{_libdir}/libde265.so.0*
%dir %{_libdir}/libheif
%{_libdir}/libheif/libheif-libde265.so
EOF

# Avoid duplicate build-id link errors when packaging prebuilt libraries.
sed -i '1i %global _build_id_links none' ImageMagick.spec.in
# Copy the runtime libraries into the buildroot at the end of %install ...
sed -i '\#multilibFileVersions .*MagickCore/version.h#r /tmp/heic-install.txt' ImageMagick.spec.in
# ... and let ImageMagick-heic own them (inside its %if %{with libheif} block).
sed -i '\#modules-Q16HDRI/coders/heic\.\*#r /tmp/heic-files.txt' ImageMagick.spec.in
