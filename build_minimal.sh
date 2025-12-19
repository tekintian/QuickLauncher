#!/bin/bash

# 最小构建脚本 - 基本功能测试
# 专注于基本编译验证

set -e

echo "🚀 开始最小构建..."

# 检查项目文件是否可读
if [ ! -f "QuickLauncher.xcodeproj/project.pbxproj" ]; then
    echo "❌ 项目文件不存在"
    exit 1
fi

# 先只尝试构建框架（核心依赖）
echo "📦 构建 QuickLauncherCore 框架（ad hoc 签名）..."
xcodebuild -project QuickLauncher.xcodeproj \
           -target QuickLauncherCore \
           -configuration Release \
           CODE_SIGN_IDENTITY="-" \
           CODE_SIGNING_REQUIRED=NO \
           CODE_SIGNING_ALLOWED=YES \
           ONLY_ACTIVE_ARCH=NO

if [ $? -eq 0 ]; then
    echo "✅ 核心框架构建成功"
else
    echo "❌ 核心框架构建失败"
    exit 1
fi

# 尝试构建主应用
echo "📦 构建 QuickLauncher 主应用（ad hoc 签名）..."
xcodebuild -project QuickLauncher.xcodeproj \
           -target QuickLauncher \
           -configuration Release \
           CODE_SIGN_IDENTITY="-" \
           CODE_SIGNING_REQUIRED=NO \
           CODE_SIGNING_ALLOWED=YES \
           ONLY_ACTIVE_ARCH=NO

if [ $? -eq 0 ]; then
    echo "✅ 主应用构建成功"
    echo "📁 构建产物位置: build/app/Build/Products/Release"
else
    echo "❌ 主应用构建失败"
    echo "📝 这可能是由于项目文件中仍有已删除组件的引用"
    echo "💡 建议在 Xcode 中打开项目，检查并删除 QuickLauncherHelper 相关的引用"
    exit 1
fi

echo "🎉 最小构建完成！"