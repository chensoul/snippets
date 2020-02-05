# https://gitee.com/pengzhile/atlassian-agent

FROM atlassian/confluence-server:7.2.2

# 将代理破解包加入容器
COPY "atlassian-agent.jar" /opt/atlassian/confluence/

# 设置启动加载代理包
RUN echo 'export CATALINA_OPTS="-javaagent:/opt/atlassian/confluence/atlassian-agent.jar ${CATALINA_OPTS}"' >> /opt/atlassian/confluence/bin/setenv.sh \
	&& sed -i 's/1024m/3072m/g' /opt/atlassian/confluence/bin/setenv.sh