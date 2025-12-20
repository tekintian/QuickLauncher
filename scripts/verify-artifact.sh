#!/bin/bash
# Verification script for CI artifacts

set -euo pipefail

if [ $# -ne 1 ]; then
    echo "Usage: $0 <package_name>"
    echo "Example: $0 QuickLauncher-Intel-Final"
    exit 1
fi

PACKAGE_NAME="$1"
PACKAGE_FILE="${PACKAGE_NAME}.tar.xz"

echo "🔍 Verifying package: $PACKAGE_FILE"

if [ ! -f "$PACKAGE_FILE" ]; then
    echo "❌ Package file not found: $PACKAGE_FILE"
    exit 1
fi

echo "📦 Package size: $(du -sh "$PACKAGE_FILE" | cut -f1)"
echo "📋 Package contents:"
tar -tvf "$PACKAGE_FILE" | head -20

# Extract to temp directory for verification
TEMP_DIR="/tmp/verify_$(basename "$PACKAGE_NAME")"
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"

echo "📂 Extracting to temp directory..."
tar -xf "$PACKAGE_FILE" -C "$TEMP_DIR"

APP_DIR=$(find "$TEMP_DIR" -name "*.app" -type d | head -1)
if [ -z "$APP_DIR" ]; then
    echo "❌ No app bundle found in package"
    rm -rf "$TEMP_DIR"
    exit 1
fi

echo "📁 App bundle: $(basename "$APP_DIR")"
echo "📊 App size: $(du -sh "$APP_DIR" | cut -f1)"

# Check Framework structure
FRAMEWORK_DIR="$APP_DIR/Contents/Frameworks/QuickLauncherCore.framework"
if [ -d "$FRAMEWORK_DIR" ]; then
    echo "🔍 Framework structure verification:"
    
    # Check symlinks
    if [ -L "$FRAMEWORK_DIR/QuickLauncherCore" ]; then
        echo "  ✅ QuickLauncherCore is symlink: $(readlink "$FRAMEWORK_DIR/QuickLauncherCore")"
    else
        echo "  ❌ QuickLauncherCore is NOT a symlink"
    fi
    
    if [ -L "$FRAMEWORK_DIR/Resources" ]; then
        echo "  ✅ Resources is symlink: $(readlink "$FRAMEWORK_DIR/Resources")"
    else
        echo "  ❌ Resources is NOT a symlink"
    fi
    
    if [ -L "$FRAMEWORK_DIR/Versions/Current" ]; then
        echo "  ✅ Versions/Current is symlink: $(readlink "$FRAMEWORK_DIR/Versions/Current")"
    else
        echo "  ❌ Versions/Current is NOT a symlink"
    fi
    
    echo "📁 Framework directory structure:"
    ls -la "$FRAMEWORK_DIR" | head -10
else
    echo "⚠️ No Framework directory found"
fi

# Clean up
rm -rf "$TEMP_DIR"
echo "✅ Verification completed"