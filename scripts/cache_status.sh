#!/bin/bash
set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🗂️  DOCKER LAYER CACHE - STATUS & RECOMMENDATIONS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ "${{ inputs.CACHE }}" == "true" ]; then
  echo "✅ Docker layer caching is ENABLED"
  echo ""

  # Check cache status
  if [ "${{ steps.cache-docker.outputs.cache-hit }}" == "true" ]; then
    echo "::notice::🎯 Cache Status: EXACT MATCH FOUND"
    echo "   Source: Current commit cache"
    echo "   Result: Maximum speed - all layers will be reused"
  elif [ -d "/tmp/.buildx-cache" ] && [ "$(ls -A /tmp/.buildx-cache 2>/dev/null)" ]; then
    CACHE_SIZE=$(du -sh /tmp/.buildx-cache 2>/dev/null | cut -f1 || echo "unknown")
    echo "::notice::♻️  Cache Status: RESTORED from previous build"
    echo "   Size: $CACHE_SIZE"
    echo "   Result: Unchanged layers will be reused - significant speedup expected"
  else
    echo "::notice::🆕 Cache Status: NOT FOUND (fresh build)"
    echo "   Result: This build will create cache for future runs"
  fi

  echo ""
  echo "📍 Cache location: /tmp/.buildx-cache"
  echo ""
  echo "💡 Recommendation: Set up a scheduled workflow to clean old caches periodically."
  echo "   This prevents cache accumulation and ensures fresh system packages."
  echo "   See documentation for cleanup workflow example."
else
  echo "::notice::ℹ️  Docker layer caching is DISABLED"
  echo ""
  echo "💡 Consider enabling cache for faster builds!"
  echo ""
  echo "To enable, add this to your workflow:"
  echo "   CACHE: 'true'"
  echo ""
  echo "Benefits:"
  echo "   • 5-7 minutes faster builds (on average)"
  echo "   • Only changed layers are rebuilt"
  echo "   • Significant CI/CD pipeline time savings"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"