#!/bin/bash

# 本地构建脚本 - 支持多种签名选项
# 使用方法: 
#   ./build_local.sh          # ad hoc 签名（默认）
#   ./build_local.sh no-sign   # 跳过签名（用于测试）
#   ./build_local.sh sign      # 自动代码签名（需要证书）

set -e

SIGN_MODE=""
SIGN_DESC=""
if [ "$1" = "sign" ]; then
    SIGN_MODE="-allowProvisioningUpdates"
    SIGN_DESC="自动代码签名"
elif [ "$1" = "no-sign" ]; then
    SIGN_MODE="CODE_SIGNING_ALLOWED=NO"
    SIGN_DESC="跳过代码签名"
else
    # 默认使用 ad hoc 签名（修复签名冲突）
    SIGN_MODE='CODE_SIGN_IDENTITY="-" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO DEVELOPMENT_TEAM="" PROVISIONING_PROFILE_SPECIFIER=""'
    SIGN_DESC="ad hoc 签名"
fi

echo "🔧 构建模式：$SIGN_DESC"

echo "🚀 开始本地构建 QuickLauncher（重构版本）..."

# 获取项目根目录
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "📂 项目目录: $PROJECT_DIR"

# 使用本地ShortcutRecorder依赖
echo "📦 使用本地ShortcutRecorder依赖（相对路径配置）..."

# 清理构建目录
echo "🧹 清理构建目录..."
rm -rf build/

# 开始构建
echo "📦 开始构建..."
xcodebuild -project QuickLauncher.xcodeproj \
           -scheme QuickLauncher \
           -configuration Release \
           -derivedDataPath build \
           $SIGN_MODE \
           ENABLE_BITCODE=NO \
           DEAD_CODE_STRIPPING=YES \
           STRIP_INSTALLED_PRODUCT=YES \
           COPY_PHASE_STRIP=YES \
           ONLY_ACTIVE_ARCH=YES \
           COMPRESS_PNG_RESOURCES=YES \
           build

# 清理调试符号
echo "🗑️ 清理调试符号..."
find build/Build/Products -name "*.dSYM" -exec rm -rf {} \; 2>/dev/null || true

# 移除未使用的Swift库
echo "🔧 移除未使用的Swift库..."
APP_PATH="build/Build/Products/Release/QuickLauncher.app"
UNUSED_LIBS=(
    "libswiftCloudKit.dylib"
    "libswiftCoreLocation.dylib" 
    "libswiftCoreData.dylib"
    "libswiftMetal.dylib"
    "libswiftCoreImage.dylib"
    "libswiftIOKit.dylib"
    "libswiftQuartzCore.dylib"
)

for lib in "${UNUSED_LIBS[@]}"; do
    if [ -f "$APP_PATH/Contents/Frameworks/$lib" ]; then
        echo "  移除: $lib"
        rm "$APP_PATH/Contents/Frameworks/$lib"
    fi
done

# 复制本地化文件
echo "🌍 复制本地化文件..."
if [ -f "$PROJECT_DIR/scripts/copy_localization.sh" ]; then
    "$PROJECT_DIR/scripts/copy_localization.sh"
else
    echo "⚠️  警告：找不到本地化复制脚本"
fi

# 创建分发包
echo "📦 创建分发包..."
mkdir -p dist
cp -R "$APP_PATH" dist/

# QuickLauncherHelper has been removed - no longer need to copy

# 显示结果
echo ""
echo "✅ 构建完成！"
echo "📊 构建结果："

if [ -f "$APP_PATH" ]; then
    FINAL_SIZE=$(du -sh "$APP_PATH" | cut -f1)
    echo "  QuickLauncher.app: $FINAL_SIZE"
fi

# QuickLauncherHelper has been removed - no size reporting needed

DIST_SIZE=$(du -sh dist | cut -f1)
echo "  分发包总大小: $DIST_SIZE"

echo ""
echo "🎉 构建成功！已使用本地ShortcutRecorder依赖，无需网络访问。"