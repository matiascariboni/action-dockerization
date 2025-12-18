#!/bin/bash
set -e

RUNNER_ARCH=$(uname -m)
TARGET_ARCH="${IMAGE_ARCH}"
USE_QEMU_INPUT="${USE_QEMU}"

echo "🔍 Detecting cross-compilation requirement..."
echo "   Runner architecture: $RUNNER_ARCH"
echo "   Target architecture: $TARGET_ARCH"

# Auto-detect if USE_QEMU is 'auto'
if [ "$USE_QEMU_INPUT" = "auto" ]; then
  # Normalizar arquitectura del runner
  case "$RUNNER_ARCH" in
    x86_64|amd64)
      RUNNER_NORMALIZED="amd64"
      ;;
    aarch64|arm64)
      RUNNER_NORMALIZED="arm64"
      ;;
    armv7l|armhf)
      RUNNER_NORMALIZED="armv7"
      ;;
    *)
      RUNNER_NORMALIZED="$RUNNER_ARCH"
      ;;
  esac

  # Detectar si target coincide con runner
  if [[ "$TARGET_ARCH" == *"$RUNNER_NORMALIZED"* ]]; then
    NEEDS_QEMU="false"
    echo "✅ Native build detected: $RUNNER_NORMALIZED matches $TARGET_ARCH"
  else
    NEEDS_QEMU="true"
    echo "⚠️  Cross-compilation detected: $RUNNER_NORMALIZED → $TARGET_ARCH"
    echo "   QEMU will be enabled for emulation"
  fi
else
  NEEDS_QEMU="$USE_QEMU_INPUT"
  echo "🔧 QEMU manually set to: $USE_QEMU_INPUT"
fi

# Exportar outputs
echo "needs_qemu=$NEEDS_QEMU" >> $GITHUB_OUTPUT
echo "runner_arch=$RUNNER_ARCH" >> $GITHUB_OUTPUT

echo ""
if [ "$NEEDS_QEMU" = "false" ]; then
  echo "🚀 Native build - Maximum performance expected"
else
  echo "⚠️  Cross-compilation build - Slower performance expected"
fi