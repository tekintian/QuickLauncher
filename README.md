<div align="center">
  <img width="80%" src="Resources/app-icon.png"><br/><br/>
  English | <a href="./Resources/README-zh.md">中文</a> 
</div>

## QuickLauncher

QuickLauncher是一款为macOS设计的实用工具，允许您从Finder上下文菜单快速打开终端或编辑器应用程序。通过简单的点击，您可以在指定路径下启动您喜欢的终端或编辑器，极大提升开发和文件管理效率。

### 项目特点

本项目是基于macos原生Swift语言,并参考了多个github优秀项目, 在Ji4n1ng的OpenInTerminal项目基础上进行的精简优化改造重构版本，主要改进包括：

- **体积优化**：从原有的32M大幅精简至22M
- **内存管理优化**：改进了内存使用效率，减少资源占用
- **语言配置增强**：新增语言配置功能，支持多语言切换
- **依赖本地化**：将网络依赖优化为本地依赖，提高构建和运行稳定性
- **统一异常管理**：实现了统一的错误处理机制，提升用户体验
- **现代化Launcher**：采用现代化的启动管理方式，提高应用响应速度

## 核心功能

| 功能 Feature | 描述 Description |
| --- | --- |
| **快速启动终端** | 从Finder上下文菜单直接在当前路径打开终端 |
| **编辑器集成** | 支持在各种代码编辑器中打开文件和文件夹 |
| **多应用支持** | 兼容多种终端和编辑器应用程序 |
| **自定义应用** | 支持添加和使用自定义应用程序 |
| **键盘快捷键** | 通过全局快捷键快速执行操作 |
| **状态栏集成** | 从菜单栏快速访问功能 |
| **多语言支持** | 支持9种语言界面 |
| **路径复制** | 一键复制文件或文件夹路径到剪贴板 |

## 支持的应用

### 终端应用
- Terminal (macOS默认)
- iTerm
- Hyper
- Alacritty
- kitty
- Warp
- WezTerm
- Tabby
- Ghostty

### 编辑器应用
- TextEdit (macOS默认)
- Xcode
- Visual Studio Code
- Visual Studio Code - Insiders
- Atom
- Sublime Text
- VSCodium
- BBEdit
- TextMate
- CotEditor
- MacVim
- JetBrains系列 (AppCode, CLion, GoLand, IntelliJ IDEA, PhpStorm, PyCharm, RubyMine, WebStorm, Android Studio, Fleet)
- Typora
- Nova
- Cursor
- notepad--
- neovim

## 安装方法

从[GitHub Releases](https://github.com/tekintian/QuickLauncher/releases)页面下载最新版本并安装。

## 快速开始

### 🚀 安装后立即使用

1. **下载安装**: 从[GitHub Releases](https://github.com/tekintian/QuickLauncher/releases)下载最新版本

2. **首次设置**: 
   - 打开系统偏好设置 → 扩展 → Finder扩展
   - 启用"QuickLauncher"扩展

3. **立即使用**:
   - 在Finder中右键任意文件夹
   - 选择"Open in Terminal"在终端中打开
   - 选择"Open in Editor"在编辑器中打开

### ⚡ 开发者快速构建

```bash
# 克隆项目
git clone https://github.com/tekintian/QuickLauncher.git
cd QuickLauncher

# 快速构建（推荐）
./build_local.sh

# 或者使用优化的快速构建脚本（包含体积优化）
./quick_build.sh --signing-mode adhoc terminal

# 运行应用
open build/Build/Products/Release/QuickLauncher.app
```

## 配置和常见问题

请查看[配置文档](./Resources/README-Config.md)了解详细设置和常见问题解答。

### 📚 构建文档
- [快速构建指南](./docs/QUICK_BUILD_GUIDE.md) - 开发者必读
- [详细构建说明](./docs/BUILD_INSTRUCTIONS.md) - 完整构建流程
- [构建故障排除](./docs/BUILD_TROUBLESHOOTING.md) - 常见问题解决

## 技术架构

QuickLauncher使用Swift语言开发，基于macOS 10.15及以上版本构建。项目采用模块化设计，主要组件包括：

- **主应用**：提供用户界面和首选项设置
- **QuickLauncherCore**：核心功能库，处理终端/编辑器启动逻辑
- **Finder扩展**：提供上下文菜单集成
- **LaunchManager**：现代化的应用启动管理

## 开发依赖

- Swift 5.3+
- macOS 10.15+
- ShortcutRecorder (本地依赖)

## 构建说明

项目提供了多种构建脚本，方便开发和发布：

```bash
# 开发构建（跳过签名）
./build_local.sh no-sign

# 优化构建（需要有效证书）
./build_local.sh

# 快速测试编译
./build_test.sh
```

## 📚 项目文档

### 📖 用户文档
- [🚀 快速入门](./QUICK_START.md) - 5分钟开始使用
- [📋 完整配置说明](./Resources/README-Config.md) - 详细设置和配置
- [🔄 更新日志](./CHANGELOG.md) - 版本更新记录

### 👨‍💻 开发者文档
- [🛠️ 构建指南](./docs/BUILD_INSTRUCTIONS.md) - 完整构建说明
- [⚡ 快速构建](./docs/QUICK_BUILD_GUIDE.md) - 开发者构建脚本
- [🔧 故障排除](./docs/BUILD_TROUBLESHOOTING.md) - 常见问题解决
- [🏗️ 架构说明](./docs/REFACTORING_SUMMARY.md) - 项目重构总结

### 📋 项目治理
- [🤝 贡献指南](./CONTRIBUTING.md) - 如何参与项目贡献
- [🔒 安全政策](./SECURITY.md) - 安全漏洞报告和政策
- [📄 许可证](./LICENSE) - MIT许可证条款

## 🌟 支持项目

开源项目需要您的支持才能长期发展。如果您喜欢QuickLauncher，请考虑通过以下方式支持：

### 💝 赞助支持
通过成为赞助商支持项目发展，您的用户图标或公司标志将显示在README中，并链接到您的主页。

| 支付宝 AliPay | 微信支付 WeChat Pay |
| --- | --- |
| <img src="./Resources/alipay.jpg" width="50%"> | <img src="./Resources/weChatPay.jpg" width="50%"> |

## 关于作者

本项目由**tekintian** 维护和开发。tekintian拥有多年的软件开发经验，专注于macOS/windows/Mobile应用开发、Web开发和信息化系统定制。

- **邮箱**：tekin.tian@gmail.com
- **个人网站**：[https://dev.tekin.cn](https://dev.tekin.cn)
- **QQ**：932256355

### 专业服务

提供专业的信息化软件定制开发服务，包括：

- macOS应用开发与优化
- Web应用开发（前后端一体化）
- 企业信息化系统定制
- 软件架构设计与重构
- 性能优化与系统集成

如有合作需求，欢迎通过以上联系方式进行咨询。

### 参考项目

- [Ji4n1ng/OpenInTerminal](https://github.com/Ji4n1ng/OpenInTerminal)
- [jbtule/cdto](https://github.com/jbtule/cdto)
- [es-kumagai/OpenTerminal](https://github.com/es-kumagai/OpenTerminal)
- [tingraldi/SwiftScripting](https://github.com/tingraldi/SwiftScripting)
- [onmyway133/FinderGo](https://github.com/onmyway133/FinderGo)
- [Caldis/Mos](https://github.com/Caldis/Mos/)

## 许可证

QuickLauncher遵循MIT许可证发布。