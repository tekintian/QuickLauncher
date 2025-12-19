#!/bin/bash

# QuickLauncher DMG 创建脚本
# 用法: ./scripts/create-simple-dmg.sh <app_path> <dmg_name>

set -e

# 参数检查
if [ $# -ne 2 ]; then
    echo "用法: $0 <应用路径> <DMG文件名>"
    echo "示例: $0 Release/Intel/QuickLauncher.app QuickLauncher-Intel.dmg"
    exit 1
fi

APP_PATH="$1"
DMG_NAME="$2"
DMG_DIR="$(dirname "$DMG_NAME")"
DMG_BASE="$(basename "$DMG_NAME" .dmg)"

echo "🍎 创建 QuickLauncher DMG 安装包"
echo "📦 应用路径: $APP_PATH"
echo "📁 DMG 名称: $DMG_NAME"

# 检查应用是否存在
if [ ! -d "$APP_PATH" ]; then
    echo "❌ 错误: 应用不存在: $APP_PATH"
    exit 1
fi

# 创建临时目录
TEMP_DIR="temp_dmg_$DMG_BASE"
rm -rf "$TEMP_DIR"
mkdir "$TEMP_DIR"

# 复制应用到临时目录
echo "📋 复制应用文件..."
cp -R "$APP_PATH" "$TEMP_DIR/"

# 创建 Applications 文件夹的符号链接（方便用户拖拽）
ln -s /Applications "$TEMP_DIR/Applications"

# 创建 DMG 背景和位置设置
mkdir "$TEMP_DIR/.background"
cat > "$TEMP_DIR/.background/dmg_setup.py" << 'EOF'
try:
    from AppKit import NSScreen, NSColor, NSFont
    from Foundation import NSURL
    from Cocoa import NSWorkspace
    import os
    import sys
except ImportError:
    print("Error: Required modules not available")
    sys.exit(1)

def setup_dmg():
    import os
    import subprocess
    
    # 获取屏幕尺寸来计算窗口大小
    try:
        screen = NSScreen.mainScreen()
        screen_frame = screen.frame()
        screen_width = int(screen_frame.size.width)
        screen_height = int(screen_frame.size.height)
    except:
        screen_width = 1440
        screen_height = 900
    
    # 设置 DMG 窗口大小和位置
    window_width = 600
    window_height = 400
    window_x = (screen_width - window_width) // 2
    window_y = (screen_height - window_height) // 2
    
    # 设置图标位置
    app_x = 150
    app_y = 250
    applications_x = 450
    applications_y = 250
    
    # 设置窗口位置
    script = f'''
    tell application "Finder"
        set theWindow to window of disk "$DMG_BASE"
        set current view of theWindow to icon view
        set toolbar visible of theWindow to false
        set statusbar visible of theWindow to false
        set the bounds of theWindow to {{{window_x}, {window_y}, {window_x + window_width}, {window_y + window_height}}}
        set view of theWindow to container view
        set arrangement of theWindow to not arranged
        
        -- 设置应用图标位置
        set position of item "QuickLauncher.app" of container of theWindow to {{{app_x}, {app_y}}}
        
        -- 设置 Applications 链接位置
        set position of item "Applications" of container of theWindow to {{{applications_x}, {applications_y}}}
        
        close theWindow
        open theWindow
        update theWindow
    end tell
    '''
    
    return script

if __name__ == "__main__":
    script_content = setup_dmg()
    # 将脚本写入临时文件供 AppleScript 执行
    with open('/tmp/dmg_setup.scpt', 'w') as f:
        f.write(script_content)
EOF

# 创建简单的背景说明
cat > "$TEMP_DIR/README.txt" << EOF
QuickLauncher 安装说明

1. 将 QuickLauncher.app 拖拽到 Applications 文件夹
2. 首次运行时，请在系统设置中授予必要权限：
   - Apple Events 权限（用于与 Finder 交互）
   - 辅助功能权限（如需要）

3. 启动后，QuickLauncher 将在状态栏显示图标

更多信息请访问: https://github.com/tekintian/QuickLauncher
EOF

# 创建临时 DMG
echo "🔨 创建临时 DMG..."
TEMP_DMG="temp_$DMG_BASE.dmg"
hdiutil create -srcfolder "$TEMP_DIR" -volname "$DMG_BASE" -fs HFS+ -fsargs "-c c=64,a=16,e=16" -format UDRW "$TEMP_DMG"

# 挂载临时 DMG
echo "📂 挂载临时 DMG..."
DEVICE=$(hdiutil attach -readwrite -noverify -noautoopen "$TEMP_DMG" | egrep '^/dev/' | sed 1q | awk '{print $1}')

# 设置 DMG 外观
echo "🎨 设置 DMG 外观..."
VOLUME_PATH="/Volumes/$DMG_BASE"

# 尝试设置图标位置（使用 AppleScript）
cat > /tmp/setup_dmg.applescript << EOF
tell application "Finder"
    set theWindow to window of disk "$DMG_BASE"
    set current view of theWindow to icon view
    set toolbar visible of theWindow to false
    set statusbar visible of theWindow to false
    set the bounds of theWindow to {400, 300, 1000, 700}
    set view of theWindow to container view
    set arrangement of theWindow to not arranged
    
    -- 设置应用图标位置
    try
        set position of item "QuickLauncher.app" of container of theWindow to {150, 400}
    end try
    
    -- 设置 Applications 链接位置
    try
        set position of item "Applications" of container of theWindow to {450, 400}
    end try
    
    -- 设置背景色为浅灰色
    try
        set background color of theWindow to {65535, 65535, 65535}
    end try
    
    close theWindow
    open theWindow
    update theWindow
end tell
EOF

# 执行 AppleScript 设置
osascript /tmp/setup_dmg.applescript 2>/dev/null || echo "⚠️ DMG 外观设置失败，但 DMG 仍然可用"

# 卸载临时 DMG
echo "💿 卸载临时 DMG..."
hdiutil detach "$DEVICE"

# 转换为压缩 DMG
echo "🗜️ 压缩 DMG..."
hdiutil convert "$TEMP_DMG" -format UDZO -imagekey zlib-level=9 -o "$DMG_NAME"

# 清理临时文件
echo "🧹 清理临时文件..."
rm -f "$TEMP_DMG"
rm -rf "$TEMP_DIR"
rm -f /tmp/setup_dmg.applescript
rm -f /tmp/dmg_setup.scpt

# 显示结果
echo "✅ DMG 创建完成: $DMG_NAME"
echo "📊 文件大小: $(du -h "$DMG_NAME" | cut -f1)"

echo "🎉 QuickLauncher DMG 安装包已准备就绪！"