#!/bin/bash
# Test script to simulate the CI workflow locally

set -euo pipefail

echo "🧪 Testing CI workflow locally..."

# Check if we have a built app to test with
APP_PATH="QuickLauncher-Intel.app"
if [ ! -d "$APP_PATH" ]; then
    echo "❌ No app bundle found at $APP_PATH"
    echo "Please build the app first using: ./build_local.sh"
    exit 1
fi

echo "📁 Using app: $APP_PATH"
APP_SIZE=$(du -sh "$APP_PATH" | cut -f1)
echo "📊 Original app size: $APP_SIZE"

# Clean and create artifacts directory
rm -rf CI-Artifacts
mkdir -p CI-Artifacts

# Step 1: Copy and preserve original build
cp -R "$APP_PATH" "CI-Artifacts/QuickLauncher-Intel-Original.app"
echo "📦 Original app copied"

# Step 2: Create working copy for modifications
cp -R "CI-Artifacts/QuickLauncher-Intel-Original.app" "CI-Artifacts/QuickLauncher-Intel.app"

echo "🔧 Checking Framework structure..."
FRAMEWORKS_DIR="CI-Artifacts/QuickLauncher-Intel.app/Contents/Frameworks/QuickLauncherCore.framework"

if [ ! -d "$FRAMEWORKS_DIR" ]; then
    echo "⚠️ No Frameworks directory found"
    echo "📁 Available contents:"
    ls -la "CI-Artifacts/QuickLauncher-Intel.app/Contents/"
    exit 0
fi

echo "📁 Framework directory exists: $FRAMEWORKS_DIR"
echo "📋 Framework structure check:"
ls -la "$FRAMEWORKS_DIR"

# Check if Versions/Current is a symlink or directory
if [ -L "$FRAMEWORKS_DIR/Versions/Current" ]; then
    echo "  ✅ Versions/Current is already a symlink: $(readlink $FRAMEWORKS_DIR/Versions/Current)"
    echo "  🔧 Framework structure is correct, no changes needed"
elif [ -d "$FRAMEWORKS_DIR/Versions/Current" ]; then
    echo "  ⚠️ Versions/Current is a directory, creating proper symlink structure"
    cd "$FRAMEWORKS_DIR"
    echo "    🔄 Moving Current directory contents to A..."
    if [ ! -d "Versions/A" ]; then
        mv "Versions/Current" "Versions/A"
    else
        # Merge contents if A already exists
        cp -R "Versions/Current/"* "Versions/A/" 2>/dev/null || true
        rm -rf "Versions/Current"
    fi
    echo "    🔗 Creating Current -> A symlink..."
    cd Versions
    ln -sf A Current
    cd ..
    echo "    🔗 Updating top-level symlinks..."
    rm -f QuickLauncherCore Resources 2>/dev/null || true
    ln -sf Versions/A/QuickLauncherCore QuickLauncherCore
    ln -sf Versions/A/Resources Resources
    cd /Users/runner/work/QuickLauncher/QuickLauncher
    echo "  ✅ Symlink structure fixed"
else
    echo "  ❌ Versions/Current missing"
fi

echo "📋 Final Framework structure:"
ls -la "$FRAMEWORKS_DIR"

# Step 3: Package after framework fixes
echo "📦 Creating post-framework-fix package..."
cd CI-Artifacts
tar -cJf "QuickLauncher-Intel-PostFrameworkFix.tar.xz" "QuickLauncher-Intel.app"
echo "  📊 Post-framework-fix package size: $(du -sh "QuickLauncher-Intel-PostFrameworkFix.tar.xz" | cut -f1)"
cd ..

echo "🧹 Running library cleanup script..."
if [ -f "./scripts/clean-libs.sh" ]; then
  chmod +x ./scripts/clean-libs.sh
  ./scripts/clean-libs.sh "CI-Artifacts/QuickLauncher-Intel.app"
  echo "✅ Library cleanup completed"
else
  echo "⚠️ clean-libs.sh script not found"
fi

# Show final app size
APP_SIZE=$(du -sh "CI-Artifacts/QuickLauncher-Intel.app" | cut -f1)
echo "📊 Final app size: $APP_SIZE"

# Step 4: Create final packages
echo "📦 Creating final packages..."
cd CI-Artifacts

# Package original build
tar -cJf "QuickLauncher-Intel-Original.tar.xz" "QuickLauncher-Intel-Original.app"
echo "  📊 Original package size: $(du -sh "QuickLauncher-Intel-Original.tar.xz" | cut -f1)"

# Package final build
tar -cJf "QuickLauncher-Intel-Final.tar.xz" "QuickLauncher-Intel.app"
echo "  📊 Final package size: $(du -sh "QuickLauncher-Intel-Final.tar.xz" | cut -f1)"

# Show all packages
echo "📋 All generated packages:"
ls -lh *.tar.xz

cd ..

echo "🔍 Verifying created packages..."
cd CI-Artifacts

chmod +x ../scripts/verify-artifact.sh

for package in *.tar.xz; do
  echo "📦 Verifying $package..."
  package_name=$(basename "$package" .tar.xz)
  ../scripts/verify-artifact.sh "$package_name"
  echo "---"
done

echo "✅ Local CI workflow test completed"