<div align="center">
  <img width="80%" src="../Resources/app-icon.png"><br/><br/>
  <a href="../README.md">English</a> | 中文
</div>

# QuickLauncher

一款强大的macOS实用工具，通过允许您直接从Finder上下文菜单快速打开终端或代码编辑器来提升生产力。消除在终端应用程序中手动导航目录的需要，简化您的工作流程。

## ✨ 核心特性

QuickLauncher是基于Ji4n1ng的OpenInTerminal项目的精简优化重构版本，具有显著改进：

- **🚀 体积优化**：从32MB大幅精简至22MB，下载更快，占用空间更小
- **🧠 内存管理优化**：增强内存效率，减少资源使用
- **🌐 多语言支持**：新增语言配置功能，支持9种语言界面
- **📦 本地依赖**：将网络依赖优化为本地依赖，提高构建和运行稳定性
- **⚡ 统一异常管理**：全面的错误处理机制，提升用户体验
- **🎯 现代化启动管理**：采用先进的启动系统，替代辅助应用程序

## 🎯 主要功能

| 功能特性 | 描述说明 |
| --- | --- |
| **快速终端访问** | 从Finder上下文菜单直接在当前路径打开终端 |
| **编辑器集成** | 在您喜欢的代码编辑器中打开文件和文件夹 |
| **多应用支持** | 兼容各种终端和编辑器应用程序 |
| **自定义应用** | 添加和配置除默认支持外的自定义应用程序 |
| **全局快捷键** | 通过可配置的键盘快捷键快速执行操作 |
| **状态栏集成** | 从菜单栏快速访问，具有可定制行为 |
| **多语言支持** | 界面支持9种语言 |
| **路径复制** | 一键复制文件/文件夹路径到剪贴板 |

## 🛠️ 支持的应用程序

### 终端应用
- **Terminal** (macOS默认)
- **iTerm** - 高级终端模拟器
- **Hyper** - 基于Electron的终端
- **Alacritty** - GPU加速终端
- **kitty** - 快速、功能丰富的终端
- **Warp** - 现代化AI驱动终端
- **WezTerm** - 跨平台终端
- **Tabby** - 高度可配置终端
- **Ghostty** - 现代终端模拟器

### 编辑器应用
- **TextEdit** (macOS默认)
- **Xcode** - 苹果官方IDE
- **Visual Studio Code** - 微软代码编辑器
- **Visual Studio Code - Insiders** - VS Code预览版
- **Atom** - GitHub文本编辑器
- **Sublime Text** - 精致的文本编辑器
- **VSCodium** - 开源VS Code二进制版本
- **BBEdit** - 专业文本和代码编辑器
- **TextMate** - Mac强大文本编辑器
- **CotEditor** - 轻量级文本编辑器
- **MacVim** - macOS的Vim GUI版本
- **JetBrains套件** - 专业IDE系列：
  - AppCode (Objective-C/Swift)
  - CLion (C/C++)
  - GoLand (Go)
  - IntelliJ IDEA (Java)
  - PhpStorm (PHP)
  - PyCharm (Python)
  - RubyMine (Ruby)
  - WebStorm (JavaScript/TypeScript)
  - Android Studio (Android)
  - Fleet (下一代IDE)
- **Typora** - 极简markdown编辑器
- **Nova** - 现代文本编辑器
- **Cursor** - AI驱动代码编辑器
- **notepad--** - 轻量级文本编辑器
- **neovim** - 超可扩展的Vim编辑器

## 📥 安装方法

### 方法1：直接下载（推荐）
1. 访问 [GitHub Releases](https://github.com/tekintian/QuickLauncher/releases)
2. 下载最新DMG文件
3. 双击DMG，将应用拖拽到Applications文件夹
4. 启动应用并授予必要权限

### 方法2：从源码构建
```bash
# 克隆仓库
git clone https://github.com/tekintian/QuickLauncher.git
cd QuickLauncher

# 构建应用
./build_local.sh

# 运行应用
open build/Build/Products/Release/QuickLauncher.app
```

## 🚀 快速开始

### 1. 启用Finder扩展
1. 打开 **系统偏好设置** → **扩展** → **Finder扩展**
2. 勾选 **QuickLauncher** 启用扩展

### 2. 开始使用
在Finder中：
1. 右键点击任意文件夹
2. 选择 **"Open in Terminal"** 在终端中打开
3. 选择 **"Open in Editor"** 在默认编辑器中打开

### 3. 菜单栏快速访问
点击菜单栏中的QuickLauncher图标可访问：
- 打开当前文件夹
- 应用设置
- 快速操作

## ⚙️ 配置设置

### 更改默认终端
1. 打开QuickLauncher设置
2. 转到"Terminal"选项卡
3. 选择您偏好的终端应用程序

### 添加自定义编辑器
1. 点击"添加自定义应用"
2. 选择应用程序
3. 设置启动参数

### 设置键盘快捷键
1. 进入"快捷键"设置
2. 为常用操作设置全局快捷键

## 🔧 开发构建

### 前置要求
- **macOS**: 10.15+ (Catalina或更高版本)
- **Xcode**: 12.0+
- **Swift**: 5.3+
- **Git**

### 构建脚本
```bash
# 开发构建（跳过签名）
./build_local.sh no-sign

# 生产构建（需要有效证书）
./build_local.sh

# 快速测试编译
./build_test.sh

# 最小化构建（基本功能）
./build_minimal.sh
```

### 架构设计

QuickLauncher采用模块化架构，包含三个主要组件：

- **主应用程序**：用户界面和首选项管理
- **QuickLauncherCore**：核心功能库，处理终端/编辑器启动逻辑
- **Finder扩展**：Finder的上下文菜单集成
- **LaunchManager**：现代化应用启动管理

### 依赖项
- **Swift 5.3+**
- **ShortcutRecorder** (本地依赖)
- **系统框架**：AppKit、FinderSync、ServiceManagement、Carbon

## 📚 项目文档

### 📖 用户文档
- [🚀 快速入门指南](../QUICK_START.md) - 5分钟快速上手
- [📋 完整配置说明](./README-Config.md) - 详细设置和选项
- [🔄 更新日志](../CHANGELOG.md) - 版本历史和更新

### 👨‍💻 开发者文档
- [🛠️ 构建说明](../docs/BUILD_INSTRUCTIONS.md) - 完整构建指南
- [⚡ 快速构建指南](../docs/QUICK_BUILD_GUIDE.md) - 开发者构建脚本
- [🔧 故障排除](../docs/BUILD_TROUBLESHOOTING.md) - 常见问题和解决方案
- [🏗️ 架构说明](../docs/REFACTORING_SUMMARY.md) - 项目重构详情

### 📋 项目治理
- [🤝 贡献指南](../CONTRIBUTING.md) - 如何参与贡献
- [🔒 安全政策](../SECURITY.md) - 安全漏洞报告
- [📄 许可证](../LICENSE) - MIT许可证条款

## 🌟 支持项目

开源项目需要您的支持才能长期发展。如果您觉得QuickLauncher有用，请考虑支持其开发：

### 💝 赞助支持
成为赞助商支持项目的持续开发。您的用户图标或公司标志将显示在README中并链接到您的主页。

| 支付宝 | 微信支付 |
| --- | --- |
| <img src="./alipay.jpg" width="50%"> | <img src="./weChatPay.jpg" width="50%"> |

## 📊 技术规格

### 系统要求
- **macOS版本**：10.15+ (Catalina或更高版本)
- **内存**：推荐最低4GB RAM
- **存储空间**：100MB可用空间
- **架构**：通用版本（Intel x86_64 和 Apple Silicon M1/M2）

### 性能优化
- **启动速度**：为快速应用启动进行优化
- **内存使用**：高效内存管理，最小化占用
- **电池续航**：低资源消耗，适合长时间使用
- **网络独立性**：核心功能无网络依赖

### 安全特性
- **沙盒合规**：遵循macOS沙盒指南
- **代码签名**：正确签名确保安全性
- **隐私保护**：无数据收集或跟踪
- **权限模式**：仅请求必要的最小权限

## 🤝 参与贡献

我们欢迎各种类型的贡献！请查看我们的[贡献指南](../CONTRIBUTING.md)了解详情：
- 报告错误
- 请求功能
- 提交代码更改
- 文档改进

## 🏆 致谢

本项目由**tekintian**维护和开发，灵感来源于：
- [Ji4n1ng/OpenInTerminal](https://github.com/Ji4n1ng/OpenInTerminal)
- [jbtule/cdto](https://github.com/jbtule/cdto)
- [es-kumagai/OpenTerminal](https://github.com/es-kumagai/OpenTerminal)
- [tingraldi/SwiftScripting](https://github.com/tingraldi/SwiftScripting)
- [onmyway133/FinderGo](https://github.com/onmyway133/FinderGo)
- [Caldis/Mos](https://github.com/Caldis/Mos/)

## 📞 联系方式

- **邮箱**：tekin.tian@gmail.com
- **网站**：[https://dev.tekin.cn](https://dev.tekin.cn)
- **QQ**：932256355

### 专业服务

我提供专业的软件开发服务，包括：
- macOS应用开发与优化
- Web应用开发（全栈）
- 企业信息化系统定制
- 软件架构设计与重构
- 性能优化与系统集成

如有合作需求，欢迎通过以上方式咨询。

## 📄 许可证

QuickLauncher基于[MIT许可证](../LICENSE)发布。

---

**⭐ 如果这个项目对您有帮助，请考虑给它一个星标！**