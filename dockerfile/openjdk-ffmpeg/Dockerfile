FROM javachen/openjdk:8u201-jdk-alpine

RUN apk update \
  && apk add --no-cache nasm zlib-dev yasm-dev lame-dev libogg-dev x264-dev \
  	libvpx-dev libvorbis-dev freetype-dev libass-dev libwebp-dev rtmpdump-dev libtheora-dev opus-dev ffmpeg \
  && apk del nasm