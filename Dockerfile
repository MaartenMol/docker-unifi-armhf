FROM arm32v7/debian:stretch-slim AS builder
COPY qemu-arm-static /usr/bin
ENTRYPOINT ["sh","/run.sh"]

FROM lsiobase/ubuntu.armhf:xenial

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Unifi SDN Controller version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="Maarten Mol"

# package versions
ARG UNIFI_VER="5.12.35"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"

RUN \
 echo "**** install packages ****" && \
 apt-get update && \
 apt-get install -y \
	binutils \
	jsvc \
	mongodb-server \
	openjdk-8-jre-headless \
	wget && \
 echo "**** install unifi ****" && \
 curl -o \
 /tmp/unifi.deb -L \
	"http://dl.ubnt.com/unifi/${UNIFI_VER}/unifi_sysvinit_all.deb" && \
 dpkg -i /tmp/unifi.deb && \
 echo "**** cleanup ****" && \
 apt-get clean && \
 rm -rf \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

# add local files
COPY root/ /

# Volumes and Ports
WORKDIR /usr/lib/unifi
VOLUME /config
EXPOSE 8080 8081 8443 8843 8880
