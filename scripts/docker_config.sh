#!/bin/bash
set -e

# Get the branch
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

# Si ENV_NAME está vacío, usar el último segmento del nombre de la rama
if [ -z "$ENV_NAME" ]; then
  # Extraer el último segmento después del último "/"
  ENV_NAME=$(echo "${BRANCH_NAME}" | awk -F'/' '{print $NF}')
  echo "ENV_NAME not provided, using branch name: $ENV_NAME"
fi

# Buscar Dockerfile específico del entorno
DOCKERFILE_PATH="./Dockerfile.$(echo "${ENV_NAME}" | tr '[:upper:]' '[:lower:]')"
if [[ -f "$DOCKERFILE_PATH" ]]; then
  echo "Environment-specific Dockerfile found: $DOCKERFILE_PATH"
else
  echo "Using default Dockerfile"
  DOCKERFILE_PATH="./Dockerfile"
fi
echo "DOCKERFILE_PATH=$DOCKERFILE_PATH" >> $GITHUB_OUTPUT

# Generar nombre del compose file
COMPOSE_FILE_NAME="${COMPOSE_NAME}_$(echo "${ENV_NAME}" | tr '[:upper:]' '[:lower:]').yml"
echo "COMPOSE_FILE_NAME=$COMPOSE_FILE_NAME" >> $GITHUB_OUTPUT

# Generar nombre de imagen
IMAGE_NAME="${GITHUB_REPOSITORY#*/}_${ENV_NAME}"
echo "IMAGE_NAME=$IMAGE_NAME" >> $GITHUB_OUTPUT