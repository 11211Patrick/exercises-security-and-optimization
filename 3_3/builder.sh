#!/bin/sh
# Usage: ./builder.sh <github-repo> <docker-image>
# Example: ./builder.sh mluukkai/express_app mluukkai/testing
 
# Stop immediately if any command fails
set -e
 
# 1. Check arguments
if [ "$#" -ne 2 ]; then
  echo "Usage: ./builder.sh <github-repo> <docker-image>"
  exit 1
fi
 
GITHUB_REPO="$1"
DOCKER_IMAGE="$2"
 
# 2. Clone into a temporary directory that is removed when the script exits
WORKDIR=$(mktemp -d)
trap 'rm -rf "$WORKDIR"' EXIT
 
echo "==> Cloning https://github.com/$GITHUB_REPO"
git clone --depth 1 "https://github.com/$GITHUB_REPO.git" "$WORKDIR/repo"
 
if [ ! -f "$WORKDIR/repo/Dockerfile" ]; then
  echo "Error: no Dockerfile found in the root of $GITHUB_REPO"
  exit 1
fi
 
# 3. Build the image
echo "==> Building image $DOCKER_IMAGE"
docker build -t "$DOCKER_IMAGE" "$WORKDIR/repo"
 
# 4. Push to Docker Hub (requires a prior 'docker login')
echo "==> Pushing $DOCKER_IMAGE to Docker Hub"
docker push "$DOCKER_IMAGE"
 
echo "==> Done: $DOCKER_IMAGE is now on Docker Hub"
