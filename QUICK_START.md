# 🚀 QuickLauncher 快速入门

5分钟内开始使用QuickLauncher！

## 📦 快速安装

### 方法1: 直接下载 (推荐)
1. 访问 [GitHub Releases](https://github.com/tekintian/QuickLauncher/releases)
2. 下载最新版本的DMG文件
3. 双击DMG，将应用拖拽到Applications文件夹
4. 完成！🎉

### 方法2: Homebrew (暂未支持)
```bash
# 未来将支持
brew install --cask quicklauncher
```

## ⚡ 立即使用

### 1. 启用扩展
打开 **系统偏好设置** → **扩展** → **Finder扩展** → 勾选 **QuickLauncher**

### 2. 开始使用
在Finder中：
1. 右键点击任意文件夹
2. 选择 **"Open in Terminal"** 在终端中打开
3. 选择 **"Open in Editor"** 在编辑器中打开

### 3. 菜单栏快捷访问
点击菜单栏的QuickLauncher图标，快速访问：
- 打开当前文件夹
- 应用设置
- 常用操作

## 🛠️ 常用配置

### 更改默认终端
1. 打开QuickLauncher设置
2. 选择"Terminal"选项卡
3. 选择您偏好的终端应用

### 添加自定义编辑器
1. 点击"添加自定义应用"
2. 选择应用程序
3. 设置启动参数

### 设置快捷键
1. 进入"快捷键"设置
2. 为常用操作设置全局快捷键

## 🔧 开发者快速构建

### 前置要求
- macOS 10.15+ (Catalina或更高)
- Xcode 12.0+
- Git

### 构建步骤
```bash
# 1. 克隆项目
git clone https://github.com/tekintian/QuickLauncher.git
cd QuickLauncher

# 2. 初始化子模块
git submodule update --init --recursive

# 3. 快速构建
./build_local.sh

# 4. 运行应用
open dist/QuickLauncher.app
```

### 开发测试
```bash
# 测试编译
./build_test.sh

# 构建所有组件
./build_local.sh all

# 无签名快速构建
./build_local.sh no-sign
```

## 🎯 常见问题快速解决

### Q: Finder右键菜单没有显示？
**A**: 检查系统偏好设置 → 扩展 → Finder扩展，确保QuickLauncher已启用

### Q: 应用无法启动？
**A**: 检查系统偏好设置 → 安全性与隐私，允许来自未识别开发者的应用

### Q: 构建失败？
**A**: 
1. 检查Xcode版本: `xcodebuild -version`
2. 清理构建: `rm -rf build/`
3. 重新尝试: `./build_local.sh terminal`

### Q: 终端/编辑器未在列表中？
**A**: 使用"添加自定义应用"功能手动添加您需要的应用

## 📚 进一步学习

### 📖 详细文档
- [完整README](./README.md) - 项目详细介绍
- [构建指南](./docs/QUICK_BUILD_GUIDE.md) - 开发者构建文档
- [配置说明](./Resources/README-Config.md) - 详细配置选项
- [故障排除](./docs/BUILD_TROUBLESHOOTING.md) - 问题解决方案

### 🌟 支持的应用

#### 终端应用
- Terminal, iTerm, Hyper, Alacritty, kitty, Warp, WezTerm, Tabby, Ghostty

#### 编辑器应用  
- VS Code, Sublime Text, Xcode, TextEdit, Atom, VSCodium, BBEdit, TextMate, CotEditor, MacVim, JetBrains系列, Typora, Nova, Cursor, notepad--, neovim

### 🎉 进阶功能
- 多语言支持 (9种语言)
- 自定义应用配置
- 键盘快捷键
- 路径复制功能
- 状态栏集成

## 内置路径

日志路径
~/Library/Logs/QuickLauncher

脚本路径
$HOME/Library/Application Scripts/cn.tekin.app.QuickLauncher


## 🤝 获取帮助

- **文档**: [完整文档目录](./docs/)
- **问题反馈**: [GitHub Issues](https://github.com/tekintian/QuickLauncher/issues)
- **功能建议**: [GitHub Discussions](https://github.com/tekintian/QuickLauncher/discussions)
- **联系作者**: tekin.tian@gmail.com

## 🔗 相关链接

- [项目主页](https://github.com/tekintian/QuickLauncher)
- [作者网站](https://dev.tekin.cn)
- [更新日志](./CHANGELOG.md)
- [贡献指南](./CONTRIBUTING.md)
- [安全政策](./SECURITY.md)

---

**🎊 恭喜！您已准备好使用QuickLauncher提升工作效率！**

如果这个快速入门指南对您有帮助，请考虑给项目一个⭐️！