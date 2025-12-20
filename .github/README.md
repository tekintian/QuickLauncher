# GitHub Actions CI/CD 工作流

本项目使用 GitHub Actions 进行持续集成和自动发布。

## 环境变量

工作目录: /Users/runner/work/QuickLauncher/QuickLauncher/

构建路径: DerivedData-Intel/Build/Products/Release/QuickLauncher.app (相对路径)

完整路径: /Users/runner/work/QuickLauncher/QuickLauncher/DerivedData-Intel/Build/Products/Release/QuickLauncher.app



## 🔄 工作流文件

### 1. `ci.yml` - 持续集成
- **触发条件**：推送到 main/master/develop 分支，或针对这些分支的 Pull Request
- **功能**：
  - 多架构构建（Intel x86_64 和 Apple Silicon ARM64）
  - 基本代码检查和语法验证
  - 项目结构验证
  - 脚本权限检查

### 2. `release.yml` - 自动发布
- **触发条件**：推送以 `v` 开头的标签（如 `v1.0.0`）
- **功能**：
  - 多架构构建和打包
  - 创建 DMG 安装包和 ZIP 压缩包
  - 代码签名（自签名或开发者证书）
  - 生成 SHA256 校验和
  - 自动创建 GitHub Release

## 🚀 发布流程

1. **开发完成**：确保代码已提交并测试
2. **创建标签**：
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
3. **自动发布**：GitHub Actions 将自动：
   - 构建 Intel 和 ARM64 版本
   - 创建 DMG 和 ZIP 安装包
   - 生成校验和
   - 发布到 GitHub Releases

## 📦 发布产物

每次发布会生成以下文件：

| 文件名 | 描述 | 架构 |
|--------|------|------|
| `QuickLauncher-Intel.dmg` | Intel 版本 DMG 安装包 | x86_64 |
| `QuickLauncher-ARM64.dmg` | Apple Silicon 版本 DMG 安装包 | arm64 |
| `QuickLauncher-Intel.zip` | Intel 版本 ZIP 压缩包 | x86_64 |
| `QuickLauncher-ARM64.zip` | Apple Silicon 版本 ZIP 压缩包 | arm64 |
| `*.sha256` | 对应文件的 SHA256 校验和 | - |

## 🏗️ 构建要求

- **macOS 版本**：
  - Intel 版本：macOS 10.15 (Catalina)+
  - ARM64 版本：macOS 11.0 (Big Sur)+
- **Xcode**：最新稳定版本
- **Swift**：兼容 Swift 5.3+

## 🔐 代码签名

### 自签名（默认）
- 使用临时自签名证书
- 用户首次运行时需要手动允许

### 开发者证书（可选）
1. 在 GitHub Secrets 中设置 `APPLE_SIGNING_IDENTITY`
2. 值格式：`Developer ID Application: Your Name (TEAM_ID)`
3. CI 将自动使用开发者证书签名

## 🛠️ 本地构建

### 开发构建
```bash
# Intel 版本
xcodebuild -project QuickLauncher.xcodeproj -scheme QuickLauncher -configuration Debug -arch x86_64 build

# ARM64 版本  
xcodebuild -project QuickLauncher.xcodeproj -scheme QuickLauncher -configuration Debug -arch arm64 build
```

### 发布构建
```bash
# 使用提供的脚本
./scripts/update_app_icons.sh Resources/app-icon.png Resources/status-icon.png

# 或手动构建
xcodebuild -project QuickLauncher.xcodeproj -scheme QuickLauncher -configuration Release build
```

## 🔧 故障排除


### ✅ 正确的应用结构参考
构建的应用 (`QuickLauncher.app`) 应该包含：
```
QuickLauncher.app/Contents/
├── MacOS/
│   └── QuickLauncher (1.88 MB) ✅
├── Frameworks/
│   ├── libswiftFoundation.dylib (3.02 MB) ✅
│   ├── libswiftAppKit.dylib (217.38 KB) ✅
│   ├── libswiftCore.dylib (6.16 MB) ✅
│   └── QuickLauncherCore.framework/ ✅
├── Resources/
│   ├── Assets.car (1.61 MB) ✅
│   ├── AppIcon.icns (64 KB) ✅
│   ├── MainMenu.nib (4.06 KB) ✅
│   └── *.lproj/ (本地化文件) ✅
├── PlugIns/
│   └── QuickLauncherFinderExtension.appex/ ✅
└── Info.plist ✅
```

### CI 构建失败
1. 检查 Xcode 版本兼容性
2. 验证 Package.swift 和项目配置
3. 确认本地依赖项正确

### 发布失败
1. 确认标签格式正确（`v` 开头）
2. 检查 GITHUB_TOKEN 权限
3. 验证项目结构和文件路径

### 签名问题
1. 检查开发者证书配置
2. 验证 Apple ID 和 Team ID
3. 确认证书有效性

## 📊 监控

- 所有构建状态可在 GitHub Actions 页面查看
- 发布历史在 GitHub Releases 中跟踪
- 构建日志可用于调试和优化

---

**注意**：首次使用前请仔细阅读项目主 README 了解完整的使用说明和权限配置。