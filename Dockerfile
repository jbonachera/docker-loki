# syntax=docker/dockerfile:1
#FROM ubuntu:bionic
FROM --platform=$TARGETPLATFORM ubuntu:bionic
ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG TARGETARCH
ARG GEOIP_ACCOUNTID
ARG GEOIP_LICENSE
ENTRYPOINT ["/usr/bin/supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf"]
RUN apt-get update &&  apt-get install -y gnupg2 curl ca-certificates apt-transport-https
RUN curl -1sLf 'https://repositories.timber.io/public/vector/cfg/setup/bash.deb.sh' | bash
RUN curl -sL https://packages.grafana.com/gpg.key | apt-key add -
RUN echo "deb https://packages.grafana.com/oss/deb stable main" | tee /etc/apt/sources.list.d/grafana.list
RUN apt-get update && apt-get install -y supervisor unzip grafana vector && rm -rf /var/cache/apt
ENV LOKI_VERSION="v2.6.1"
ENV CPU_ARCH="${TARGETARCH}"
#ENV CPU_ARCH="amd64"
ENV LOKI_DOWNLOAD_URL="https://github.com/grafana/loki/releases/download/${LOKI_VERSION}/loki-linux-${CPU_ARCH}.zip"
RUN curl -o loki.zip -sL ${LOKI_DOWNLOAD_URL} && \
    unzip loki.zip && \
    rm -f loki.zip && \
    mv loki-linux-${CPU_ARCH} /usr/local/bin/loki
COPY supervisord.conf /etc/supervisord.conf
COPY loki-config.yaml /etc/loki.yaml
COPY vector.toml /etc/vector/vector.toml
