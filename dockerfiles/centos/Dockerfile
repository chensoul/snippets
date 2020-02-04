FROM centos:7

RUN yum update -y && yum -y install kde-l10n-Chinese && yum clean all \
	&& localedef -c -f UTF-8 -i zh_CN zh_CN.utf8 \
	&& echo 'LC_ALL="zh_CN.utf8"' > /etc/locale.conf \
	&& cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo Asia/Shanghai > /etc/timezone 

ENV LANG=zh_CN.utf8 \
	LC_ALL=zh_CN.utf8