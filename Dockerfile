# syntax=docker/dockerfile:1

FROM alpine:3.19

# set version label
ARG BUILD_DATE
ARG VERSION
ARG RADARR_RELEASE
LABEL build_version="Linuxserver.io armv7 fork version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="lggomez"

# environment settings
ARG RADARR_BRANCH="master"
ENV XDG_CONFIG_HOME="/config/xdg" 

RUN \
  echo "**** install packages ****" && \
  apk add -U --upgrade --no-cache \
    icu-libs \
    sqlite-libs \
    curl \
    jq \
    xmlstarlet && \
  echo "**** install radarr ****" && \
  mkdir -p /app/radarr/bin && \
  if [ -z ${RADARR_RELEASE+x} ]; then \
    RADARR_RELEASE=$(curl -sL "https://radarr.servarr.com/v1/update/${RADARR_BRANCH}/changes?runtime=netcore&os=linuxmusl" \
    | jq -r '.[0].version'); \
  fi && \
  curl -o \
    /tmp/radarr.tar.gz -L \
    "https://radarr.servarr.com/v1/update/${RADARR_BRANCH}/updatefile?version=${RADARR_RELEASE}&os=linuxmusl&runtime=netcore&arch=arm" && \
  tar xzf \
    /tmp/radarr.tar.gz -C \
    /app/radarr/bin --strip-components=1 && \
  echo -e "UpdateMethod=docker\nBranch=${RADARR_BRANCH}\nPackageVersion=${VERSION}\nPackageAuthor=[linuxserver.io](https://linuxserver.io)" > /app/radarr/package_info && \
  echo "**** cleanup ****" && \
  rm -rf \
    /app/radarr/bin/Radarr.Update \
    /tmp/*

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 7878

VOLUME /config

ENTRYPOINT ./app/radarr/bin/Radarr && bash
