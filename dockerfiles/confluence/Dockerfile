# https://gitee.com/pengzhile/atlassian-agent

FROM atlassian/confluence-server:7.3.1

# 将代理破解包加入容器
COPY "atlassian-agent.jar" /opt/atlassian/confluence/
COPY docker-entrypoint.sh /

# 设置启动加载代理包
RUN echo "nameserver 114.114.114.114" | tee /etc/resolv.conf > /dev/null \
	&& apt-get update && apt-get upgrade && apt-get install xmlstarlet -y \
	&& echo 'export CATALINA_OPTS="-javaagent:/opt/atlassian/confluence/atlassian-agent.jar ${CATALINA_OPTS}"' >> /opt/atlassian/confluence/bin/setenv.sh 

ENTRYPOINT ["/docker-entrypoint.sh"]