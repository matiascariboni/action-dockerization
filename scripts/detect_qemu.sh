#!/bin/bash
set -e

RUNNER_ARCH=$(uname -m)
TARGET_ARCH="${{ inputs.IMAGE_ARCH }}"
USE_QEMU="${{ inputs.USE_QEMU }}"

echo "🔍 Runner architecture: $RUNNER_ARCH"
echo "🎯 Target architecture: $TARGET_ARCH"

# Auto-detect if USE_QEMU is 'auto'
if [ "$USE_QEMU" = "auto" ]; then
  # Mapeo de arquitecturas
  if [[ "$RUNNER_ARCH" == "x86_64" || "$RUNNER_ARCH" == "amd64" ]]; then
    RUNNER_NORMALIZED="amd64"
  elif [[ "$RUNNER_ARCH" == "aarch64" || "$RUNNER_ARCH" == "arm64" ]]; then
    RUNNER_NORMALIZED="arm64"
  else
    RUNNER_NORMALIZED="$RUNNER_ARCH"
  fi

  # Detect if target matches runner
  if [[ "$TARGET_ARCH" == *"$RUNNER_NORMALIZED"* ]]; then
    NEEDS_QEMU="false"
    echo "✅ Native build detected: $RUNNER_NORMALIZED → $TARGET_ARCH"
  else
    NEEDS_QEMU="true"
    echo "⚠️  Cross-compilation detected: $RUNNER_NORMALIZED → $TARGET_ARCH"
  fi
else
  NEEDS_QEMU="$USE_QEMU"
  echo "🔧 QEMU manually set to: $USE_QEMU"
fi

echo "needs_qemu=$NEEDS_QEMU" >> $GITHUB_OUTPUT
echo "runner_arch=$RUNNER_ARCH" >> $GITHUB_OUTPUT