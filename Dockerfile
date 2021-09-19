# syntax=docker/dockerfile:1
FROM --platform=$BUILDPLATFORM alpine
ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG TARGETARCH
ENTRYPOINT ["/usr/bin/supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf"]
RUN apk --no-cache add curl supervisor unzip libc6-compat grafana syslog-ng
ENV LOKI_VERSION="v2.3.0"
ENV CPU_ARCH="${TARGETARCH}"
ENV LOKI_DOWNLOAD_URL="https://github.com/grafana/loki/releases/download/${LOKI_VERSION}/loki-linux-${CPU_ARCH}.zip"
ENV PROMTAIL_DOWNLOAD_URL="https://github.com/grafana/loki/releases/download/${LOKI_VERSION}/promtail-linux-${CPU_ARCH}.zip"
ENV LOGCLI_DOWNLOAD_URL="https://github.com/grafana/loki/releases/download/${LOKI_VERSION}/logcli-linux-${CPU_ARCH}.zip"
RUN curl -o loki.zip -sL ${LOKI_DOWNLOAD_URL} && \
    unzip loki.zip && \
    rm -f loki.zip && \
    mv loki-linux-${CPU_ARCH} /usr/local/bin/loki
RUN curl -o promtail.zip -sL ${PROMTAIL_DOWNLOAD_URL} && \
    unzip promtail.zip && \
    rm -f promtail.zip && \
    mv promtail-linux-${CPU_ARCH} /usr/local/bin/promtail
RUN curl -o logcli.zip -sL ${LOGCLI_DOWNLOAD_URL} && \
    unzip logcli.zip && \
    rm -f logcli.zip && \
    mv logcli-linux-${CPU_ARCH} /usr/local/bin/logcli
COPY syslog-ng.conf /etc/syslog-ng/conf.d/loki.conf
COPY supervisord.conf /etc/supervisor.d/config.ini
COPY loki-config.yaml /etc/loki.yaml
COPY promtail-config.yaml /etc/promtail.yaml
