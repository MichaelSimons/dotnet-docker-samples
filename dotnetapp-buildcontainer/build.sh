#!/bin/sh

# Capture the current build and app image, if any, so that we can clean them up when we are done.
currentBuildImage=$(docker images build-image -q)
currentAppImage=$(docker images dockerapp -q)

docker build -t build-image -f Dockerfile.build .

# Create a container from our build image so that we can copy the contents out.
docker create --name build-container build-image
# Copy the contents of the /out directory out so that we can build our app image.
docker cp build-container:/out ./out
# Build the application image.
docker build -t dockerapp .

# Cleanup
docker rm build-container

rm -r ./out

if [ -n "$currentBuildImage" ]; then
    docker rmi $currentBuildImage
fi

if [ -n "$currentAppImage" ]; then
    docker rmi $currentAppImage
fi
