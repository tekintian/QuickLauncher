// swift-tools-version:5.3
// Package definition for QuickLauncher with local dependencies

import PackageDescription

let package = Package(
    name: "QuickLauncher",
    platforms: [
        .macOS(.v10_13)
    ],
    dependencies: [
        // ShortcutRecorder dependency - local path for development, 
        // automatically switches to remote URL in CI via ci-setup.sh
        .package(path: "./LocalDependencies/ShortcutRecorder")
    ],
    targets: [
        // 这里定义项目的主要目标
        // 注意：这主要是为了包解析，实际构建使用Xcode项目
    ]
)