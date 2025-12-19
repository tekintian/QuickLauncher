#!/bin/bash

# 脚本：移除远程SPM依赖，使用本地ShortcutRecorder

set -e

echo "🔄 移除远程ShortcutRecorder依赖..."

PROJECT_FILE="QuickLauncher.xcodeproj/project.pbxproj"

# 备份原文件
cp "$PROJECT_FILE" "$PROJECT_FILE.spm_backup"

# 移除SPM相关配置
sed -i '' '/ShortcutRecorder.*repositoryURL/d' "$PROJECT_FILE"
sed -i '' '/XCRemoteSwiftPackageReference.*ShortcutRecorder/d' "$PROJECT_FILE"
sed -i '' '/XCSwiftPackageProductDependency.*ShortcutRecorder/,+5d' "$PROJECT_FILE"
sed -i '' '/packageReferences.*ShortcutRecorder/d' "$PROJECT_FILE"
sed -i '' '/ShortcutRecorder in Frameworks/d' "$PROJECT_FILE"

echo "✅ 移除完成"
echo "📝 请手动将LocalDependencies/ShortcutRecorder/中的源文件添加到Xcode项目中"