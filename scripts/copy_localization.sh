#!/bin/bash

# 脚本：复制本地化文件到构建目录
# 用途：确保Preferences.strings文件被正确复制到应用中

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_DIR/build"

echo "正在复制本地化文件..."

# 获取构建的产品目录
PRODUCT_DIR=$(find "$BUILD_DIR" -name "*.app" -type d | head -n 1)

if [ -z "$PRODUCT_DIR" ]; then
    # 如果在build目录中找不到，尝试在DerivedData中查找
    DERIVED_DATA_DIR="$HOME/Library/Developer/Xcode/DerivedData"
    PRODUCT_DIR=$(find "$DERIVED_DATA_DIR" -name "QuickLauncher.app" -type d | head -n 1)
fi

if [ -z "$PRODUCT_DIR" ]; then
    echo "错误：找不到构建的应用目录"
    exit 1
fi

echo "找到应用目录: $PRODUCT_DIR"

# 复制所有语言的Preferences.strings文件
LANGUAGES=("zh-Hans" "en" "fr" "ru" "it" "es" "de" "ko" "tr")

for lang in "${LANGUAGES[@]}"; do
    SOURCE_FILE="$PROJECT_DIR/QuickLauncher/PreferencesWindow/${lang}.lproj/Preferences.strings"
    TARGET_DIR="$PRODUCT_DIR/Contents/Resources/${lang}.lproj"
    
    echo "检查源文件: $SOURCE_FILE"
    if [ -f "$SOURCE_FILE" ]; then
        echo "复制 $lang 的 Preferences.strings"
        mkdir -p "$TARGET_DIR"
        cp "$SOURCE_FILE" "$TARGET_DIR/"
    else
        echo "警告：找不到 $lang 的 Preferences.strings"
    fi
done

echo "本地化文件复制完成！"