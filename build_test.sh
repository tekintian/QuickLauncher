#!/bin/bash

# 测试构建脚本 - 使用 ad hoc 签名，验证编译
# 用于测试本地依赖是否工作正常

set -e

echo "🧪 开始测试构建（ad hoc 签名）..."

# 获取项目根目录
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 确保使用本地依赖（使用相对路径）
if ! grep -q 'file://./LocalDependencies/ShortcutRecorder' QuickLauncher.xcodeproj/project.pbxproj; then
    echo "⚠️  本地依赖路径未配置，正在设置..."
    sed -i '' 's|repositoryURL = ".*ShortcutRecorder.*"|repositoryURL = "file://./LocalDependencies/ShortcutRecorder"|g' QuickLauncher.xcodeproj/project.pbxproj
fi

# 验证本地依赖存在
if [ ! -d "$PROJECT_DIR/LocalDependencies/ShortcutRecorder" ]; then
    echo "❌ 本地ShortcutRecorder依赖不存在"
    exit 1
fi

# 清理构建目录
echo "🧹 清理构建目录..."
rm -rf build/

# 测试构建（ad hoc 签名）
echo "🔨 开始构建（ad hoc 签名）..."
xcodebuild -project QuickLauncher.xcodeproj \
           -scheme QuickLauncher \
           -configuration Debug \
           -derivedDataPath build \
           CODE_SIGN_IDENTITY="-" \
           CODE_SIGNING_REQUIRED=NO \
           CODE_SIGNING_ALLOWED=YES \
           ENABLE_BITCODE=NO \
           DEAD_CODE_STRIPPING=YES \
           build

echo ""
echo "✅ 测试构建成功！"
echo "📊 构建产物位于: build/Build/Products/Debug/"
echo ""
echo "🎯 验证本地ShortcutRecorder依赖工作正常，无需网络访问！"
echo "🔐 使用 ad hoc 签名，可在本地运行"