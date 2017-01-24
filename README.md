## R Dockerfile

This repository contains **Dockerfile** for [Docker](https://www.docker.com/)'s [automated build](https://registry.hub.docker.com/u/dockerfile/cpgonzal/) published to the public [Docker Hub Registry](https://registry.hub.docker.com/).


### Base Docker Image

* [dockerhub/debian:jessie](https://hub.docker.com/r/_/debian/)

### Installation

1. Install [Docker](https://www.docker.com/).

2. Download [automated build](https://registry.hub.docker.com/u/dockerfile/cpgonzal/) from public [Docker Hub Registry](https://registry.hub.docker.com/): `docker pull cpgonzal/docker-r`

   (alternatively, you can build an image from Dockerfile: `docker build --build-arg R_VERSION=3.3.2 -t="cpgonzal/docker-r" github.com/cpgonzal/docker-r`)


### Usage

#### Run `docker-r`

    docker run --rm -d cpgonzal/docker-r

#### Run `cpgonzal/docker-data-volume` with persistent shared directories.

    docker run --rm -d -v <log-dir>:/data -v <data-dir>:/libraries cpgonzal/docker-r
=======
# docker-r
R Dockerfile for trusted automated Docker builds. https://hub.docker.com/r/cpgonzal/docker-data-volume/ 
>>>>>>> ea0a54e076571b63a194f53f143380884b70baee
