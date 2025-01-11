all: image-linux

VERSION=latest

.PHONY: image-linux
image-linux:
	@DOCKER_BUILDKIT=1 docker build . --platform linux/amd64 -t monro/calibre-kcc-web:${VERSION}



