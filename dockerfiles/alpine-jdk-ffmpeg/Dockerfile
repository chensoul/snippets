# https://github.com/alfg/docker-ffmpeg/blob/master/Dockerfile

FROM javachen/alpine-jdk:8

# User root user to install software
USER root

RUN set -euxo pipefail \
  && apk add --no-cache --virtual BUILD build-base \
  && apk add --no-cache \
  freetype-dev \
  gcc \
  lame-dev \
  libogg-dev \
  libass \
  libass-dev \
  libvpx-dev \
  libvorbis-dev \
  libwebp-dev \
  libtheora-dev \
  opus-dev \
  pkgconf \
  pkgconfig \
  rtmpdump-dev \
  x264-dev \
  x265-dev \
  yasm \
  ffmpeg \
  && apk del BUILD

USER java 

CMD ["/usr/bin/ffmpeg"]  
