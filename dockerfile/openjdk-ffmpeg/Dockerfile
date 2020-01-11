# https://github.com/alfg/docker-ffmpeg/blob/master/Dockerfile

FROM javachen/openjdk:8u201-jdk-alpine

RUN apk add --no-cache \
  build-base \
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
  ffmpeg


CMD ["/usr/bin/ffmpeg"]  