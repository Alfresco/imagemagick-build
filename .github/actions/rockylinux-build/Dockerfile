FROM rockylinux:8
ENV RPM_CAP=rpm_capabilities
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
