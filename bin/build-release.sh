#!/bin/sh

set -e

# Root directory.
BASEDIR=$( cd `dirname $0`/.. ; pwd )
cd "$BASEDIR"

GIT_TAG=$( git ls-remote --exit-code --refs --tags --sort='-version:refname' \
  https://github.com/adminneo-org/adminneo.git 'v*.*.*' \
  | sed '/-/d' \
  | head --lines=1 \
  | cut -d / -f 3 )

sh bin/build.sh -t ${GIT_TAG:1}
sh bin/build.sh -t latest
