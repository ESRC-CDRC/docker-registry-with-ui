FROM phusion/baseimage:0.9.16
MAINTAINER CDRC_UCL
# --TAG: gladys.geog.ucl.ac.uk/esrc-cdrc/docker-registry

ENV DOCKER_REGISTRY_HOME /usr/lib/docker-registry

# Make sure sshd is disabled
RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

RUN apt-get update \
# Install pip
    && apt-get install -y \
        swig \
        python-pip \
# Install deps for backports.lzma (python2 requires it)
        python-dev \
        python-mysqldb \
        python-rsa \
        libssl-dev \
        liblzma-dev \
        libevent1-dev \
        wget \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p ${DOCKER_REGISTRY_HOME} && wget -O- "https://github.com/docker/docker-registry/archive/0.9.1.tar.gz" | tar xz --strip-components=1 -C ${DOCKER_REGISTRY_HOME}
WORKDIR ${DOCKER_REGISTRY_HOME}
RUN cp ./config/boto.cfg /etc/
ADD ./docker-reg-config.yml /etc/
ADD ./service  /etc/service

# Install core
RUN pip install ${DOCKER_REGISTRY_HOME}/depends/docker-registry-core

# Install registry
RUN pip install file://${DOCKER_REGISTRY_HOME}#egg=docker-registry[bugsnag,newrelic,cors]

RUN patch \
    $(python -c 'import boto; import os; print os.path.dirname(boto.__file__)')/connection.py \
    < ${DOCKER_REGISTRY_HOME}/contrib/boto_header_patch.diff

ENV DOCKER_REGISTRY_CONFIG /etc/docker-reg-config.yml
ENV SETTINGS_FLAVOR local

VOLUME ['/var/lib/docker-registry']

EXPOSE 5000
