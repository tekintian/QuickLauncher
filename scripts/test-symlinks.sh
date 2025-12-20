#!/bin/bash
# Test script to verify symlink handling logic

echo "🧪 Testing symlink handling logic..."

# Create test structure
TEST_DIR="/tmp/framework_test"
rm -rf "$TEST_DIR"
mkdir -p "$TEST_DIR/Versions/Current/Resources"
mkdir -p "$TEST_DIR/Versions/Current"
echo "test binary" > "$TEST_DIR/Versions/Current/QuickLauncherCore"

echo "📁 Initial structure:"
ls -la "$TEST_DIR"

# Simulate CI logic
cd "$TEST_DIR"

echo "🔄 Testing directory->symlink conversion..."
if [ -d "Versions/Current" ]; then
    echo "  Moving Current to A..."
    mv "Versions/Current" "Versions/A"
    echo "  Creating Current -> A symlink..."
    cd Versions
    ln -sf A Current
    cd ..
    echo "  Creating top-level symlinks..."
    ln -sf Versions/A/QuickLauncherCore QuickLauncherCore
    ln -sf Versions/A/Resources Resources
fi

echo "📁 Final structure:"
ls -la "$TEST_DIR"

echo "🔍 Verification:"
echo "  QuickLauncherCore: $(readlink QuickLauncherCore)"
echo "  Resources: $(readlink Resources)"  
echo "  Versions/Current: $(readlink Versions/Current)"

# Clean up
rm -rf "$TEST_DIR"
echo "✅ Test completed"