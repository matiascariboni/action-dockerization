#!/bin/bash
set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 BUILD SUMMARY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Verificar imagen construida
IMAGE_FILE="${{ steps.docker_config.outputs.IMAGE_NAME }}.tar"
if [ -f "$IMAGE_FILE" ]; then
  IMAGE_SIZE=$(du -h "$IMAGE_FILE" | cut -f1)
  IMAGE_SIZE_BYTES=$(stat -f%z "$IMAGE_FILE" 2>/dev/null || stat -c%s "$IMAGE_FILE" 2>/dev/null)
  echo "✅ Docker image built successfully"
  echo ""
  echo "📊 Image Details:"
  echo "   Name: $IMAGE_FILE"
  echo "   Size: $IMAGE_SIZE ($IMAGE_SIZE_BYTES bytes)"
  echo "   Tag: ${{ steps.docker_config.outputs.DOCKER_TAG }}"
  echo "   Platform: ${{ inputs.IMAGE_ARCH }}"
else
  echo "::error::❌ Docker image file not found: $IMAGE_FILE"
  exit 1
fi

echo ""
echo "🏗️  Build Configuration:"
RUNNER_ARCH=$(uname -m)
TARGET_ARCH="${{ inputs.IMAGE_ARCH }}"
QEMU_USED="${{ steps.detect_qemu.outputs.needs_qemu }}"

echo "   Runner Architecture: $RUNNER_ARCH"
echo "   Target Platform: $TARGET_ARCH"

# Mostrar información de compilación
if [ "$QEMU_USED" = "false" ]; then
  echo "   Build Type: 🚀 Native (optimized)"
  echo "   QEMU Emulation: No"
elif [ "$QEMU_USED" = "true" ]; then
  echo "   Build Type: ⚠️  Cross-compilation"
  echo "   QEMU Emulation: Yes"
else
  echo "   Build Type: Unknown"
  echo "   QEMU Emulation: N/A"
fi

# Información de cache
if [ "${{ inputs.CACHE }}" = "true" ]; then
  echo "   Docker Cache: Enabled ✅"
  if [ -d "/tmp/.buildx-cache" ]; then
    CACHE_SIZE=$(du -sh /tmp/.buildx-cache 2>/dev/null | cut -f1)
    echo "   Cache Size: $CACHE_SIZE"
  fi
else
  echo "   Docker Cache: Disabled"
fi

echo ""
echo "🔧 Compose Configuration:"
echo "   IMAGE_NAME: ${{ steps.docker_config.outputs.IMAGE_NAME }}"
echo "   COMPOSE_FILE_NAME: ${{ steps.docker_config.outputs.COMPOSE_FILE_NAME }}"
echo "   COMPOSE_PORTS: ${{ steps.port_formatter.outputs.COMPOSE_PORTS }}"
echo "   COMPOSE_NETWORKS: ${{ steps.net_formatter.outputs.COMPOSE_NETWORKS }}"
echo "   COMPOSE_VOLUMES: ${{ steps.volume_formatter.outputs.COMPOSE_VOLUMES }}"

echo ""
echo "💾 Disk Space After Build:"
df -h . | tail -1 | awk '{printf "   Available: %s / %s (%s used)\n", $4, $2, $5}'

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"