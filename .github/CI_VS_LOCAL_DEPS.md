# GitHub CI vs 本地依赖配置说明

## 🎯 目标

实现在不同环境下使用不同的依赖源：
- **GitHub CI**: 使用远程GitHub依赖 `https://github.com/ShortCutRecorder/ShortcutRecorder.git`
- **本地开发**: 使用本地依赖 `./LocalDependencies/ShortcutRecorder`

## 📁 配置文件

### 本地开发 (Package.swift)
```swift
dependencies: [
    // 使用本地ShortcutRecorder依赖，避免每次构建时访问远程仓库
    .package(path: "./LocalDependencies/ShortcutRecorder")
]
```

### GitHub CI (CI环境自动生成)
CI workflow会临时修改Package.swift为：
```swift
dependencies: [
    // Use remote ShortcutRecorder dependency for CI builds
    .package(url: "https://github.com/ShortCutRecorder/ShortcutRecorder.git", from: "3.4.0")
]
```

## 🔄 工作流程

### 本地开发
1. 使用本地依赖，开发速度快
2. 无需网络连接即可编译
3. 可以修改ShortcutRecorder源码进行调试

### GitHub CI
1. 构建开始时：
   - 备份原始 `Package.swift` → `Package-local.swift`
   - 创建CI专用的 `Package.swift` 使用远程依赖
2. 构建完成后：
   - 恢复原始 `Package.swift`

## 📋 详细步骤

### CI Workflow 修改内容

1. **移除submodule checkout**
   ```yaml
   - name: Checkout
     uses: actions/checkout@v4
   ```

2. **添加依赖切换步骤**
   ```yaml
   - name: Update Package Dependencies for CI
     run: |
       echo "📦 Updating Package.swift to use remote dependencies for CI..."
       # 生成CI专用的Package.swift
       cat > Package-ci.swift << 'EOF'
       // CI专用配置 - 使用远程依赖
       .package(url: "https://github.com/ShortCutRecorder/ShortcutRecorder.git", from: "3.4.0")
       EOF
       
       # 备份并切换
       cp Package.swift Package-local.swift
       cp Package-ci.swift Package.swift
   ```

3. **构建完成后恢复**
   ```yaml
   # 构建完成后
   if [ -f "Package-local.swift" ]; then
     echo "🔄 Restoring original Package.swift..."
     cp Package-local.swift Package.swift
   fi
   ```

## 🎯 优势

### 本地开发优势
- **速度快**: 本地依赖，无需网络下载
- **稳定性**: 不受远程仓库状态影响
- **调试便利**: 可以修改依赖源码
- **离线开发**: 无需网络连接

### CI环境优势  
- **干净环境**: 每次获取最新的远程依赖
- **版本一致**: 使用指定的版本范围 (from: "3.4.0")
- **自动化**: 无需维护submodule
- **简单配置**: 不需要复杂的submodule设置

## 🔧 验证方法

### 本地验证
```bash
# 检查本地依赖
swift package resolve
# 应该显示本地ShortcutRecorder路径

# 构建测试
xcodebuild -project QuickLauncher.xcodeproj -scheme QuickLauncher clean build
```

### CI验证
CI日志中应该显示：
```
📦 Updating Package.swift to use remote dependencies for CI...
🔄 Restoring original Package.swift...
```

## 📝 注意事项

1. **不要提交** Package-local.swift 文件（它在构建过程中创建）
2. **保持同步**: 本地LocalDependencies/ShortcutRecorder应与远程版本同步
3. **版本管理**: 如果需要更新ShortcutRecorder版本，同时更新：
   - 本地submodule
   - CI中的版本号 (`from: "3.4.0"`)

## 🔄 同步本地和远程依赖

如果需要更新本地依赖：
```bash
# 更新submodule到最新版本
cd LocalDependencies/ShortcutRecorder
git pull origin master
cd ../..

# 提交submodule更新
git add LocalDependencies/ShortcutRecorder
git commit -m "Update ShortcutRecorder to latest version"
```

然后同步更新CI中的版本号。