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

# Process each framework using a for loop to avoid subshell issues
for framework in "$FRAMEWORKS_DIR"/*.framework; do
    # Skip if no frameworks found
    [ -d "$framework" ] || continue
    
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
    
    # Create Current -> A symlink (remove directory if it exists)
    CURRENT_LINK="$framework/Versions/Current"
    if [ ! -L "$CURRENT_LINK" ]; then
        # Remove if it exists as directory or broken link
        if [ -e "$CURRENT_LINK" ] || [ -L "$CURRENT_LINK" ]; then
            rm -rf "$CURRENT_LINK"
        fi
        ln -sf A "$CURRENT_LINK"
        echo "    🔗 Created Current -> A symlink"
    else
        CURRENT_TARGET=$(readlink "$CURRENT_LINK" 2>/dev/null || echo "")
        if [ "$CURRENT_TARGET" != "A" ]; then
            echo "    🔄 Fixing Current symlink (was: $CURRENT_TARGET, should be: A)"
            rm -f "$CURRENT_LINK"
            ln -sf A "$CURRENT_LINK"
        fi
    fi
    
    # Create top-level binary symlink
    BINARY_LINK="$framework/$FRAMEWORK_NAME"
    if [ ! -L "$BINARY_LINK" ]; then
        ln -sf "Versions/A/$FRAMEWORK_NAME" "$BINARY_LINK"
        echo "    🔗 Created $FRAMEWORK_NAME -> Versions/A/$FRAMEWORK_NAME symlink"
    else
        BINARY_TARGET=$(readlink "$BINARY_LINK" 2>/dev/null || echo "")
        if [ "$BINARY_TARGET" != "Versions/A/$FRAMEWORK_NAME" ]; then
            echo "    🔄 Fixing $FRAMEWORK_NAME symlink (was: $BINARY_TARGET, should be: Versions/A/$FRAMEWORK_NAME)"
            rm -f "$BINARY_LINK"
            ln -sf "Versions/A/$FRAMEWORK_NAME" "$BINARY_LINK"
        fi
    fi
    
    # Create Resources symlink
    RESOURCES_LINK="$framework/Resources"
    if [ ! -L "$RESOURCES_LINK" ]; then
        ln -sf "Versions/A/Resources" "$RESOURCES_LINK"
        echo "    🔗 Created Resources -> Versions/A/Resources symlink"
    else
        RESOURCES_TARGET=$(readlink "$RESOURCES_LINK" 2>/dev/null || echo "")
        if [ "$RESOURCES_TARGET" != "Versions/A/Resources" ]; then
            echo "    🔄 Fixing Resources symlink (was: $RESOURCES_TARGET, should be: Versions/A/Resources)"
            rm -f "$RESOURCES_LINK"
            ln -sf "Versions/A/Resources" "$RESOURCES_LINK"
        fi
    fi
    
    # Verify final structure
    echo "    ✅ Verifying structure..."
    FRAMEWORK_SIZE=$(du -sh "$framework" | cut -f1)
    echo "      📊 Framework size: $FRAMEWORK_SIZE"
    
    # Check that top-level items are symlinks and verify their targets
    if [ -L "$BINARY_LINK" ]; then
        BINARY_TARGET=$(readlink "$BINARY_LINK" 2>/dev/null || echo "")
        if [ "$BINARY_TARGET" = "Versions/A/$FRAMEWORK_NAME" ]; then
            echo "      ✅ $FRAMEWORK_NAME symlink is correct: $BINARY_TARGET"
        else
            echo "      ❌ $FRAMEWORK_NAME symlink is wrong: $BINARY_TARGET"
        fi
    elif [ -f "$BINARY_LINK" ]; then
        echo "      ❌ $FRAMEWORK_NAME is still a file (should be symlink)"
    else
        echo "      ❌ $FRAMEWORK_NAME link missing"
    fi
    
    if [ -L "$RESOURCES_LINK" ]; then
        RESOURCES_TARGET=$(readlink "$RESOURCES_LINK" 2>/dev/null || echo "")
        if [ "$RESOURCES_TARGET" = "Versions/A/Resources" ]; then
            echo "      ✅ Resources symlink is correct: $RESOURCES_TARGET"
        else
            echo "      ❌ Resources symlink is wrong: $RESOURCES_TARGET"
        fi
    elif [ -d "$RESOURCES_LINK" ]; then
        echo "      ❌ Resources is still a directory (should be symlink)"
    else
        echo "      ❌ Resources link missing"
    fi
    
    if [ -L "$CURRENT_LINK" ]; then
        CURRENT_TARGET=$(readlink "$CURRENT_LINK" 2>/dev/null || echo "")
        if [ "$CURRENT_TARGET" = "A" ]; then
            echo "      ✅ Current symlink is correct: $CURRENT_TARGET"
        else
            echo "      ❌ Current symlink is wrong: $CURRENT_TARGET"
        fi
    else
        echo "      ❌ Current symlink missing"
    fi
    
    echo "      📁 Framework structure:"
    ls -la "$framework" | head -10
done

echo "✅ Framework structure fix completed"