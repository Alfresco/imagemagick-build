ARG BASE_IMAGE=rockylinux/rockylinux:9

FROM ${BASE_IMAGE}

RUN <<EOF
yum update -y
yum install -y epel-release
EOF

ADD *.rpm /

# Real HEIC file to decode in the test (a decode-only build can't create one).
COPY sample.heic /sample.heic

ARG BASE_IMAGE
ENV BASE_IMAGE=${BASE_IMAGE}

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
