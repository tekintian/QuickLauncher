#!/bin/bash
# QuickLauncher Framework Structure Fix Script
# Ensures proper Framework structure with symlinks instead of duplicate files

set -euo pipefail

if [ $# -ne 1 ]; then
    echo "Usage: $0 <app_bundle_path>"
    echo "Example: $0 CI-Artifacts/QuickLauncher-Intel.app"
    exit 1
fi

APP_BUNDLE="$1"
FRAMEWORKS_DIR="$APP_BUNDLE/Contents/Frameworks"

echo "🔧 Fixing Framework structure in $APP_BUNDLE..."

if [ ! -d "$FRAMEWORKS_DIR" ]; then
    echo "⚠️ No Frameworks directory found"
    exit 0
fi

# Find and fix all frameworks
find "$FRAMEWORKS_DIR" -name "*.framework" -type d | while read framework; do
    FRAMEWORK_NAME=$(basename "$framework" .framework)
    echo "  📦 Fixing $FRAMEWORK_NAME.framework"
    
    # Remove duplicate top-level binary file if it exists
    if [ -f "$framework/$FRAMEWORK_NAME" ] && [ ! -L "$framework/$FRAMEWORK_NAME" ]; then
        echo "    🗑️ Removing duplicate binary: $framework/$FRAMEWORK_NAME"
        rm "$framework/$FRAMEWORK_NAME"
    fi
    
    # Move duplicate Resources directory to Versions/A/ if it exists as real directory
    if [ -d "$framework/Resources" ] && [ ! -L "$framework/Resources" ]; then
        echo "    🔄 Moving Resources to Versions/A/"
        if [ -d "$framework/Versions/A" ] && [ ! -d "$framework/Versions/A/Resources" ]; then
            mv "$framework/Resources" "$framework/Versions/A/Resources"
        else
            echo "    🗑️ Removing duplicate Resources (Versions/A/Resources already exists)"
            rm -rf "$framework/Resources"
        fi
    fi
    
    # Ensure Versions/A directory exists and has proper structure
    if [ ! -d "$framework/Versions/A" ]; then
        echo "    ❌ Versions/A directory missing"
        exit 1
    fi
    
    # Create Versions/A/Resources if missing
    if [ ! -d "$framework/Versions/A/Resources" ]; then
        echo "    📁 Creating Versions/A/Resources directory"
        mkdir -p "$framework/Versions/A/Resources"
    fi
    
    # Create Current -> A symlink
    cd "$framework/Versions"
    if [ ! -L "Current" ]; then
        ln -sf A Current
        echo "    🔗 Created Current -> A symlink"
    else
        CURRENT_TARGET=$(readlink Current 2>/dev/null || echo "")
        if [ "$CURRENT_TARGET" != "A" ]; then
            echo "    🔄 Fixing Current symlink (was: $CURRENT_TARGET, should be: A)"
            rm -f Current
            ln -sf A Current
        fi
    fi
    cd - >/dev/null
    
    # Create top-level binary symlink
    cd "$framework"
    if [ ! -L "$FRAMEWORK_NAME" ]; then
        ln -sf Versions/Current/$FRAMEWORK_NAME $FRAMEWORK_NAME
        echo "    🔗 Created $FRAMEWORK_NAME -> Versions/Current/$FRAMEWORK_NAME symlink"
    else
        BINARY_TARGET=$(readlink $FRAMEWORK_NAME 2>/dev/null || echo "")
        if [ "$BINARY_TARGET" != "Versions/Current/$FRAMEWORK_NAME" ]; then
            echo "    🔄 Fixing $FRAMEWORK_NAME symlink (was: $BINARY_TARGET, should be: Versions/Current/$FRAMEWORK_NAME)"
            rm -f $FRAMEWORK_NAME
            ln -sf Versions/Current/$FRAMEWORK_NAME $FRAMEWORK_NAME
        fi
    fi
    
    # Create Resources symlink
    if [ ! -L "Resources" ]; then
        ln -sf Versions/Current/Resources Resources
        echo "    🔗 Created Resources -> Versions/Current/Resources symlink"
    else
        RESOURCES_TARGET=$(readlink Resources 2>/dev/null || echo "")
        if [ "$RESOURCES_TARGET" != "Versions/Current/Resources" ]; then
            echo "    🔄 Fixing Resources symlink (was: $RESOURCES_TARGET, should be: Versions/Current/Resources)"
            rm -f Resources
            ln -sf Versions/Current/Resources Resources
        fi
    fi
    cd - >/dev/null
    
    # Verify final structure
    echo "    ✅ Verifying structure..."
    FRAMEWORK_SIZE=$(du -sh "$framework" | cut -f1)
    echo "      📊 Framework size: $FRAMEWORK_SIZE"
    
    # Check that top-level items are symlinks
    if [ -f "$framework/$FRAMEWORK_NAME" ] && [ ! -L "$framework/$FRAMEWORK_NAME" ]; then
        echo "      ❌ $FRAMEWORK_NAME is still a file (should be symlink)"
    else
        echo "      ✅ $FRAMEWORK_NAME is correctly a symlink"
    fi
    
    if [ -d "$framework/Resources" ] && [ ! -L "$framework/Resources" ]; then
        echo "      ❌ Resources is still a directory (should be symlink)"
    else
        echo "      ✅ Resources is correctly a symlink"
    fi
done

echo "✅ Framework structure fix completed"