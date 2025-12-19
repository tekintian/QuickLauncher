# 🎨 QuickLauncher 图标

QuickLauncher项目的应用图标、状态栏图标和Finder扩展图标。

## 🔧 图标类型
- **应用图标**（8个文件）：
  - 16x16, 32x32, 128x128, 256x256（标准尺寸）
  - 对应的 @2x 和 @3x 高分辨率版本
  - 最大支持 512x512 像素（256@2x）

- **状态栏图标**（3个文件）：
  - 16x16, 32x32, 48x48
  - 支持 1x, 2x, 3x 缩放

- **Logo 图标**（1个文件）：
  - 256x256 标准尺寸

### 🔧 图标文件位置：
```
QuickLauncher/
├── Assets.xcassets/
│   ├── AppIcon.appiconset/     # 应用图标
│   ├── StatusBarIcon.imageset/ # 状态栏图标
│   └── logo.imageset/         # Logo 图标
```

## 📊 状态栏图标 (StatusBarIcon)
3个状态栏图标：

| 文件名 | 尺寸 | 用途 | 状态 |
|--------|------|------|------|
| `status_bar_icon.png` | 18x18 | 状态栏标准显示 | ✅ 已替换 |
| `status_bar_icon@2x.png` | 36x36 | 状态栏2x显示 | ✅ 已替换 |
| `status_bar_icon@3x.png` | 54x54 | 状态栏3x显示 | ✅ 已替换 |

## 🔍 Finder扩展图标 (Finder Extension)
3个Finder扩展图标：

| 文件名 | 尺寸 | 用途 | 状态 |
|--------|------|------|------|
| `Finder_extension_icon.png` | 16x16 | 上下文菜单标准 | ✅ 已替换 |
| `Finder_extension_icon@2x.png` | 32x32 | 上下文菜单2x | ✅ 已替换 |
| `Finder_extension_icon@3x.png` | 48x48 | 上下文菜单3x | ✅ 已替换 |

### 🛠️ 工具栏图标 (Toolbar)

以下工具栏图标：

| 文件名 | 尺寸 | 用途 | 状态 |
|--------|------|------|------|
| `ToolbarCustomize.png` | 32x32 | 工具栏自定义 | ✅ 已替换 |

## 📁 文件位置

### 源图标文件
```
Resources/
└── app-icon.png (816.75 KB) - 源图标文件
```

### 目标文件位置

```
QuickLauncher/Assets.xcassets/
├── AppIcon.appiconset/
│   ├── AppIcon-16.png
│   ├── AppIcon-16@2x.png
│   ├── AppIcon-32.png
│   ├── AppIcon-32@2x.png
│   ├── AppIcon-128.png
│   ├── AppIcon-128@2x.png
│   ├── AppIcon-256.png
│   ├── AppIcon-256@2x.png
│   └── Contents.json
├── StatusBarIcon.imageset/
│   ├── status_bar_icon.png
│   ├── status_bar_icon@2x.png
│   ├── status_bar_icon@3x.png
│   └── Contents.json
├── ToolbarCustomize.imageset/
│   ├── ToolbarCustomize.png
│   └── Contents.json
└── logo.imageset/
    ├── AppIcon-256.png (通过AppIcon引用)
    └── Contents.json

QuickLauncherFinderExtension/FinderAssets.xcassets/
└── Icon.imageset/
    ├── Finder_extension_icon.png
    ├── Finder_extension_icon@2x.png
    ├── Finder_extension_icon@3x.png
    └── Contents.json
```

## 🛠️ 技术实现

### 使用的工具
- **sips** (macOS内置图片处理工具) - 用于调整图标尺寸
- **bash脚本** - 自动化替换流程

### 替换命令示例
```bash
# 替换应用图标
sips -z 16 16 Resources/app-icon.png --out QuickLauncher/Assets.xcassets/AppIcon.appiconset/AppIcon-16.png

# 替换状态栏图标  
sips -z 18 18 Resources/app-icon.png --out QuickLauncher/Assets.xcassets/StatusBarIcon.imageset/status_bar_icon.png

# 替换Finder扩展图标
sips -z 16 16 Resources/app-icon.png --out QuickLauncherFinderExtension/FinderAssets.xcassets/Icon.imageset/Finder_extension_icon.png
```

## 🎯 视觉效果

### 统一性
- 所有界面元素使用统一的新图标设计
- 保持了品牌一致性
- 提升了用户界面现代感

### 清晰度
- 每个尺寸都进行了优化处理
- 支持Retina高分辨率显示
- 在不同系统缩放比例下保持清晰

## 🔄 自动化脚本

如需将来重新生成图标，可使用以下脚本：

```bash
#!/bin/bash
# 图标替换脚本

SOURCE_ICON="Resources/app-icon.png"

# 应用图标尺寸
declare -a APP_ICON_SIZES=("16:16" "32:16@2x" "32:32" "64:32@2x" "128:128" "256:128@2x" "256:256" "512:256@2x" "512:512" "1024:512@2x")

# 状态栏图标尺寸
declare -a STATUS_SIZES=("18:status_bar_icon" "36:status_bar_icon@2x" "54:status_bar_icon@3x")

# Finder扩展图标尺寸
declare -a FINDER_SIZES=("16:Finder_extension_icon" "32:Finder_extension_icon@2x" "48:Finder_extension_icon@3x")

# 执行替换
for size_info in "${APP_ICON_SIZES[@]}"; do
    IFS=':' read -r size filename <<< "$size_info"
    sips -z $size $size $SOURCE_ICON --out "QuickLauncher/Assets.xcassets/AppIcon.appiconset/$filename.png"
done

for size_info in "${STATUS_SIZES[@]}"; do
    IFS=':' read -r size filename <<< "$size_info"
    sips -z $size $size $SOURCE_ICON --out "QuickLauncher/Assets.xcassets/StatusBarIcon.imageset/$filename.png"
done

for size_info in "${FINDER_SIZES[@]}"; do
    IFS=':' read -r size filename <<< "$size_info"
    sips -z $size $size $SOURCE_ICON --out "QuickLauncherFinderExtension/FinderAssets.xcassets/Icon.imageset/$filename.png"
done

echo "✅ 所有图标替换完成！"
```

## 📝 注意事项

### 图标设计要求
- 新图标应支持透明背景
- 建议使用PNG格式
- 确保在深色和浅色模式下都清晰可见
- 考虑不同尺寸下的视觉效果

### 构建验证
- 每次更换图标后建议重新构建项目
- 检查图标在不同界面元素中的显示效果
- 验证Retina和非Retina显示器上的效果
