FROM amsokol/centos-java8:latest
MAINTAINER Alexander Sokolovsky <amsokol@gmail.com>

# User root user to install software
USER root

# Execute system update
RUN yum -y update && yum -y install tar && yum clean all

# Create a user and group used to launch processes
# The user ID 1000 is the default for the first "regular" user on Fedora/RHEL,
# so there is a high chance that this ID will be equal to the current user
# making it easier to use volumes (no permission issues)
RUN groupadd -r tomcat -g 1000 && useradd -u 1000 -r -g tomcat -m -d /opt/tomcat -s /sbin/nologin -c "Tomcat user" tomcat

# Specify the user which should be used to execute all commands below
USER tomcat

# Set the working directory to tomcat's user home directory
WORKDIR /opt/tomcat

# Set the JAVA_HOME variable to make it clear where Java is located
ENV JAVA_HOME /usr/java/latest

# Set the WILDFLY_VERSION env variable
ENV TOMCAT_VERSION 7.0.59

COPY assets/apache-tomcat-$TOMCAT_VERSION.tar.gz /opt/tomcat/apache-tomcat.tar.gz

RUN cd $HOME && tar -zxf apache-tomcat.tar.gz && mv apache-tomcat-$TOMCAT_VERSION apache-tomcat && rm apache-tomcat.tar.gz

# Expose the folders we're interested in
VOLUME ["/opt/tomcat/apache-tomcat/logs"]
VOLUME ["/opt/tomcat/apache-tomcat/webapps"]

# Expose the ports we're interested in
EXPOSE 8080

# Set the default command to run on boot
CMD ["java", "-Djava.util.logging.config.file=/opt/tomcat/apache-tomcat/conf/logging.properties", "-Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager", "-Djava.net.preferIPv4Stack=true", "-Duser.timezone=GMT", "-Xms750m", "-Xmx1200m", "-Xnoagent", "-Djava.compiler=NONE", "-XX:+UseConcMarkSweepGC", "-XX:+CMSClassUnloadingEnabled", "-Dfile.encoding=UTF-8", "-Djava.endorsed.dirs=/opt/tomcat/apache-tomcat/endorsed", "-classpath", "/opt/tomcat/apache-tomcat/bin/bootstrap.jar:/opt/tomcat/apache-tomcat/bin/tomcat-juli.jar", "-Dcatalina.base=/opt/tomcat/apache-tomcat", "-Dcatalina.home=/opt/tomcat/apache-tomcat", "-Djava.io.tmpdir=/opt/tomcat/apache-tomcat/temp", "org.apache.catalina.startup.Bootstrap", "start"]

