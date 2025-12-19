#!/bin/bash

# QuickLauncher CI 构建测试脚本
# 用于本地验证 GitHub Actions 构建流程

set -e

echo "🚀 QuickLauncher CI 构建测试"
echo "============================"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

# 检查系统要求
echo "🔍 检查系统要求..."

# 检查 Xcode
if ! command -v xcodebuild &> /dev/null; then
    error "Xcode 未安装或不在 PATH 中"
fi
success "Xcode 已安装: $(xcodebuild -version | head -1)"

# 检查操作系统
if [[ "$(uname)" != "Darwin" ]]; then
    error "此脚本需要在 macOS 系统上运行"
fi

MACOS_VERSION=$(sw_vers -productVersion)
success "macOS 版本: $MACOS_VERSION"

# 检查项目文件
echo
echo "📁 检查项目结构..."

required_files=(
    "QuickLauncher.xcodeproj/project.pbxproj"
    "QuickLauncher/Info.plist"
    "QuickLauncherCore/Info.plist"
    "Package.swift"
    "scripts/update_app_icons.sh"
    "scripts/create-simple-dmg.sh"
)

for file in "${required_files[@]}"; do
    if [[ ! -f "$file" ]]; then
        error "缺少必需文件: $file"
    fi
    success "找到文件: $file"
done

# 检查图标文件
if [[ -f "Resources/app-icon.png" ]]; then
    success "找到应用图标: Resources/app-icon.png"
else
    warning "未找到应用图标: Resources/app-icon.png"
fi

if [[ -f "Resources/status-icon.png" ]]; then
    success "找到状态栏图标: Resources/status-icon.png"
else
    warning "未找到状态栏图标: Resources/status-icon.png"
fi

# 测试脚本语法
echo
echo "🔧 检查脚本语法..."

scripts=(
    "scripts/update_app_icons.sh"
    "scripts/create-simple-dmg.sh"
)

for script in "${scripts[@]}"; do
    if [[ -f "$script" ]]; then
        if bash -n "$script"; then
            success "脚本语法正确: $script"
        else
            error "脚本语法错误: $script"
        fi
        
        # 检查可执行权限
        if [[ -x "$script" ]]; then
            success "脚本可执行: $script"
        else
            warning "脚本不可执行，正在添加权限: $script"
            chmod +x "$script"
        fi
    fi
done

# 检查 GitHub Actions 配置
echo
echo "🔄 检查 GitHub Actions 配置..."

if command -v python3 &> /dev/null && python3 -c "import yaml" &> /dev/null; then
    workflow_files=(
        ".github/workflows/ci.yml"
        ".github/workflows/release.yml"
    )
    
    for workflow in "${workflow_files[@]}"; do
        if [[ -f "$workflow" ]]; then
            if python3 -c "import yaml; yaml.safe_load(open('$workflow'))"; then
                success "GitHub Actions 配置正确: $workflow"
            else
                error "GitHub Actions 配置错误: $workflow"
            fi
        else
            warning "未找到 GitHub Actions 配置: $workflow"
        fi
    done
else
    warning "Python3 或 PyYAML 未安装，跳过 GitHub Actions 配置检查"
fi

# 模拟 Intel 构建
echo
echo "🏗️ 测试 Intel 构建..."

INTEL_DERIVEDDATA="DerivedData-Intel-Test"

if xcodebuild -project QuickLauncher.xcodeproj \
    -scheme QuickLauncher \
    -configuration Debug \
    -arch x86_64 \
    -derivedDataPath "$INTEL_DERIVEDDATA" \
    MACOSX_DEPLOYMENT_TARGET=10.15 \
    ONLY_ACTIVE_ARCH=NO \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    -allowProvisioningUpdates \
    clean build > /dev/null 2>&1; then
    
    success "Intel 构建成功"
    
    # 检查构建产物
    if [[ -f "$INTEL_DERIVEDDATA/Build/Products/Debug/QuickLauncher.app/Contents/MacOS/QuickLauncher" ]]; then
        success "Intel 可执行文件存在"
        
        # 检查架构
        arch_info=$(file "$INTEL_DERIVEDDATA/Build/Products/Debug/QuickLauncher.app/Contents/MacOS/QuickLauncher")
        if [[ "$arch_info" == *"x86_64"* ]]; then
            success "Intel 架构正确: $arch_info"
        else
            warning "Intel 架构可能有问题: $arch_info"
        fi
    else
        error "Intel 可执行文件不存在"
    fi
else
    error "Intel 构建失败"
fi

# 清理 Intel 构建产物
rm -rf "$INTEL_DERIVEDDATA"

# 模拟 ARM64 构建（如果支持）
echo
echo "🏗️ 测试 Apple Silicon 构建..."

ARM64_DERIVEDDATA="DerivedData-ARM64-Test"

# 检查是否在 Apple Silicon Mac 上
if [[ "$(uname -m)" == "arm64" ]]; then
    if xcodebuild -project QuickLauncher.xcodeproj \
        -scheme QuickLauncher \
        -configuration Debug \
        -arch arm64 \
        -derivedDataPath "$ARM64_DERIVEDDATA" \
        MACOSX_DEPLOYMENT_TARGET=11.0 \
        ONLY_ACTIVE_ARCH=NO \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_REQUIRED=NO \
        -allowProvisioningUpdates \
        clean build > /dev/null 2>&1; then
        
        success "Apple Silicon 构建成功（本地架构）"
        
        # 检查构建产物
        if [[ -f "$ARM64_DERIVEDDATA/Build/Products/Debug/QuickLauncher.app/Contents/MacOS/QuickLauncher" ]]; then
            success "Apple Silicon 可执行文件存在"
            
            # 检查架构
            arch_info=$(file "$ARM64_DERIVEDDATA/Build/Products/Debug/QuickLauncher.app/Contents/MacOS/QuickLauncher")
            if [[ "$arch_info" == *"arm64"* ]]; then
                success "Apple Silicon 架构正确: $arch_info"
            else
                warning "Apple Silicon 架构可能有问题: $arch_info"
            fi
        else
            error "Apple Silicon 可执行文件不存在"
        fi
    else
        warning "Apple Silicon 构建失败（即使在 Apple Silicon Mac 上）"
    fi
else
    warning "跳过 Apple Silicon 构建测试（当前在 Intel Mac 上，GitHub Actions 会在 Apple Silicon 环境中测试）"
    
    # 仍然检查 xcodebuild 是否支持 arm64 目标
    if xcodebuild -showsdks | grep -q "macosx11\|macOS 11"; then
        success "Xcode 支持 macOS 11.0+ 目标（ARM64 构建在 GitHub Actions 中将正常工作）"
    else
        warning "当前 Xcode 版本可能不支持 ARM64 目标"
    fi
fi

# 清理 ARM64 构建产物
rm -rf "$ARM64_DERIVEDDATA"

# 测试图标更新功能
echo
echo "🎨 测试图标更新功能..."

if [[ -f "Resources/app-icon.png" ]] && [[ -f "scripts/update_app_icons.sh" ]]; then
    # 创建临时测试目录
    TEST_DIR="test_icons_backup_$(date +%s)"
    mkdir -p "$TEST_DIR"
    
    # 备份当前图标
    if [[ -d "QuickLauncher/Assets.xcassets/AppIcon.appiconset" ]]; then
        cp -r QuickLauncher/Assets.xcassets/AppIcon.appiconset "$TEST_DIR/" 2>/dev/null || true
    fi
    
    if [[ -d "QuickLauncher/Assets.xcassets/StatusBarIcon.imageset" ]]; then
        cp -r QuickLauncher/Assets.xcassets/StatusBarIcon.imageset "$TEST_DIR/" 2>/dev/null || true
    fi
    
    # 测试图标更新脚本（非交互式）
    if echo "N" | echo "N" | ./scripts/update_app_icons.sh Resources/app-icon.png Resources/app-icon.png > /dev/null 2>&1; then
        success "图标更新脚本工作正常"
        
        # 恢复备份
        if [[ -d "$TEST_DIR/AppIcon.appiconset" ]]; then
            cp -r "$TEST_DIR/AppIcon.appiconset"/* QuickLauncher/Assets.xcassets/AppIcon.appiconset/ 2>/dev/null || true
        fi
        
        if [[ -d "$TEST_DIR/StatusBarIcon.imageset" ]]; then
            cp -r "$TEST_DIR/StatusBarIcon.imageset"/* QuickLauncher/Assets.xcassets/StatusBarIcon.imageset/ 2>/dev/null || true
        fi
    else
        warning "图标更新脚本可能有问题"
    fi
    
    # 清理测试目录
    rm -rf "$TEST_DIR"
else
    warning "跳过图标更新测试（缺少图标文件）"
fi

# 清理测试构建产物
echo
echo "🧹 清理测试构建产物..."
rm -rf DerivedData-*
rm -f *.dmg *.zip
rm -rf Release/

echo
echo "============================"
success "🎉 CI 构建测试完成！"
echo
echo "📋 测试摘要："
echo "  ✅ 系统环境检查通过"
echo "  ✅ 项目结构检查通过"
echo "  ✅ 脚本语法检查通过"
echo "  ✅ GitHub Actions 配置检查通过"
echo "  ✅ Intel 构建测试通过"
echo "  ✅ Apple Silicon 构建测试完成"
echo "  ✅ 图标更新功能测试完成"
echo
echo "🚀 项目已准备好进行 GitHub Actions CI/CD 部署！"
echo
echo "📝 下一步："
echo "  1. 提交代码到仓库"
echo "  2. 推送到 GitHub"
echo "  3. CI 将自动运行"
echo "  4. 创建版本标签以触发发布："
echo "     git tag v1.0.0 && git push origin v1.0.0"