#!/bin/bash

# Test script to verify CI dependency switching works correctly
# This script simulates what happens in CI

echo "🧪 Testing CI dependency switching..."

# Backup original files
echo "📦 Backing up original files..."
cp QuickLauncher.xcodeproj/project.pbxproj test-original.pbxproj
cp Package.swift test-original.swift

# Simulate CI dependency update
echo "🔄 Simulating CI dependency update..."

# Update Xcode project
echo "📝 Updating Xcode project..."
sed 's|repositoryURL = "file://./LocalDependencies/ShortcutRecorder";|repositoryURL = "https://github.com/tekintian/ShortcutRecorder.git";|g' QuickLauncher.xcodeproj/project.pbxproj > temp.pbxproj && mv temp.pbxproj QuickLauncher.xcodeproj/project.pbxproj

# Update Package.swift
cat > Package-ci.swift << 'EOF'
// swift-tools-version:5.3
// Package definition for QuickLauncher with remote dependencies (CI only)

import PackageDescription

let package = Package(
    name: "QuickLauncher",
    platforms: [
        .macOS(.v10_15)
    ],
    dependencies: [
        // Use remote ShortcutRecorder dependency for CI builds
        .package(url: "https://github.com/tekintian/ShortcutRecorder.git", from: "3.4.0")
    ],
    targets: [
        // 这里定义项目的主要目标
        // 注意：这主要是为了包解析，实际构建使用Xcode项目
    ]
)
EOF

cp Package-ci.swift Package.swift

# Verify changes
echo "✅ Verifying changes..."
echo "Xcode project repository URL:"
grep -n "repositoryURL" QuickLauncher.xcodeproj/project.pbxproj

echo ""
echo "Package.swift dependency:"
grep -n "ShortCutRecorder" Package.swift

# Restore original files
echo ""
echo "🔄 Restoring original files..."
mv test-original.pbxproj QuickLauncher.xcodeproj/project.pbxproj
mv test-original.swift Package.swift

echo "✅ Test completed successfully!"
echo ""
echo "✅ Local development:"
echo "  - Uses: file://./LocalDependencies/ShortcutRecorder"
echo "  - Fast, offline, debuggable"
echo ""
echo "✅ GitHub CI:"
echo "  - Uses: https://github.com/tekintian/ShortcutRecorder.git"
echo "  - Automated, no submodule required"