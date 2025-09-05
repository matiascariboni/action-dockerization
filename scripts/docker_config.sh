#!/bin/bash
set -e

if [[ $GITHUB_REF == *tags* ]]; then
  echo "Tag push detected"
  echo "DOCKER_TAG=${GITHUB_REF_NAME}" >> $GITHUB_OUTPUT
  git fetch --tags
  BRANCH_NAME=$(git branch -r --contains tags/${GITHUB_REF_NAME} | grep -v HEAD | awk -F'origin/' '{print $2}')
else
  echo "Branch push detected"
  BRANCH_NAME=${GITHUB_REF_NAME}
  echo "DOCKER_TAG=$(git rev-parse --short HEAD)" >> $GITHUB_OUTPUT
fi

DOCKERFILE_PATH="./Dockerfile.$(echo "${ENV_NAME}" | tr '[:upper:]' '[:lower:]')"
if [[ -f "$DOCKERFILE_PATH" ]]; then
  echo "Dockerfile found in: $DOCKERFILE_PATH"
else
  echo "Default Dockerfile found"
  DOCKERFILE_PATH="./Dockerfile"
fi

echo "DOCKERFILE_PATH=$DOCKERFILE_PATH" >> $GITHUB_OUTPUT

COMPOSE_FILE_NAME=${COMPOSE_NAME}"_$(echo "${ENV_NAME}" | tr '[:upper:]' '[:lower:]').yml"
echo "COMPOSE_FILE_NAME=$COMPOSE_FILE_NAME" >> $GITHUB_OUTPUT

IMAGE_NAME="${GITHUB_REPOSITORY#*/}_${ENV_NAME}"
echo "IMAGE_NAME=$IMAGE_NAME" >> $GITHUB_OUTPUT
