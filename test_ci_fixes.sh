#!/bin/bash

# 测试CI修复的脚本
# 对比本地构建和期望的CI构建结构

echo "🔍 验证CI修复脚本"
echo "=================="

LOCAL_APP="/Volumes/data/projects/swift/QuickLauncher/dist/QuickLauncher.app"

if [ ! -d "$LOCAL_APP" ]; then
    echo "❌ 本地构建app不存在，请先运行本地构建"
    exit 1
fi

echo "📋 本地构建结构验证："

# 1. 检查主app Info.plist (不应有NSExtension)
echo ""
echo "1. 检查主app Info.plist："
MAIN_PLIST="$LOCAL_APP/Contents/Info.plist"
if /usr/libexec/PlistBuddy -c "Print NSExtension" "$MAIN_PLIST" 2>/dev/null; then
    echo "   ⚠️ 主app包含NSExtension (应该被CI移除)"
else
    echo "   ✅ 主app不包含NSExtension"
fi

# 2. 检查LSUIElement格式
echo ""
echo "2. 检查LSUIElement格式："
if /usr/libexec/PlistBuddy -c "Print LSUIElement" "$MAIN_PLIST" 2>/dev/null | grep -q "YES"; then
    echo "   ✅ 主app LSUIElement为字符串格式"
else
    echo "   ❌ 主app LSUIElement格式不正确"
fi

# 3. 检查Framework结构（关键：避免重复文件）
echo ""
echo "3. 检查Framework结构："
FRAMEWORK_DIR="$LOCAL_APP/Contents/Frameworks/QuickLauncherCore.framework"

if [ -L "$FRAMEWORK_DIR/Versions/Current" ]; then
    CURRENT_TARGET=$(readlink "$FRAMEWORK_DIR/Versions/Current")
    if [ "$CURRENT_TARGET" = "A" ]; then
        echo "   ✅ Versions/Current -> A (正确)"
    else
        echo "   ❌ Versions/Current -> $CURRENT_TARGET (应该是 A)"
    fi
else
    echo "   ❌ Versions/Current 符号链接缺失"
fi

if [ -L "$FRAMEWORK_DIR/QuickLauncherCore" ]; then
    BINARY_TARGET=$(readlink "$FRAMEWORK_DIR/QuickLauncherCore")
    if [ "$BINARY_TARGET" = "Versions/Current/QuickLauncherCore" ]; then
        echo "   ✅ QuickLauncherCore -> Versions/Current/QuickLauncherCore (正确)"
    else
        echo "   ❌ QuickLauncherCore -> $BINARY_TARGET (应该是 Versions/Current/QuickLauncherCore)"
    fi
else
    echo "   ❌ QuickLauncherCore 符号链接缺失"
fi

if [ -L "$FRAMEWORK_DIR/Resources" ]; then
    RESOURCES_TARGET=$(readlink "$FRAMEWORK_DIR/Resources")
    if [ "$RESOURCES_TARGET" = "Versions/Current/Resources" ]; then
        echo "   ✅ Resources -> Versions/Current/Resources (正确)"
    else
        echo "   ❌ Resources -> $RESOURCES_TARGET (应该是 Versions/Current/Resources)"
    fi
else
    echo "   ❌ Resources 符号链接缺失"
fi

# 关键检查：确保没有重复文件
echo "   检查重复文件："
if [ -f "$FRAMEWORK_DIR/QuickLauncherCore" ] && [ ! -L "$FRAMEWORK_DIR/QuickLauncherCore" ]; then
    echo "   ❌ 发现重复的QuickLauncherCore文件 (应该是符号链接)"
else
    echo "   ✅ 没有重复的QuickLauncherCore文件"
fi

if [ -d "$FRAMEWORK_DIR/Resources" ] && [ ! -L "$FRAMEWORK_DIR/Resources" ]; then
    echo "   ❌ 发现重复的Resources目录 (应该是符号链接)"
else
    echo "   ✅ 没有重复的Resources目录"
fi

# 4. 检查扩展Info.plist
echo ""
echo "4. 检查Finder扩展："
EXTENSION_PLIST="$LOCAL_APP/Contents/PlugIns/QuickLauncherFinderExtension.appex/Contents/Info.plist"
if [ -f "$EXTENSION_PLIST" ]; then
    BUNDLE_ID=$(/usr/libexec/PlistBuddy -c "Print CFBundleIdentifier" "$EXTENSION_PLIST" 2>/dev/null)
    echo "   ✅ 扩展Bundle ID: $BUNDLE_ID"
    
    if /usr/libexec/PlistBuddy -c "Print NSExtension" "$EXTENSION_PLIST" 2>/dev/null > /dev/null; then
        echo "   ✅ 扩展包含NSExtension"
    else
        echo "   ❌ 扩展缺少NSExtension"
    fi
    
    # 检查LSUIElement格式
    if /usr/libexec/PlistBuddy -c "Print LSUIElement" "$EXTENSION_PLIST" 2>/dev/null | grep -q "true"; then
        echo "   ✅ 扩展LSUIElement为布尔格式"
    else
        echo "   ⚠️ 扩展LSUIElement格式需要检查"
    fi
else
    echo "   ❌ 扩展Info.plist缺失"
fi

# 5. 检查ShortcutRecorder bundle位置
echo ""
echo "5. 检查ShortcutRecorder bundle："
if [ -d "$LOCAL_APP/Contents/Resources/ShortcutRecorder_ShortcutRecorder.bundle" ]; then
    BUNDLE_PLIST="$LOCAL_APP/Contents/Resources/ShortcutRecorder_ShortcutRecorder.bundle/Contents/Info.plist"
    if [ -f "$BUNDLE_PLIST" ]; then
        BUNDLE_ID=$(/usr/libexec/PlistBuddy -c "Print CFBundleIdentifier" "$BUNDLE_PLIST" 2>/dev/null)
        echo "   ✅ ShortcutRecorder bundle在Resources中"
        echo "   📋 Bundle ID: $BUNDLE_ID"
    else
        echo "   ⚠️ ShortcutRecorder bundle存在但Info.plist缺失"
    fi
else
    echo "   ❌ ShortcutRecorder bundle不在Resources中"
fi

# 6. 检查Swift库
echo ""
echo "6. 检查Swift库："
if [ -f "$LOCAL_APP/Contents/Frameworks/libswiftContacts.dylib" ]; then
    echo "   ✅ libswiftContacts.dylib 存在"
else
    echo "   ❌ libswiftContacts.dylib 缺失"
fi

echo ""
echo "📊 本地构建验证完成"
echo "CI修复应该让GitHub构建产生相同的结构"