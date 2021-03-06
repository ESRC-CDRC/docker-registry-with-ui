# This Makefile is for building 
SHELL=/bin/bash

CWD=$(shell pwd)
ROOT_IP=$(shell /sbin/ip route|awk '/docker0/ { print $$NF }')
REG_PORT=2625
WEB_UI_PORT=2628
REG_CONTAINER=docker_reg
UI_CONTAINER=docker_reg_ui
DATA_CONTAINER=docker_reg_data
DOCKER_HUB=gladys.geog.ucl.ac.uk
DOCKER_REPO=esrc_cdrc
IMG_REG=${DOCKER_HUB}/${DOCKER_REPO}/docker-registry
IMG_REGUI=${DOCKER_HUB}/${DOCKER_REPO}/docker-registry-ui

start: webui reg

images:
		(cd docker-registry; docker build -t ${IMG_REG} .)
		(cd docker-registry-ui; docker build -t ${IMG_REGUI} .)

fromtar:
		docker build -t ${IMG_REG} - < cdrc-docker-registry.tar.gz
		docker build -t ${IMG_REG} - < cdrc-docker-registry-ui.tar.gz

tar:
		tar czf cdrc-docker-registry.tar.gz -C docker-registry .
		tar czf cdrc-docker-registry-ui.tar.gz -C docker-registry-ui .

webui: reg volume
		@echo 'Starting docker web UI for docker registry...'
		@docker run -d --name ${UI_CONTAINER} \
			-p ${WEB_UI_PORT}:8080 \
			--volumes-from ${DATA_CONTAINER} \
			-e REG1=http://${ROOT_IP}:2625/v1/ \
			${IMG_REGUI}

reg: volume
		@echo 'Starting docker registry service...'
		@docker run -d --name ${REG_CONTAINER} \
			-p ${REG_PORT}:5000 \
			--volumes-from ${DATA_CONTAINER} \
			-e GUNICORN_OPTS=[--preload] \
			${IMG_REG}

volume:
		@echo 'Creating docker data container'
		# holding the registry data in /tmp/registry for docker-registry and web configuration in /var/lib/h2 for docker-registry-ui
		@if [ -z "$(shell docker ps -a | grep docker_reg_data)" ]; then \
			docker create --name ${DATA_CONTAINER} \
				-v /var/lib/docker-registry \
				-v /var/lib/h2 \
				phusion/baseimage:0.9.16; \
		fi

stop:
		docker stop docker_reg_ui
		docker stop docker_reg

restart:
		docker restart docker_reg
		docker restart docker_reg_ui

clean: stop
		docker rm docker_reg_ui ||: 
		docker rm docker_reg ||:

cleanall: clean
		docker rmi ${IMG_REG} ||:
		docker rmi ${IMG_REGUI} ||:
		rm *.tar.gz ||:
		@echo "The data container docker_reg_data are not removed."

.PHONY: reg stopall clean volume images tar start webui
