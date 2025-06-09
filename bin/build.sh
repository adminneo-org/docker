#!/bin/sh

set -e

# Root directory.
BASEDIR=$( cd `dirname $0`/.. ; pwd )
cd "$BASEDIR"

usage() {
    echo "Usage:"
    echo "  sh $0 [options]"
    echo ""
    echo "OPTIONS:"
    echo "  -t    Docker image tag"
    echo ""
    echo "EXAMPLES:"
    echo "  sh $0 -t devel"
    echo "  sh $0 -t latest"
    echo "  sh $0 -t 5.0.0"
    exit 1
}

TAG=devel
CACHE_BUST=1

# Read command line options.
while getopts t:h option
do
    case $option in
        t)
            TAG="$OPTARG"
            ;;
        h)
            usage
            ;;
        *)
            usage
            ;;
    esac
done

case $TAG in
    devel)
        GIT_TAG=main
        CACHE_BUST="$(date +%s)"
        ;;
    latest)
        GIT_TAG=$( git ls-remote --exit-code --refs --tags --sort='-version:refname' \
            https://github.com/adminneo-org/adminneo.git 'v*.*.*' \
            | sed '/-/d' \
            | head --lines=1 \
            | cut -d / -f 3 )
        ;;
    *)
        GIT_TAG="v$TAG"
        ;;
esac

echo "🛠️ Building AdminNeo Docker image"
echo ""
echo "tag:        $TAG"
echo "git tag:    $GIT_TAG"
echo "cache bust: $CACHE_BUST"
echo ""

docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t "adminneoorg/adminneo:$TAG" \
  --build-arg GIT_TAG="$GIT_TAG" \
  --build-arg CACHE_BUST="$CACHE_BUST" \
  .
