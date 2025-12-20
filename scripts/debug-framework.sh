#!/bin/bash
# Framework Structure Debug Script
# Shows detailed information about framework structure

set -euo pipefail

if [ $# -ne 1 ]; then
    echo "Usage: $0 <framework_path>"
    echo "Example: $0 CI-Artifacts/QuickLauncher-Intel.app/Contents/Frameworks/QuickLauncherCore.framework"
    exit 1
fi

FRAMEWORK="$1"
FRAMEWORK_NAME=$(basename "$FRAMEWORK" .framework)

echo "🔍 Debugging Framework: $FRAMEWORK_NAME"
echo "=================================="

echo "📁 Complete directory structure:"
find "$FRAMEWORK" -type f -o -type d | sort

echo ""
echo "🔗 Symlink analysis:"

# Check Versions/Current
if [ -L "$FRAMEWORK/Versions/Current" ]; then
    CURRENT_TARGET=$(readlink "$FRAMEWORK/Versions/Current")
    echo "  Versions/Current -> $CURRENT_TARGET"
    
    if [ "$CURRENT_TARGET" = "A" ]; then
        echo "    ✅ Correct target"
    else
        echo "    ❌ Wrong target (should be A)"
    fi
else
    echo "  ❌ Versions/Current is not a symlink or doesn't exist"
fi

# Check top-level binary
if [ -L "$FRAMEWORK/$FRAMEWORK_NAME" ]; then
    BINARY_TARGET=$(readlink "$FRAMEWORK/$FRAMEWORK_NAME")
    echo "  $FRAMEWORK_NAME -> $BINARY_TARGET"
    
    if [ "$BINARY_TARGET" = "Versions/Current/$FRAMEWORK_NAME" ]; then
        echo "    ✅ Correct target"
    else
        echo "    ❌ Wrong target (should be Versions/Current/$FRAMEWORK_NAME)"
    fi
    
    # Check if the target actually exists
    FULL_TARGET="$FRAMEWORK/$BINARY_TARGET"
    if [ -f "$FULL_TARGET" ]; then
        echo "    ✅ Target file exists"
    else
        echo "    ❌ Target file missing: $FULL_TARGET"
    fi
else
    echo "  ❌ $FRAMEWORK_NAME is not a symlink or doesn't exist"
fi

# Check Resources
if [ -L "$FRAMEWORK/Resources" ]; then
    RESOURCES_TARGET=$(readlink "$FRAMEWORK/Resources")
    echo "  Resources -> $RESOURCES_TARGET"
    
    if [ "$RESOURCES_TARGET" = "Versions/Current/Resources" ]; then
        echo "    ✅ Correct target"
    else
        echo "    ❌ Wrong target (should be Versions/Current/Resources)"
    fi
    
    # Check if the target actually exists
    FULL_TARGET="$FRAMEWORK/$RESOURCES_TARGET"
    if [ -d "$FULL_TARGET" ]; then
        echo "    ✅ Target directory exists"
    else
        echo "    ❌ Target directory missing: $FULL_TARGET"
    fi
else
    echo "  ❌ Resources is not a symlink or doesn't exist"
fi

echo ""
echo "📊 File vs symlink breakdown:"

for item in "$FRAMEWORK"/*; do
    item_name=$(basename "$item")
    if [ -L "$item" ]; then
        echo "  🔗 $item_name (symlink -> $(readlink "$item"))"
    elif [ -f "$item" ]; then
        echo "  📄 $item_name (file - should be symlink!)"
    elif [ -d "$item" ]; then
        echo "  📁 $item_name (directory)"
    fi
done

echo ""
echo "💾 Size analysis:"
if [ -d "$FRAMEWORK/Versions/A" ]; then
    VERSION_A_SIZE=$(du -sh "$FRAMEWORK/Versions/A" | cut -f1)
    echo "  Versions/A size: $VERSION_A_SIZE"
fi

if [ -d "$FRAMEWORK/Versions/Current" ]; then
    CURRENT_SIZE=$(du -sh "$FRAMEWORK/Versions/Current" | cut -f1)
    echo "  Versions/Current size: $CURRENT_SIZE"
fi

TOTAL_SIZE=$(du -sh "$FRAMEWORK" | cut -f1)
echo "  Total Framework size: $TOTAL_SIZE"