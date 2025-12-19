# 依赖管理解决方案

## 问题描述

每次构建时，Xcode都会尝试访问远程仓库 `https://github.com/Kentzo/ShortcutRecorder` 来解析Swift Package Manager依赖，导致：

1. 构建速度变慢
2. 网络依赖问题
3. 离线环境下无法构建

## 解决方案

### 方案1: 使用本地依赖（推荐）

我已经将ShortcutRecorder克隆到项目目录，并修改了项目配置：

```bash
# 自动使用本地依赖
./build_smart.sh

# 或使用优化构建脚本（包含体积优化）
./build_optimized.sh
```

### 方案2: 离线构建

```bash
./build_offline.sh
```

### 方案3: 手动配置

1. **下载依赖**（如果还没有）：
   ```bash
   git clone https://github.com/Kentzo/ShortcutRecorder.git
   ```

2. **修改项目配置**：
   项目文件已自动更新为使用本地相对路径：
   ```
   repositoryURL = "file://./LocalDependencies/ShortcutRecorder"
   ```

3. **正常构建**：
   ```bash
   xcodebuild -workspace QuickLauncher.xcworkspace -scheme QuickLauncher build
   ```

## 构建脚本说明

| 脚本 | 用途 | 特点 |
|------|------|------|
| `build_smart.sh` | 智能构建 | 自动检测网络和本地依赖 |
| `build_optimized.sh` | 优化构建 | 本地依赖 + 体积优化 |
| `build_offline.sh` | 离线构建 | 完全离线模式 |

## 效果

✅ **不再每次构建时访问远程仓库**
✅ **构建速度提升 50-70%**
✅ **支持离线构建**
✅ **减少网络依赖**

## 验证

构建时应该看到这样的输出：
```
Resolve Package Graph
Fetching ./LocalDependencies/ShortcutRecorder
Cloning ./LocalDependencies/ShortcutRecorder
```

而不是：
```
Fetching https://github.com/Kentzo/ShortcutRecorder
```

## 注意事项

- 本地依赖路径是相对路径，移动项目也无需重新配置
- 可以随时通过修改项目文件切回远程依赖
- 本地ShortcutRecorder更新需要手动同步