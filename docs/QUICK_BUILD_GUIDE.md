# 🚀 QuickLauncher 快速构建脚本使用指南

## 📋 脚本概述

`quick_build.sh` 已成功修改为支持简单代码签名的版本，适用于你的 macOS 10.15 本地环境。

## ✅ 已验证的功能

### 1. 主应用构建 (Ad-hoc 签名) ✅
```bash
./quick_build.sh --signing-mode adhoc terminal
```
- ✅ 构建成功
- ✅ 适用于本地测试
- ✅ 生成了签名版本的应用

### 2. 框架构建 (无签名) ✅  
```bash
./quick_build.sh --signing-mode none # (需要处理框架依赖)
```
- ✅ QuickLauncherCore 框架构建成功

## 🛠️ 签名模式说明

| 模式 | 说明 | 适用场景 | 状态 |
|------|------|----------|------|
| `auto` | 自动签名 | 开发者账户可用时 | 🟡 需要配置 |
| `adhoc` | Ad-hoc 签名 | 本地开发测试 | ✅ 已验证 |
| `none` | 无签名 | 纯开发调试 | ⚠️ 有框架依赖问题 |

## 🎯 推荐使用方式

### 1. 构建完整主应用 (推荐)
```bash
./quick_build.sh --signing-mode adhoc terminal
```
这是最可靠的构建方式，适用于：
- 本地功能测试
- 检查代码修改效果
- 调试问题

### 2. 构建所有应用
```bash
./quick_build.sh --signing-mode adhoc all
```
构建所有组件，包括：
- QuickLauncher 主应用 ✅

### 3. 查看帮助
```bash
./quick_build.sh --help
```

## 📍 构建产物位置

成功构建的应用位于：
```
build/Build/Products/Release/
```

### 已验证的构建产物
- ✅ **QuickLauncher.app** - 主应用 (约 23M)

## ⚠️ 已知问题和解决方案

### 自动签名问题  
**问题**: 需要配置开发者账户和团队 ID
**解决方案**: 使用 `adhoc` 签名模式进行本地测试

## 🔄 替代方案

如果遇到问题，可以使用其他已验证的脚本：

### 1. `build_local.sh` - 完全无签名构建
```bash
./build_local.sh   # 构建主应用
./build_local.sh all         # 构建所有应用 (支持依赖)
```

### 2. `build_macos_10_15.sh` - 完整构建脚本
```bash
./build_macos_10_15.sh      # 需要开发者账户，可生成 DMG
```

## 🚀 快速开始

1. **测试主应用**:
   ```bash
   ./quick_build.sh --signing-mode adhoc terminal
   ```

2. **运行应用**:
   ```bash
   open build/Build/Products/Release/QuickLauncher.app
   ```

3. **检查功能**:
   - 在 Finder 中右键文件夹
   - 选择 "Open in Terminal" 或 "Open in Editor"
   - 检查菜单栏图标

## 💡 开发建议

1. **日常开发**: 使用 `./quick_build.sh --signing-mode adhoc terminal`
2. **完整测试**: 使用 `./build_local.sh all`  
3. **发布准备**: 使用 `./build_macos_10_15.sh` (需要配置开发者账户)

## 📞 故障排除

如果构建失败：
1. 检查 Xcode 版本: `xcodebuild -version`
2. 检查 SDK: `xcodebuild -showsdks`
3. 清理构建缓存: `rm -rf build/`
4. 使用替代脚本: `./build_local.sh terminal`

---

**🎉 你的 macOS 10.15 环境已成功配置 QuickLauncher 快速构建系统！**