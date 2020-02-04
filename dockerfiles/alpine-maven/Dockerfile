FROM javachen/alpine-jdk:8

USER root

# Install Maven
RUN apk add wget \
    && wget --no-verbose -O /tmp/apache-maven-3.3.9.tar.gz http://archive.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz \
    && tar xzf /tmp/apache-maven-3.3.9.tar.gz -C /opt/ \
    && ln -s /opt/apache-maven-3.3.9 /opt/maven \
    && ln -s /opt/maven/bin/mvn /usr/local/bin \
    && rm -f /tmp/apache-maven-3.3.9.tar.gz

ENV MAVEN_HOME=/opt/maven M2_HOME=/opt/maven

USER java 

# Dump to bash
CMD ["bash"]