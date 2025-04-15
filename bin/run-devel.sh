#!/bin/sh

set -e

# Root directory.
BASEDIR=$( cd `dirname $0`/.. ; pwd )
cd "$BASEDIR"

docker buildx build --platform linux/amd64,linux/arm64 -t peterknut/adminneo:devel --build-arg CACHE_BUST="$(date +%s)" .

docker stop adminneo || true
docker rm adminneo || true

docker run -d --name adminneo -p 8080:8080 \
  -e NEO_COLOR_VARIANT=green \
  -e NEO_PREFER_SELECTION=true \
  -e NEO_JSON_VALUES_DETECTION=true \
  -e NEO_JSON_VALUES_AUTO_FORMAT=true \
  -e NEO_DEFAULT_PASSWORD_HASH= \
  -e NEO_SSL_TRUST_SERVER_CERTIFICATE=true \
  peterknut/adminneo:devel
