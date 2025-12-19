# 本地依赖配置说明

## 📦 ShortcutRecorder 本地依赖

为了完全避免每次构建时的网络访问，项目已配置使用本地的 ShortcutRecorder 依赖。

### 📍 本地依赖位置

```
LocalDependencies/ShortcutRecorder/
├── Sources/                 # 源代码
├── Package.swift           # Swift Package 配置
├── Resources/              # 资源文件
└── include/                # 公共头文件
```

### 🔧 配置文件

项目的 Swift Package 配置已更新为使用相对路径：

```plist
repositoryURL = "file://./LocalDependencies/ShortcutRecorder"
```

### 🔄 动态路径支持

构建脚本使用动态路径检测，支持项目在任何位置运行：

```bash
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
```

这样无论项目在何处，都能正确找到本地依赖。

### 🚀 使用方法

#### 1. 快速离线构建（推荐）
```bash
./build_offline_local.sh
```

#### 2. 本地开发构建
```bash
./build_local.sh           # 跳过签名（默认）
./build_local.sh sign      # 正常构建（需要签名证书）
```

#### 3. 测试构建
```bash
./build_test.sh            # 验证本地依赖配置
```

### ✅ 优势

- **零网络访问**：完全本地构建，不依赖 GitHub
- **快速构建**：省去包下载和解析时间
- **稳定性**：不受网络连接状态影响
- **可定制性**：可以修改本地依赖代码

### 🔍 验证配置

构建时应该看到以下输出：
```
Fetching ./LocalDependencies/ShortcutRecorder
Removing https://github.com/Kentzo/ShortcutRecorder
Cloning ./LocalDependencies/ShortcutRecorder
Checking out ./LocalDependencies/ShortcutRecorder at 3.4.0

Resolved source packages:
  ShortcutRecorder: ./LocalDependencies/ShortcutRecorder @ 3.4.0
```

而不是：
```
Fetching https://github.com/Kentzo/ShortcutRecorder
```

### 📁 支持的项目位置

使用相对路径后，项目可以放在任何位置：
- `/Users/username/projects/QuickLauncher/`
- `/tmp/QuickLauncher/`
- `/Volumes/data/projects/QuickLauncher/`
- 任何其他路径

构建脚本会自动检测项目根目录并正确解析相对路径。

### 📝 注意事项

1. **路径灵活**：使用相对路径，项目可以移动到任何位置
2. **版本同步**：需要手动保持本地依赖与官方版本的同步
3. **修改权限**：可以修改本地依赖代码以适应项目需求
4. **自动修复**：构建脚本会自动检测和修复本地依赖配置

### 🔄 切换回远程依赖

如需切换回远程依赖，修改 `QuickLauncher.xcodeproj/project.pbxproj`：

```plist
repositoryURL = "https://github.com/Kentzo/ShortcutRecorder"
```

或者使用脚本自动切换：
```bash
sed -i '' 's|repositoryURL = "file://./LocalDependencies/ShortcutRecorder"|repositoryURL = "https://github.com/Kentzo/ShortcutRecorder"|g' QuickLauncher.xcodeproj/project.pbxproj
```

### 🛠️ 故障排除

#### 本地依赖不存在
```bash
❌ 本地ShortcutRecorder依赖不存在
```

**解决方案**：
1. 检查 `LocalDependencies/ShortcutRecorder` 目录是否存在
2. 如果不存在，需要从 GitHub 克隆或获取本地依赖

#### 项目配置错误
```bash
❌ 项目未配置为使用本地依赖
```

**解决方案**：
1. 手动编辑 `project.pbxproj` 文件
2. 运行任何构建脚本会自动修复配置
3. 使用命令：`sed -i '' 's|repositoryURL = ".*ShortcutRecorder.*"|repositoryURL = "file://./LocalDependencies/ShortcutRecorder"|g' QuickLauncher.xcodeproj/project.pbxproj`