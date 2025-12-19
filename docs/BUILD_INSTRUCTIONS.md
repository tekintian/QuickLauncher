# QuickLauncher macOS 10.15 构建说明

## 概述

本项目包含两个构建脚本，专门针对 macOS 10.15 (Catalina) 及以上版本的兼容性进行了优化。

## 脚本说明

### 1. 完整构建脚本 (`build_local.sh`)

功能齐全的构建脚本，支持完整的编译、归档和 DMG 打包。

**特性：**
- 支持 macOS 10.13+ 部署目标（兼容 macOS 10.15+）
- 自动清理构建目录
- 支持分别构建三个应用
- 自动生成 DMG 安装包
- 彩色输出和详细日志
- 错误处理和依赖检查

**使用方法：**

```bash
# 构建应用
./build_local.sh

```

### 2. 快速构建脚本 (`build_test.sh`)

| 脚本 | 用途 | 特点 |
|------|------|------|
| `build_test.sh` | 测试构建 | 跳过签名，快速验证 |
| `build_local.sh` | 本地构建 | 支持签名/跳过签名选项 |
| `build_minimal.sh` | 基本功能测试 | 专注于基本编译验证 |


## 系统要求

### 开发环境
- macOS 10.15+ (Catalina 或更高版本)
- Xcode 12.0 或更高版本
- Swift 5.0+
- 已安装的 Apple Developer Tools

### 目标系统兼容性
- **QuickLauncher**: macOS 10.13+

### 推荐设置
- **开发环境**: macOS 11.0+ (Big Sur) 或更高
- **部署目标**: macOS 10.13+ (可向上兼容到最新版本)
- **Xcode**: 最新稳定版本

## 构建输出

### 目录结构
```
QuickLauncher/
├── build/                  # 构建输出目录
│   ├── Build/             # 编译产物
│   ├── DerivedData/       # Xcode 派生数据
│   └── ExportOptions.plist # 导出配置
├── archive/               # 归档文件 (.xcarchive)
├── dmg/                   # DMG 安装包
└── dist
    └── QuickLauncher.app
```

### DMG 文件命名
- `QuickLauncher.dmg`

## 常见问题

### Q: 构建失败，提示代码签名问题
A: 确保在 Xcode 中正确配置了开发团队，或者在脚本中添加 `-allowProvisioningUpdates` 参数。

### Q: 无法找到开发者工具
A: 运行 `xcode-select --install` 安装命令行工具，或确保已安装完整的 Xcode。

### Q: 部署目标版本冲突
A: 使用 `--target` 参数指定合适的版本，建议使用 10.13 以支持大部分用户。

### Q: 构建速度慢
A: 使用 `build_local.sh` 进行快速编译，或在 Xcode 中使用增量构建。

## 开发工作流

### 日常开发
1. 使用 `build_local.sh` 进行快速编译测试
2. 在 Xcode 中进行调试和修改
3. 定期使用完整脚本生成 DMG 进行发布测试

### 发布准备
1. 使用 `build_local.shh -c` 进行完整清理构建
2. 验证所有应用功能正常
3. 测试 DMG 安装包
4. 进行真机测试

### CI/CD 集成
脚本支持自动化集成，可以轻松集成到 GitHub Actions 或其他 CI 系统中：

```bash
#!/bin/bash
# CI 脚本示例
./build_local.sh --skip-dmg  # 只构建，不打包
```

### 自定义构建配置
修改脚本中的 `CONFIGURATION` 变量：
- `Release`: 发布版本（默认）
- `Debug`: 调试版本
- `Adhoc`: 临时发布

### 自定义输出目录
修改脚本开头的路径变量：
```bash
BUILD_DIR="$PROJECT_DIR/custom_build"
DMG_DIR="$PROJECT_DIR/custom_dmg"
```

## 故障排除

### 检查系统环境
```bash
# 检查 Xcode 版本
xcodebuild -version

# 检查 SDK
xcodebuild -showsdks

# 检查开发者工具
xcode-select -p
```

### 清理环境
```bash
# 完全清理
rm -rf build/ archive/ dmg/

# 清理 Xcode 缓存
rm -rf ~/Library/Developer/Xcode/DerivedData/QuickLauncher-*
```

## 技术细节

### Swift 版本兼容性
- Swift 5.0+ (项目配置)
- 支持 Swift ABI 稳定性

### 架构支持
- x86_64 (Intel)
- arm64 (Apple Silicon) - 自动包含

### 代码签名
脚本使用 `-allowProvisioningUpdates` 参数，支持：
- 开发者证书
- 托管证书
- Ad-hoc 签名

## 许可证

本构建脚本遵循与主项目相同的许可证条款。