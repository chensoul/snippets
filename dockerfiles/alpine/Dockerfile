FROM alpine

ENV LANG=C.UTF-8

RUN set -euxo pipefail \
    && echo 'https://mirrors.cloud.tencent.com/alpine/v3.11/main/' > /etc/apk/repositories \
    && echo 'https://mirrors.cloud.tencent.com/alpine/v3.11/community/' >> /etc/apk/repositories \
    && apk update \
    && apk add --no-cache tzdata bash curl busybox-extras \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo Asia/Shanghai > /etc/timezone \
    && apk del tzdata 
