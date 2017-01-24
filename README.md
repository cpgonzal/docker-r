## R Dockerfile

This repository contains **Dockerfile** for [Docker](https://www.docker.com/)'s [automated build](https://registry.hub.docker.com/u/dockerfile/cpgonzal/) published to the public [Docker Hub Registry](https://registry.hub.docker.com/).


### Base Docker Image

* [dockerhub/debian:jessie](https://hub.docker.com/r/_/debian/)

### Installation

1. Install [Docker](https://www.docker.com/).

2. Download [automated build](https://registry.hub.docker.com/u/dockerfile/cpgonzal/) from public [Docker Hub Registry](https://registry.hub.docker.com/): `docker pull cpgonzal/docker-r`

   (alternatively, you can build an image from Dockerfile: `docker build --build-arg R_VERSION=3.3.2 -t="cpgonzal/docker-r" github.com/cpgonzal/docker-r`)


### Usage

#### Run `cpgonzal/docker-r` container

    docker run -d cpgonzal/docker-r

#### Run `cpgonzal/docker-r` container with persistent shared directories.

    docker run -d -v <data-dir>:/data -v <libraries-dir>:/libraries cpgonzal/docker-r
