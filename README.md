# Docker registry with Web UI

This project provide docker images for setup a private docker registry together with a simple Web UI for browsing the registry.

## It provides

- A docker image adatped from the official [registry](https://github.com/docker/docker-registry) v0.9.1
- A docker image adapted from [docker-registry-ui](https://github.com/atc-/docker-registry-web) v0.97.0
- A Makefile for simplifying the deployment process

## How to use

- Clone the project from this repo
- `make images` to build the images and store them into the local image cache
- `make start` to run the containers from the lately build images
- Then you are able to push images to the registry by giving the name `<domainname>:<port>/<repo>/<imagename>:<tag>` and browsing the images though the web interface `http://<domainname>:<port>`

## Adapation

You may configure all the names and ports in the `Makefile` to match your settings.
You may use `make tar` to build an archive for the two image source projects and then build them in the target server.

## Notes

This project provides two services (docker-registry and docker-registry-ui), one is specifically for docker image registry which provides only APIs for accessing the information.
The second service is purely an interface over the API.
You can only push images to the docker-registry service and only browse the registry via docker-registry-ui service, and they are assigned to different ports which can be configured in Makefile.
