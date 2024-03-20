#!/bin/bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

buildctl \
 --addr docker-container://dbdbdp-buildkit \
 build \
 --progress auto \
 --opt hostname=cake.duponey.cloud \
 --opt image-resolve-mode=default \
 --opt force-network-mode=sandbox \
 --local dockerfile=./ \
 --frontend dockerfile.v0 \
 --trace cache/buildctl.trace.json \
 --opt filename=Dockerfile \
 --local context=./context \
 --export-cache type=local,dest=./cache/buildkit,mode=max,oci-mediatypes=true \
 --import-cache type=local,src=./cache/buildkit \
 --opt platform=linux/amd64,linux/arm64 \
 --output type=image,"name=docker.io/dubodubonduponey/theengs:latest",push=true,oci-mediatypes=true \
 --opt add-hosts=go-proxy.local=10.0.4.101 \
 --opt build-arg:BUILD_CREATED=2024-03-19T20:46:29-0700 \
 --opt build-arg:BUILD_URL=https://github.com/dubo-dubon-duponey \
 --opt build-arg:"BUILD_LICENSES=The MIT License (MIT)" \
 --opt build-arg:BUILD_VERSION=dev \
 --opt build-arg:BUILD_REVISION=dirty \
 --opt build-arg:BUILD_DOCUMENTATION=https://github.com/dubo-dubon-duponey \
 --opt build-arg:BUILD_SOURCE=https://github.com/dubo-dubon-duponey \
 --opt build-arg:BUILD_VENDOR=dubodubonduponey \
 --opt build-arg:BUILD_REF_NAME=latest \
 --opt build-arg:FROM_REGISTRY=docker.io/dubodubonduponey

