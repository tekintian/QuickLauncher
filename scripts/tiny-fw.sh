#!/bin/bash
# QuickLauncher Framework Structure Fix Script
# Ensures proper Framework structure with symlinks instead of duplicate files

set -euo pipefail

set -euo pipefail

if [ $# -ne 1 ]; then
    echo "Usage: $0 <app_bundle_path>"
    echo "Example: $0 CI-Artifacts/QuickLauncher-Intel.app"
    exit 1
fi

APP_BUNDLE="$1"
FRAMEWORKS_DIR="$APP_BUNDLE/Contents/Frameworks/QuickLauncherCore.framework"

echo "🔧 Fixing Framework structure in $APP_BUNDLE..."

if [ ! -d "$FRAMEWORKS_DIR" ]; then
    echo "⚠️ No Frameworks directory found"
    exit 0
fi

cd "$FRAMEWORKS_DIR"
echo "  🗑️ Removing top-level duplicate files/directories..."
rm -rf Resources
rm -rf QuickLauncherCore
rm -rf Versions/Current
echo "  🔗 Creating symlinks..."
ln -sf Versions/A/QuickLauncherCore QuickLauncherCore
ln -sf Versions/A/Resources Resources
cd Versions
ln -sf A Current
echo "  ✅ Symlinks created."

cd $APP_BUNDLE
cd ../

echo "✅ Framework structure fix completed"
