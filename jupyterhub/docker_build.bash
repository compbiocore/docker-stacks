#!/bin/bash

# Builds and pushes a given image to gcr.io + all nodes in current kubectl
# context

set -e

DOCKER_REPO=""
DOCKER_PUSH="docker push"
FORCE=False
NO_CACHE=False

while getopts "fr:" opt; do
    echo $opt
	case $opt in
		f) FORCE=True 
		;;
		n) NO_CACHE=True
		# force docker to build images with no cache
		# (use when something in an internal r script changed but the dockerfile itself did not)
		;;
		r) DOCKER_REPO="$OPTARG" 
		;;
		\? )
		echo "Usage: $0  [-f:forces build if git out of date] [-r DOCKER_REPO] [ IMAGE_FOLDER ]"
		;;
	esac
done
shift $((OPTIND-1))

# Bail if we're on a dirty git tree
echo "Force Build? $FORCE"
if ! $FORCE; then
	if ! git diff-index --quiet HEAD; then
		echo "You have uncommited changes. Please commit them before building and"
		echo "populating. This helps ensure that all docker images are traceable"
		echo "back to a git commit."
		exit 1
	fi
fi

IFS='-' read -r -a images <<< "$1"

GIT_REV=$(git log -n 1 --pretty=format:%h)
TAG="${GIT_REV}"

for index in "${!images[@]}"
do
    IMAGE=${images[0]}

	for (( j=1; j<=$index; j++ )) 
	do
		IMAGE="${IMAGE}-${images[j]}"
	done
	
	echo "Building $IMAGE"
	if [ ! -f ${IMAGE}/Dockerfile ]; then
		echo "No such file: ${IMAGE}/Dockerfile"
		exit 1
	fi

	IMAGE_NAME=jupyterhub-${IMAGE}
	IMAGE_SPEC="${DOCKER_REPO}/${IMAGE_NAME}:${TAG}"
	if NO_CACHE; then
		docker build --no-cache -f ${IMAGE}/Dockerfile -t ${IMAGE_SPEC} .
	else
		docker build -f ${IMAGE}/Dockerfile -t ${IMAGE_SPEC} .
	fi
	${DOCKER_PUSH} ${IMAGE_SPEC}
	echo "Pushed ${IMAGE_SPEC}"

	# Create latest tag
	docker tag ${DOCKER_REPO}/${IMAGE_NAME}:${TAG} ${DOCKER_REPO}/${IMAGE_NAME}:latest
	docker push ${DOCKER_REPO}/${IMAGE_NAME}:latest

done

