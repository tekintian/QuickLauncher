// swift-tools-version:5.3
// Package definition for QuickLauncher with local dependencies

import PackageDescription

let package = Package(
    name: "QuickLauncher",
    platforms: [
        .macOS(.v10_15)
    ],
    dependencies: [
        // 使用本地ShortcutRecorder依赖，避免每次构建时访问远程仓库
        .package(path: "./LocalDependencies/ShortcutRecorder")
    ],
    targets: [
        // 这里定义项目的主要目标
        // 注意：这主要是为了包解析，实际构建使用Xcode项目
    ]
)