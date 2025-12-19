# 偏好设置界面本地化修复说明

## 问题描述

在设置为中文并重启后，偏好设置界面只有"录制快捷键"按钮能正确显示中文，其他所有界面元素都显示英文。

## 根本原因

问题出现的原因是 **Preferences.strings** 文件没有被正确包含在 Xcode 项目的构建过程中。

### 具体问题：

1. **文件存在但未被引用**：虽然 `QuickLauncher/PreferencesWindow/zh-Hans.lproj/Preferences.strings` 文件在源代码中存在，但它没有被添加到 Xcode 项目的构建目标中。

2. **构建缺失**：在构建过程中，只有 `Localizable.strings` 被复制到应用的 Resources 目录，而 `Preferences.strings` 被忽略。

3. **界面无法本地化**：由于缺少这些翻译文件，Storyboard 中的界面元素无法找到对应的中文翻译，因此显示英文。

## 解决方案

### 1. 临时解决方案（手动复制）

创建了一个脚本 `scripts/copy_localization.sh` 来手动复制本地化文件：

```bash
#!/bin/bash
# 该脚本会查找构建的应用目录，并将所有语言的 Preferences.strings 文件复制到正确位置
```

### 2. 长期解决方案（集成到构建流程）

修改了 `build_local.sh` 构建脚本，在构建完成后自动运行本地化复制脚本：

```bash
# 复制本地化文件
echo "🌍 复制本地化文件..."
if [ -f "$PROJECT_DIR/scripts/copy_localization.sh" ]; then
    "$PROJECT_DIR/scripts/copy_localization.sh"
else
    echo "⚠️  警告：找不到本地化复制脚本"
fi
```

### 3. 运行时检查

在 `AdvancedPreferencesViewController.swift` 中添加了运行时检查，在必要时提醒用户本地化文件缺失。

## 修复步骤

### 方法一：使用修复后的构建脚本

```bash
# 使用集成了本地化修复的构建脚本
./build_local.sh no-sign
```

### 方法二：手动修复

```bash
# 1. 构建应用
xcodebuild -scheme QuickLauncher -configuration Debug CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO build

# 2. 运行本地化复制脚本
./scripts/copy_localization.sh

# 3. 启动应用测试
open build/Build/Products/Debug/QuickLauncher.app
```

### 方法三：使用独立构建脚本

```bash
# 使用包含本地化修复的独立构建脚本
./build_with_localization.sh
```

## 验证修复

修复后，偏好设置界面应该能够正确显示中文：

1. ✅ 窗口标题显示"偏好设置"而不是"Preferences"
2. ✅ 标签页显示"通用"、"高级"而不是"General"、"Advanced"
3. ✅ 所有按钮和标签显示中文翻译
4. ✅ "录制快捷键"按钮继续正常工作（ShortcutRecorder 本地化也正常）

## 技术细节

### ShortcutRecorder 本地化

ShortcutRecorder 库的本地化问题通过修改 `LocalDependencies/ShortcutRecorder/Sources/ShortcutRecorder/SRCommon.m` 文件解决：

```c
NSBundle *SRBundle()
{
    // 添加了备用bundle查找逻辑，支持Swift Package Manager模式
    // 确保在各种集成方式下都能找到本地化资源
}
```

### 构建系统问题

Xcode 项目中的 `knownRegions` 配置正确包含了 `zh-Hans`，但是 Preferences.strings 文件没有被添加到构建目标的资源列表中。这是导致问题的根本原因。

## 建议

1. **长期解决方案**：将 Preferences.strings 文件正确添加到 Xcode 项目的构建目标中，而不是依赖脚本复制。

2. **CI/CD 集成**：在持续集成流程中添加本地化文件检查，确保所有语言的翻译文件都被正确包含。

3. **测试自动化**：添加自动化测试来验证本地化文件的存在和完整性。

## 相关文件

- `scripts/copy_localization.sh` - 本地化文件复制脚本
- `build_local.sh` - 修改后的构建脚本
- `build_with_localization.sh` - 独立的本地化构建脚本
- `QuickLauncher/PreferencesWindow/AdvancedPreferencesViewController.swift` - 添加了运行时检查
- `LocalDependencies/ShortcutRecorder/Sources/ShortcutRecorder/SRCommon.m` - 修复了ShortcutRecorder本地化