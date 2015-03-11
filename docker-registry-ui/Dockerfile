FROM phusion/baseimage:0.9.16
MAINTAINER CDRC_UCL
# --TAG: gladys.geog.ucl.ac.uk/esrc-cdrc/docker-registry-ui

# Make sure sshd is disabled
RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

RUN apt-get update \
# Install Tomcat and JDK
    && apt-get install -y \
      tomcat7 \
      openjdk-7-jdk \
      wget \
    && rm -rf /var/lib/apt/lists/*
RUN mkdir /var/lib/h2 && chmod a+rw /var/lib/h2
RUN rm -rf /var/lib/tomcat7/webapps/*

ENV DRUI_ROOT /usr/lib/docker-reg-webui
ENV CATALINA_BASE /var/lib/tomcat7
ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64/

# Install grails and project dependencies
WORKDIR ${DRUI_ROOT}
RUN wget -O- "https://github.com/atc-/docker-registry-web/archive/v0.97.0.tar.gz" | tar zx --strip-components=1 -C ${DRUI_ROOT}
RUN ./grailsw help
RUN ./grailsw war \
    && cp target/docker-registry-ui-*.war /var/lib/tomcat7/webapps/ROOT.war

# Update catalina configuration
ADD ./service /etc/service

EXPOSE 8080
VOLUME ["/var/lib/h2/", "/var/lib/tomcat7"]
