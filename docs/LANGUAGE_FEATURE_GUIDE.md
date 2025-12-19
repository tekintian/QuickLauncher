# 语言配置功能实现指南

## 功能概述

已在 QuickLauncher 的偏好设置中添加了语言配置功能，支持以下语言：
- Auto (跟随系统)
- English
- 简体中文 (zh-Hans)
- Deutsch (de)
- Español (es)
- Français (fr)
- Italiano (it)
- 한국어 (ko)
- Русский (ru)
- Türkçe (tr)

## 已完成的后端实现

### 1. 数据存储层
- ✅ 在 `DefaultsKeys` 中添加了 `selectedLanguage` 键
- ✅ 在 `DefaultsManager` 中添加了语言配置属性和方法
- ✅ 实现了 `setLanguage()` 方法来应用语言更改
- ✅ 添加了 `availableLanguages` 属性提供可用语言列表

### 2. 界面控制器层
- ✅ 在 `GeneralPreferencesViewController` 中添加了语言选择逻辑
- ✅ 实现了 `initLanguageMenu()` 方法
- ✅ 实现了 `refreshLanguage()` 方法
- ✅ 实现了 `languageChanged()` 事件处理
- ✅ 添加了语言更改确认对话框和重启功能

### 3. 应用层
- ✅ 在 `AppDelegate` 中添加了 `restartApplication()` 方法
- ✅ 创建了 `Notification+Name.swift` 扩展支持语言更改通知
- ✅ 添加了本地化字符串常量

## 需要手动完成的界面连接

### 在 Storyboard 中添加语言选择界面

请按照以下步骤在 `Preferences.storyboard` 中添加语言选择控件：

#### 步骤 1: 打开 Storyboard
1. 在 Xcode 中打开 `QuickLauncher.xcworkspace`
2. 导航到 `QuickLauncher/PreferencesWindow/Base.lproj/Preferences.storyboard`
3. 在 Interface Builder 中打开该文件

#### 步骤 2: 定位 General 页面
1. 在 Storyboard 中找到 "General Preferences View Controller"
2. 在界面中找到 "Open with default Editor:" 标签和下拉菜单
3. 在此下方添加语言选择界面

#### 步骤 3: 添加界面元素
1. **添加标签**：
   - 从 Object Library 拖拽一个 `Label` 到界面
   - 设置文本为 "Language:" (或根据本地化设置)
   - 将标签 ID 设置为类似 "language-label"

2. **添加下拉菜单**：
   - 从 Object Library 拖拽一个 `Pop Up Button` 到标签旁边
   - 设置 Button ID 为 "language-button"
   - 在 Attributes Inspector 中确保 Behavior 设置为 "Push In Pull Down"

#### 步骤 4: 连接 Outlet
1. 选中 `GeneralPreferencesViewController`
2. 右键点击打开 Connections Inspector
3. 将 `language-button` 连接到 `@IBOutlet weak var languageButton: NSPopUpButton!`

#### 步骤 5: 连接 Action
1. 在 Pop Up Button 上右键
2. 拖拽 "Value Changed" 事件到 `GeneralPreferencesViewController`
3. 选择 `languageChanged:` 方法

#### 步骤 6: 设置 Auto Layout 约束
1. 为标签和下拉菜单设置适当的约束
2. 确保与其他元素对齐
3. 设置合适的间距

#### 步骤 7: 添加本地化字符串
如果需要完全本地化，请在以下文件中添加字符串：

**英文** (`en.lproj/Preferences.strings`):
```
/* Class = "NSTextFieldCell"; title = "Language:"; ObjectID = "your-label-id"; */
"your-label-id.title" = "Language:";
```

**中文** (`zh-Hans.lproj/Preferences.strings`):
```
/* Class = "NSTextFieldCell"; title = "Language:"; ObjectID = "your-label-id"; */
"your-label-id.title" = "语言：";
```

## 功能特性

### 语言切换流程
1. 用户在偏好设置中选择语言
2. 系统显示确认对话框询问是否重启应用
3. 用户确认后保存语言设置
4. 应用自动重启，应用新语言

### 支持的语言
- **Auto**: 跟随系统语言设置
- **English**: 英语
- **简体中文**: 简体中文
- **Deutsch**: 德语
- **Español**: 西班牙语
- **Français**: 法语
- **Italiano**: 意大利语
- **한국어**: 韩语
- **Русский**: 俄语
- **Türkçe**: 土耳其语

### 存储方式
- 使用 `UserDefaults` 存储用户选择
- 键名: `SelectedLanguage`
- 默认值: `auto` (跟随系统)

### 语言应用方式
- 使用 `AppleLanguages` 系统设置
- 重启应用后立即生效
- 支持标准的 macOS 本地化机制

## 测试验证

### 基本功能测试
1. 打开应用偏好设置
2. 验证语言下拉菜单是否显示所有可用语言
3. 选择不同语言并确认重启
4. 验证应用重启后界面语言是否正确

### 边界情况测试
1. 测试取消重启后设置是否保持
2. 测试多次快速切换语言
3. 测试系统语言变化时的"Auto"选项行为

### 本地化测试
1. 在不同系统语言环境下测试界面显示
2. 验证所有本地化字符串是否正确显示
3. 测试从右到左语言的支持（如适用）

## 编译和构建

语言配置功能已经完全集成到现有构建系统中，无需额外的构建设置。所有现有的构建脚本都支持此功能。

## 注意事项

1. **重启必要性**: macOS 应用需要重启才能应用语言更改
2. **系统兼容性**: 语言设置使用标准的 `AppleLanguages` 方法
3. **本地化覆盖**: 用户选择会覆盖系统语言设置
4. **设置持久化**: 语言选择会在应用更新后保持

这个实现提供了完整的语言配置功能，用户可以根据需要选择界面语言，提升了应用的国际化和用户体验。