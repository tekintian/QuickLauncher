# QuickLauncher 图标替换工具使用说明

## 工具介绍

`update_app_icons.sh` 是一个自动化脚本，用于将指定的 PNG 图标文件替换到 QuickLauncher 应用的各个位置，支持分别设置应用图标和状态栏图标。

## 使用方法

### 基本用法
```bash
# 使用不同的源文件（推荐）
./scripts/update_app_icons.sh Resources/app-icon.png Resources/status-icon.png

# 使用相同的图标文件
./scripts/update_app_icons.sh Resources/app-icon.png

# 使用绝对路径
./scripts/update_app_icons.sh /path/to/app-icon.png /path/to/status-icon.png

# 使用相对路径
./scripts/update_app_icons.sh ./icons/app-icon.png ./icons/status-icon.png
```

### 参数说明
- **第一个参数**：应用图标源文件路径（必需）
- **第二个参数**：状态栏图标源文件路径（可选，默认使用应用图标）

## 功能特性

### 🔧 自动生成的图标类型
- **应用图标**（8个文件）：
  - 16x16, 32x32, 128x128, 256x256（标准尺寸）
  - 对应的 @2x 和 @3x 高分辨率版本
  - 最大支持 512x512 像素（256@2x）

- **状态栏图标**（3个文件）：
  - 16x16, 32x32, 48x48
  - 支持 1x, 2x, 3x 缩放

- **Logo 图标**（1个文件）：
  - 256x256 标准尺寸（使用应用图标源文件）

### 🛡️ 安全特性
- **自动备份**：可选择备份当前图标
- **错误检查**：验证文件存在性和格式
- **路径安全**：支持相对和绝对路径
- **系统检查**：确认 macOS 环境和工具可用性
- **分别处理**：支持应用图标和状态栏图标使用不同源文件

## 交互式功能

脚本运行时会提供以下选项：
1. **备份确认**：询问是否备份当前图标
2. **缓存清理**：询问是否清理 Xcode 构建缓存
3. **实时反馈**：显示处理进度和结果

## 系统要求

- **操作系统**：macOS（需要 sips 工具）
- **文件格式**：PNG 格式的图标文件
- **运行位置**：QuickLauncher 项目根目录

## 示例输出

```
================================
QuickLauncher 图标替换工具
================================
[INFO] 应用图标源文件：/Volumes/data/projects/swift/QuickLauncher/Resources/app-icon.png
[INFO] 状态栏图标源文件：/Volumes/data/projects/swift/QuickLauncher/Resources/status-icon.png
[INFO] 项目根目录：/Volumes/data/projects/swift/QuickLauncher

是否备份当前图标？(y/N): y
[WARNING] 正在备份原图标到：./icon_backup_20231219_180000
[INFO] 原图标备份完成

================================
开始生成图标
[INFO] 生成应用图标...
[INFO] 生成 16x16 应用图标 (16 x 16)
  ✓ 已生成：AppIcon-16.png
  ✓ 已生成：AppIcon-16@2x.png
  ...（其他应用图标）

[INFO] 生成状态栏图标...
[INFO] 生成 16x16 状态栏图标 (16 x 16)
  ✓ 已生成：status_bar_icon.png
  ✓ 已生成：status_bar_icon@2x.png
  ✓ 已生成：status_bar_icon@3x.png

[INFO] 生成 Logo 图标...
[INFO] 生成 256x256 Logo 图标 (256 x 256)
  ✓ 已生成：AppIcon-256.png

================================
图标替换完成
[INFO] 总共生成了 12 个图标文件
[INFO] 应用图标数量：8 个
[INFO] 状态栏图标数量：3 个
[INFO] Logo 图标数量：1 个
```

## 推荐的图标设计

### 应用图标
- **尺寸**：建议使用 512x512 或更高分辨率的 PNG
- **设计**：应该简洁明了，在小尺寸下也能清晰识别
- **内容**：代表应用功能的主要视觉元素

### 状态栏图标
- **尺寸**：建议使用 128x128 或更高分辨率的 PNG
- **设计**：必须简洁，在 16x16 像素下也能清晰识别
- **颜色**：建议使用单色或简单的配色方案
- **内容**：简洁的符号或字母，适合小尺寸显示

## 故障排除

### 常见错误及解决方案

1. **"应用图标文件不存在"**
   - 检查应用图标文件路径是否正确
   - 确保文件确实存在

2. **"状态栏图标文件不存在"**
   - 检查状态栏图标文件路径是否正确
   - 确保文件确实存在

3. **"仅支持 PNG 格式的图标文件"**
   - 转换图片格式为 PNG
   - 检查文件扩展名

4. **"sips 工具不可用"**
   - 确保在 macOS 系统上运行
   - sips 是 macOS 系统自带工具，无需额外安装

5. **"目录不存在"**
   - 确保在 QuickLauncher 项目根目录运行脚本
   - 检查项目结构是否完整

## 高级用法

### 批量处理图标
```bash
# 处理多套图标
for theme in light dark; do
    ./scripts/update_app_icons.sh "icons/app-${theme}.png" "icons/status-${theme}.png"
done
```

### 自动化构建
在 CI/CD 流程中使用：
```bash
# 非交互式模式（跳过备份和缓存清理）
echo "N" | echo "N" | ./scripts/update_app_icons.sh build/app-icon.png build/status-icon.png
```

### 备份管理
定期清理备份文件：
```bash
# 删除7天前的备份
find . -name "icon_backup_*" -type d -mtime +7 -exec rm -rf {} +
```

## 文件结构

生成的图标将放置在以下位置：
```
QuickLauncher/
├── Assets.xcassets/
│   ├── AppIcon.appiconset/     # 应用图标（8个文件）
│   ├── StatusBarIcon.imageset/ # 状态栏图标（3个文件）
│   └── logo.imageset/         # Logo 图标（1个文件）
└── Resources/
    ├── app-icon.png           # 应用图标源文件
    └── status-icon.png        # 状态栏图标源文件
```

## 更新日志

- **v2.0**：支持分别设置应用图标和状态栏图标源文件
- **v1.0**：初始版本，支持基本的图标替换功能
- 修复了 bash 数组遍历的兼容性问题
- 改进了错误处理和用户反馈

---

💡 **提示**：
- 建议使用正方形的高质量 PNG 图标以获得最佳效果
- 状态栏图标应该设计得简洁，适合小尺寸显示
- 可以定期备份重要的图标设计文件