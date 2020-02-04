FROM javachen/centos:7

# Create a user and group used to launch processes
# The user ID 1000 is the default for the first "regular" user on Fedora/RHEL,
# so there is a high chance that this ID will be equal to the current user
# making it easier to use volumes (no permission issues)
RUN yum -y install java-1.8.0-openjdk-devel \
	&& groupadd -r java -g 1000 \
	&& useradd -u 1000 -r -g java -m -d /home/java -s /sbin/nologin -c "Java user" java \
	&& chmod 755 /home/java

# Set the JAVA_HOME variable to make it clear where Java is located
ENV JAVA_HOME /usr/lib/jvm/java

# Set the working directory to java' user home directory
WORKDIR /home/java

# Specify the user which should be used to execute all commands below
USER java