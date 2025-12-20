#!/bin/bash
# QuickLauncher Unused Libraries Cleanup Script
# Removes unused Swift libraries to reduce app size

set -euo pipefail

if [ $# -ne 1 ]; then
    echo "Usage: $0 <app_bundle_path>"
    echo "Example: $0 CI-Artifacts/QuickLauncher-Intel.app"
    exit 1
fi

APP_BUNDLE="$1"
FRAMEWORKS_DIR="$APP_BUNDLE/Contents/Frameworks"

echo "🧹 Cleaning unused libraries in $APP_BUNDLE..."

if [ ! -d "$FRAMEWORKS_DIR" ]; then
    echo "⚠️ No Frameworks directory found"
    exit 0
fi

# List of unused Swift libraries that can be safely removed
UNUSED_LIBS=(
    "libswiftCloudKit.dylib"
    "libswiftCoreLocation.dylib"
    "libswiftCoreData.dylib"
    "libswiftMetal.dylib"
    "libswiftCoreImage.dylib"
    "libswiftIOKit.dylib"
    "libswiftQuartzCore.dylib"
    "libswiftMediaPlayer.dylib"
    "libswiftGameplayKit.dylib"
    "libswiftSpriteKit.dylib"
    "libswiftSceneKit.dylib"
    "libswiftAVFoundation.dylib"
    "libswiftCoreMedia.dylib"
    "libswiftCoreGraphics.dylib"
    "libswiftCoreText.dylib"
    "libswiftImageIO.dylib"
    "libswiftDarwin.dylib"
    "libswiftDispatch.dylib"
    "libswiftFoundation.dylib"
    "libswiftObjectiveC.dylib"
    "libswiftXPC.dylib"
)

REMOVED_COUNT=0
for lib in "${UNUSED_LIBS[@]}"; do
    LIB_PATH="$FRAMEWORKS_DIR/$lib"
    if [ -f "$LIB_PATH" ]; then
        rm "$LIB_PATH"
        echo "  🗑️ Removed: $lib"
        ((REMOVED_COUNT++))
    fi
done

echo "✅ Cleanup completed - removed $REMOVED_COUNT unused libraries"

# Show final size
if [ -d "$APP_BUNDLE" ]; then
    APP_SIZE=$(du -sh "$APP_BUNDLE" | cut -f1)
    echo "📊 Final app size: $APP_SIZE"
fi