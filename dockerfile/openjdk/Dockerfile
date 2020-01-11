# JVM 在 Docker 等容器环境下的资源限制问题 
# https://blog.yuanbin.me/posts/2019-03/2019-03-18_23-30-06/
# https://segmentfault.com/a/1190000021392583?utm_medium=referral

FROM openjdk:8u201-jdk-alpine

RUN set -euxo pipefail \
    && echo 'https://mirrors.cloud.tencent.com/alpine/v3.11/main/' > /etc/apk/repositories \
    && echo 'https://mirrors.cloud.tencent.com/alpine/v3.11/community/' >> /etc/apk/repositories \
    && apk update \
    && apk add --no-cache tzdata bash tini curl busybox-extras \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo Asia/Shanghai > /etc/timezone \
    && apk del tzdata \
    && curl -L https://alibaba.github.io/arthas/install.sh | sh \
    && mv as.sh /usr/bin/as.sh

ENTRYPOINT ["/sbin/tini", "--"]

CMD ["java", "-XX:InitialRAMPercentage=10.0", "-XX:MaxRAMPercentage=50.0", "-XshowSettings:vm", "-version"]