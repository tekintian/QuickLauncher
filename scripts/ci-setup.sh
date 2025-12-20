#!/bin/bash
# QuickLauncher CI Setup Script
# Handles dependency configuration for CI environments

set -euo pipefail

echo "🔧 Configuring QuickLauncher for CI build..."

# Only modify dependencies in CI environment
if [[ "${CI:-}" != "true" ]]; then
    echo "⚠️ This script should only run in CI environment"
    exit 1
fi

# Configure remote dependencies for CI
if [ -f "QuickLauncher.xcodeproj/project.pbxproj" ]; then
    echo "📦 Switching to remote dependencies..."
    sed -i '' 's|file://./LocalDependencies/ShortcutRecorder|https://github.com/tekintian/ShortcutRecorder.git|g' QuickLauncher.xcodeproj/project.pbxproj
    echo "✅ Dependencies configured for CI"
else
    echo "❌ Xcode project file not found"
    exit 1
fi

echo "🎉 CI setup completed"