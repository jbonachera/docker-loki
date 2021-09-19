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
RUN curl -sL https://packages.grafana.com/gpg.key | apt-key add -
RUN curl -sL https://packages.fluentbit.io/fluentbit.key | apt-key add -
RUN echo "deb https://packages.grafana.com/oss/deb stable main" | tee /etc/apt/sources.list.d/grafana.list
RUN echo "deb https://packages.fluentbit.io/ubuntu/bionic bionic main" | tee /etc/apt/sources.list.d/fluent.list
RUN apt-get update && apt-get install -y supervisor unzip grafana td-agent-bit geoipupdate && rm -rf /var/cache/apt
ENV LOKI_VERSION="v2.3.0"
ENV CPU_ARCH="${TARGETARCH}"
#ENV CPU_ARCH="amd64"
ENV LOKI_DOWNLOAD_URL="https://github.com/grafana/loki/releases/download/${LOKI_VERSION}/loki-linux-${CPU_ARCH}.zip"
RUN curl -o loki.zip -sL ${LOKI_DOWNLOAD_URL} && \
    unzip loki.zip && \
    rm -f loki.zip && \
    mv loki-linux-${CPU_ARCH} /usr/local/bin/loki
RUN echo "UserId ${GEOIP_ACCOUNTID}\nLicenseKey ${GEOIP_LICENSE}\nProductIds GeoLite2-City" > /etc/GeoIP.conf && geoipupdate && cp /var/lib/GeoIP/GeoLite2-City.mmdb /etc/td-agent-bit/
COPY parse_timestamp.lua /etc/td-agent-bit/parse_timestamp.lua
COPY supervisord.conf /etc/supervisord.conf
COPY loki-config.yaml /etc/loki.yaml
COPY td-agent-bit.conf /etc/td-agent-bit/td-agent-bit.conf
COPY iptables-parser /opt/iptables-parser
RUN cat /opt/iptables-parser >> /etc/td-agent-bit/parsers.conf
