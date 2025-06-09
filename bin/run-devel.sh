#!/bin/sh

set -e

# Root directory.
BASEDIR=$( cd `dirname $0`/.. ; pwd )
cd "$BASEDIR"

sh bin/build.sh -t devel

docker stop adminneo-devel || true
docker rm adminneo-devel || true

docker run -d --name adminneo-devel -p 8080:8080 \
  -e NEO_COLOR_VARIANT=green \
  -e NEO_PREFER_SELECTION=true \
  -e NEO_JSON_VALUES_DETECTION=true \
  -e NEO_JSON_VALUES_AUTO_FORMAT=true \
  -e NEO_VISIBLE_COLLATIONS='ascii_general_ci,utf8mb4*czech*ci' \
  -e NEO_HIDDEN_DATABASES=__system \
  -e NEO_HIDDEN_SCHEMAS=__system \
  -e NEO_DEFAULT_PASSWORD_HASH= \
  -e NEO_SSL_TRUST_SERVER_CERTIFICATE=true \
  adminneoorg/adminneo:devel
