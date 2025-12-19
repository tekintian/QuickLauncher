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
        .package(url: "https://github.com/ShortCutRecorder/ShortcutRecorder.git", from: "3.4.0")
    ],
    targets: [
        // 这里定义项目的主要目标
        // 注意：这主要是为了包解析，实际构建使用Xcode项目
    ]
)
