<div align="center">
  <img width="80%" src="Resources/app-icon.png"><br/><br/>
  <a href="./README.md">English</a> | <a href="./Resources/README-zh.md">中文</a> 
</div>

# QuickLauncher

A powerful macOS utility that enhances productivity by allowing you to quickly open terminals or code editors directly from the Finder context menu. Eliminate the need to manually navigate through directories in terminal applications and streamline your workflow.

## ✨ Key Features

QuickLauncher is a refined and optimized version based on Ji4n1ng's OpenInTerminal project, with significant improvements:

- **🚀 Size Optimization**: Reduced from 32MB to 22MB for faster downloads and storage
- **🧠 Memory Management**: Enhanced memory efficiency and reduced resource usage
- **🌐 Language Support**: Added multi-language configuration with 9 supported languages
- **📦 Local Dependencies**: Replaced network dependencies with local ones for better stability
- **⚡ Unified Error Handling**: Comprehensive error management for improved user experience
- **🎯 Modern Launch Management**: Advanced launch system replacing helper applications

## 🎯 Core Functionality

| Feature | Description |
| --- | --- |
| **Quick Terminal Access** | Open terminals directly from Finder context menu at current path |
| **Editor Integration** | Open files and folders in your favorite code editors |
| **Multi-Application Support** | Compatible with various terminal and editor applications |
| **Custom Applications** | Add and configure custom applications beyond supported defaults |
| **Global Shortcuts** | Execute operations quickly with configurable keyboard shortcuts |
| **Status Bar Integration** | Quick access from menu bar with customizable behavior |
| **Multi-Language Support** | Interface available in 9 languages |
| **Path Copy** | One-click copy of file/folder paths to clipboard |

## 🛠️ Supported Applications

### Terminal Applications
- **Terminal** (macOS default)
- **iTerm** - Advanced terminal emulator
- **Hyper** - Electron-based terminal
- **Alacritty** - GPU-accelerated terminal
- **kitty** - Fast, feature-rich terminal
- **Warp** - Modern, AI-powered terminal
- **WezTerm** - Cross-platform terminal
- **Tabby** - Highly configurable terminal
- **Ghostty** - Modern terminal emulator

### Editor Applications
- **TextEdit** (macOS default)
- **Xcode** - Apple's IDE
- **Visual Studio Code** - Microsoft's code editor
- **Visual Studio Code - Insiders** - VS Code preview version
- **Atom** - GitHub's text editor
- **Sublime Text** - Sophisticated text editor
- **VSCodium** - Open-source VS Code binary
- **BBEdit** - Professional text and code editor
- **TextMate** - Powerful text editor for Mac
- **CotEditor** - Lightweight text editor
- **MacVim** - Vim GUI for macOS
- **JetBrains Suite** - Professional IDEs:
  - AppCode (Objective-C/Swift)
  - CLion (C/C++)
  - GoLand (Go)
  - IntelliJ IDEA (Java)
  - PhpStorm (PHP)
  - PyCharm (Python)
  - RubyMine (Ruby)
  - WebStorm (JavaScript/TypeScript)
  - Android Studio (Android)
  - Fleet (Next-generation IDE)
- **Typora** - Minimal markdown editor
- **Nova** - Modern text editor
- **Cursor** - AI-powered code editor
- **notepad--** - Lightweight text editor
- **neovim** - Hyperextensible Vim-based editor

## 📥 Installation

### Method 1: Direct Download (Recommended)
1. Visit [GitHub Releases](https://github.com/tekintian/QuickLauncher/releases)
2. Download the latest DMG file
3. Double-click the DMG and drag the app to Applications folder
4. Launch the app and grant necessary permissions

### Method 2: Build from Source
```bash
# Clone the repository
git clone https://github.com/tekintian/QuickLauncher.git
cd QuickLauncher

# Build the application
./build_local.sh

# Run the application
open build/Build/Products/Release/QuickLauncher.app
```

## 🚀 Quick Start

### 1. Enable Finder Extension
1. Open **System Preferences** → **Extensions** → **Finder Extensions**
2. Check **QuickLauncher** to enable it

### 2. Start Using
In Finder:
1. Right-click on any folder
2. Select **"Open in Terminal"** to open in terminal
3. Select **"Open in Editor"** to open in your default editor

### 3. Menu Bar Quick Access
Click the QuickLauncher icon in the menu bar for:
- Open current folder
- Application settings
- Quick actions

## ⚙️ Configuration

### Changing Default Terminal
1. Open QuickLauncher settings
2. Go to "Terminal" tab
3. Select your preferred terminal application

### Adding Custom Editor
1. Click "Add Custom Application"
2. Choose the application
3. Set launch parameters

### Setting Keyboard Shortcuts
1. Navigate to "Shortcuts" settings
2. Set global shortcuts for common operations

## 🔧 Development

### Prerequisites
- **macOS**: 10.15+ (Catalina or higher)
- **Xcode**: 12.0+
- **Swift**: 5.3+
- **Git**

### Build Scripts
```bash
# Development build (skip signing)
./build_local.sh no-sign

# Production build (requires valid certificate)
./build_local.sh

# Quick test compilation
./build_test.sh

# Minimal build for basic functionality
./build_minimal.sh
```

### Architecture

QuickLauncher uses a modular architecture with three main components:

- **Main Application**: User interface and preferences management
- **QuickLauncherCore**: Core functionality library handling terminal/editor launch logic
- **Finder Extension**: Context menu integration for Finder
- **LaunchManager**: Modern application launch management

### Dependencies
- **Swift 5.3+**
- **ShortcutRecorder** (local dependency)
- **System Frameworks**: AppKit, FinderSync, ServiceManagement, Carbon

## 📚 Documentation

### 📖 User Documentation
- [🚀 Quick Start Guide](./QUICK_START.md) - Get started in 5 minutes
- [📋 Complete Configuration](./Resources/README-Config.md) - Detailed settings and options
- [🔄 Changelog](./CHANGELOG.md) - Version history and updates

### 👨‍💻 Developer Documentation
- [🛠️ Build Instructions](./docs/BUILD_INSTRUCTIONS.md) - Complete build guide
- [⚡ Quick Build Guide](./docs/QUICK_BUILD_GUIDE.md) - Developer build scripts
- [🔧 Troubleshooting](./docs/BUILD_TROUBLESHOOTING.md) - Common issues and solutions
- [🏗️ Architecture Summary](./docs/REFACTORING_SUMMARY.md) - Project refactoring details

### 📋 Project Governance
- [🤝 Contributing Guide](./CONTRIBUTING.md) - How to contribute
- [🔒 Security Policy](./SECURITY.md) - Security vulnerability reporting
- [📄 License](./LICENSE) - MIT License terms

## 🌟 Support the Project

Open source projects need your support to thrive long-term. If you find QuickLauncher helpful, please consider supporting its development:

### 💝 Sponsorship
Become a sponsor to support the project's continued development. Your user icon or company logo will be displayed in the README with a link to your homepage.

| Alipay | WeChat Pay |
| --- | --- |
| <img src="./Resources/alipay.jpg" width="50%"> | <img src="./Resources/weChatPay.jpg" width="50%"> |

## 📊 Technical Specifications

### System Requirements
- **macOS Version**: 10.15+ (Catalina or higher)
- **Memory**: Minimum 4GB RAM recommended
- **Storage**: 100MB available space
- **Architecture**: Universal (Intel x86_64 and Apple Silicon M1/M2)

### Performance Optimizations
- **Launch Speed**: Optimized for rapid application startup
- **Memory Usage**: Efficient memory management with minimal footprint
- **Battery Life**: Low resource consumption for extended use
- **Network Independence**: No network dependencies for core functionality

### Security Features
- **Sandbox Compliance**: Follows macOS sandboxing guidelines
- **Code Signing**: Properly signed for security
- **Privacy**: No data collection or tracking
- **Permission Model**: Minimal required permissions

## 🤝 Contributing

We welcome contributions of all types! Please see our [Contributing Guide](./CONTRIBUTING.md) for details on:
- Reporting bugs
- Requesting features
- Submitting code changes
- Documentation improvements

## 🏆 Credits

This project is maintained and developed by **tekintian**, with inspiration from:
- [Ji4n1ng/OpenInTerminal](https://github.com/Ji4n1ng/OpenInTerminal)
- [jbtule/cdto](https://github.com/jbtule/cdto)
- [es-kumagai/OpenTerminal](https://github.com/es-kumagai/OpenTerminal)
- [tingraldi/SwiftScripting](https://github.com/tingraldi/SwiftScripting)
- [onmyway133/FinderGo](https://github.com/onmyway133/FinderGo)
- [Caldis/Mos](https://github.com/Caldis/Mos/)

## 📞 Contact

- **Email**: tekin.tian@gmail.com
- **Website**: [https://dev.tekin.cn](https://dev.tekin.cn)
- **QQ**: 932256355

### Professional Services

I provide professional software development services, including:
- macOS application development and optimization
- Web application development (full-stack)
- Enterprise information system customization
- Software architecture design and refactoring
- Performance optimization and system integration

For collaboration inquiries, please contact me using the information above.

## 📄 License

QuickLauncher is released under the [MIT License](./LICENSE).

---

**⭐ If this project helps you, please consider giving it a star!**