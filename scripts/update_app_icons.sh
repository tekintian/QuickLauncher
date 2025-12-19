#!/bin/bash

# ==============================================================================
# QuickLauncher 图标替换工具
# ==============================================================================
# 
# 功能：将指定的图标文件替换到 QuickLauncher 应用的各个位置
# 使用：./scripts/update_app_icons.sh [应用图标路径] [状态栏图标路径]
# 
# 支持的图标尺寸：
# - 应用图标：16x16, 32x32, 128x128, 256x256 (以及对应的 @2x 和 @3x 版本)
# - 状态栏图标：16x16, 32x32, 48x48
# - Logo 图标：256x256
#
# 示例：
#   ./scripts/update_app_icons.sh Resources/app-icon.png Resources/status-icon.png
#   ./scripts/update_app_icons.sh Resources/app-icon.png Resources/status-icon.png
#   ./scripts/update_app_icons.sh /path/to/app-icon.png /path/to/status-icon.png
#   ./scripts/update_app_icons.sh Resources/app-icon.png  # 状态栏图标使用相同文件
#
# 注意：需要安装 macOS 的 sips 工具（系统自带）

set -e  # 遇到错误时退出

# 脚本配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ASSETS_DIR="$PROJECT_ROOT/QuickLauncher/Assets.xcassets"

# 图标路径配置
APPICON_DIR="$ASSETS_DIR/AppIcon.appiconset"
STATUSBAR_DIR="$ASSETS_DIR/StatusBarIcon.imageset"
LOGO_DIR="$ASSETS_DIR/logo.imageset"

# 颜色输出函数
print_info() {
    echo -e "\033[32m[INFO]\033[0m $1"
}

print_warning() {
    echo -e "\033[33m[WARNING]\033[0m $1"
}

print_error() {
    echo -e "\033[31m[ERROR]\033[0m $1"
}

print_header() {
    echo -e "\033[36m================================\033[0m"
    echo -e "\033[36m$1\033[0m"
    echo -e "\033[36m================================\033[0m"
}

# 显示使用说明
show_usage() {
    cat << EOF
QuickLauncher 图标替换工具

使用方法：
    $0 [应用图标路径] [状态栏图标路径]

参数说明：
    应用图标路径    PNG 格式的应用图标文件路径
    状态栏图标路径  PNG 格式的状态栏图标文件路径（可选，默认使用应用图标）

示例：
    $0 Resources/app-icon.png Resources/status-icon.png
    $0 Resources/app-icon.png  # 状态栏图标使用相同文件
    $0 /path/to/app-icon.png /path/to/status-icon.png
    $0 Resources/app-icon.png Resources/app-icon.png  # 使用相同图标

功能说明：
    - 自动生成应用所需的各种尺寸图标
    - 支持分别设置应用图标和状态栏图标
    - Logo 图标使用应用图标源文件
    - 最大支持 512x512 像素（256@2x）
    - 自动备份原图标（可选）

要求：
    - macOS 系统（需要 sips 工具）
    - PNG 格式的图标文件
    - 脚本必须在 QuickLauncher 项目根目录下运行

EOF
}

# 检查参数
if [ $# -eq 0 ]; then
    print_error "缺少应用图标文件路径参数"
    show_usage
    exit 1
fi

APP_SOURCE_ICON="$1"
STATUS_SOURCE_ICON="$2"

# 如果没有提供状态栏图标，则使用应用图标
if [ -z "$STATUS_SOURCE_ICON" ]; then
    STATUS_SOURCE_ICON="$APP_SOURCE_ICON"
    print_warning "未指定状态栏图标，将使用应用图标文件"
fi

# 转换相对路径为绝对路径
if [[ "$APP_SOURCE_ICON" != /* ]]; then
    APP_SOURCE_ICON="$PROJECT_ROOT/$APP_SOURCE_ICON"
fi

if [[ "$STATUS_SOURCE_ICON" != /* ]]; then
    STATUS_SOURCE_ICON="$PROJECT_ROOT/$STATUS_SOURCE_ICON"
fi

# 检查应用图标文件是否存在
if [ ! -f "$APP_SOURCE_ICON" ]; then
    print_error "应用图标文件不存在：$APP_SOURCE_ICON"
    exit 1
fi

# 检查状态栏图标文件是否存在
if [ ! -f "$STATUS_SOURCE_ICON" ]; then
    print_error "状态栏图标文件不存在：$STATUS_SOURCE_ICON"
    exit 1
fi

# 检查文件格式（仅支持 PNG）
if [[ ! "$APP_SOURCE_ICON" =~ \.png$ ]]; then
    print_error "应用图标仅支持 PNG 格式"
    exit 1
fi

if [[ ! "$STATUS_SOURCE_ICON" =~ \.png$ ]]; then
    print_error "状态栏图标仅支持 PNG 格式"
    exit 1
fi

# 检查 sips 工具是否可用
if ! command -v sips &> /dev/null; then
    print_error "sips 工具不可用，请确保在 macOS 系统上运行此脚本"
    exit 1
fi

print_header "QuickLauncher 图标替换工具"
print_info "应用图标源文件：$APP_SOURCE_ICON"
print_info "状态栏图标源文件：$STATUS_SOURCE_ICON"
print_info "项目根目录：$PROJECT_ROOT"

# 确认目录存在
for dir in "$APPICON_DIR" "$STATUSBAR_DIR" "$LOGO_DIR"; do
    if [ ! -d "$dir" ]; then
        print_error "目录不存在：$dir"
        exit 1
    fi
done

# 备份原图标（可选）
backup_old_icons() {
    local backup_dir="$PROJECT_ROOT/icon_backup_$(date +%Y%m%d_%H%M%S)"
    print_warning "正在备份原图标到：$backup_dir"
    
    mkdir -p "$backup_dir"
    
    # 备份应用图标
    if [ -n "$(ls -A "$APPICON_DIR"/*.png 2>/dev/null)" ]; then
        cp "$APPICON_DIR"/*.png "$backup_dir/" 2>/dev/null || true
    fi
    
    # 备份状态栏图标
    if [ -n "$(ls -A "$STATUSBAR_DIR"/*.png 2>/dev/null)" ]; then
        cp "$STATUSBAR_DIR"/*.png "$backup_dir/" 2>/dev/null || true
    fi
    
    # 备份 Logo 图标
    if [ -n "$(ls -A "$LOGO_DIR"/*.png 2>/dev/null)" ]; then
        cp "$LOGO_DIR"/*.png "$backup_dir/" 2>/dev/null || true
    fi
    
    print_info "原图标备份完成"
}

# 生成图标的通用函数
generate_icon() {
    local size=$1
    local output_path=$2
    local description=$3
    local source_file=$4
    
    print_info "生成 $description ($size x $size)"
    
    if sips -z "$size" "$size" "$source_file" --out "$output_path" >/dev/null 2>&1; then
        echo "  ✓ 已生成：$(basename "$output_path")"
    else
        print_error "生成图标失败：$output_path"
        return 1
    fi
}

# 询问是否备份原图标
# echo
# read -p "是否备份当前图标？(y/N): " -n 1 -r
# echo
# if [[ $REPLY =~ ^[Yy]$ ]]; then
#     backup_old_icons
# fi

print_header "开始生成图标"

# 生成应用图标
print_info "生成应用图标..."

# 应用图标列表：文件名 尺寸 描述
declare -a APP_ICON_LIST=(
    "AppIcon-16.png 16 16x16 应用图标"
    "AppIcon-16@2x.png 32 16x16@2x 应用图标"
    "AppIcon-32.png 32 32x32 应用图标"
    "AppIcon-32@2x.png 64 32x32@2x 应用图标"
    "AppIcon-128.png 128 128x128 应用图标"
    "AppIcon-128@2x.png 256 128x128@2x 应用图标"
    "AppIcon-256.png 256 256x256 应用图标"
    "AppIcon-256@2x.png 512 256x256@2x 应用图标 (最大)"
)

for icon_info in "${APP_ICON_LIST[@]}"; do
    read -r filename size description <<< "$icon_info"
    output_path="$APPICON_DIR/$filename"
    generate_icon "$size" "$output_path" "$description" "$APP_SOURCE_ICON"
done

echo

# 生成状态栏图标
print_info "生成状态栏图标..."

# 状态栏图标列表：文件名 尺寸 描述
declare -a STATUS_ICON_LIST=(
    "status_bar_icon.png 16 16x16 状态栏图标"
    "status_bar_icon@2x.png 32 16x16@2x 状态栏图标"
    "status_bar_icon@3x.png 48 16x16@3x 状态栏图标"
)

for icon_info in "${STATUS_ICON_LIST[@]}"; do
    read -r filename size description <<< "$icon_info"
    output_path="$STATUSBAR_DIR/$filename"
    generate_icon "$size" "$output_path" "$description" "$STATUS_SOURCE_ICON"
done

echo

# 生成 Logo 图标（使用应用图标）
print_info "生成 Logo 图标..."

# Logo 图标列表：文件名 尺寸 描述
declare -a LOGO_ICON_LIST=(
    "AppIcon-256.png 256 256x256 Logo 图标"
)

for icon_info in "${LOGO_ICON_LIST[@]}"; do
    read -r filename size description <<< "$icon_info"
    output_path="$LOGO_DIR/$filename"
    generate_icon "$size" "$output_path" "$description" "$APP_SOURCE_ICON"
done

print_header "图标替换完成"

# 显示生成的图标统计
total_app_icons=${#APP_ICON_LIST[@]}
total_status_icons=${#STATUS_ICON_LIST[@]}
total_logo_icons=${#LOGO_ICON_LIST[@]}
total_icons=$((total_app_icons + total_status_icons + total_logo_icons))

print_info "总共生成了 $total_icons 个图标文件"

echo
print_info "应用图标数量：$total_app_icons 个"
print_info "状态栏图标数量：$total_status_icons 个"
print_info "Logo 图标数量：$total_logo_icons 个"

echo
print_info "图标文件已更新到以下位置："
print_info "  应用图标：$APPICON_DIR"
print_info "  状态栏图标：$STATUSBAR_DIR"
print_info "  Logo 图标：$LOGO_DIR"

echo
print_info "现在可以重新编译项目来查看新图标效果"

# 可选：询问是否清理构建缓存
echo
read -p "是否清理 Xcode 构建缓存以强制刷新图标？(y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "清理构建缓存..."
    if command -v xcodebuild &> /dev/null; then
        xcodebuild clean -project "$PROJECT_ROOT/QuickLauncher.xcodeproj" >/dev/null 2>&1 || true
        print_info "构建缓存已清理"
    else
        print_warning "未找到 xcodebuild，请手动清理缓存"
    fi
fi

print_header "脚本执行完成"
print_info "祝您使用愉快！ 🎉"