# CI Framework Symlink Fix

## 问题描述

在CI构建过程中发现以下问题：
1. **大小异常增加**：删除了11个库文件后，app大小从14M增加到17M（2025-12-20第50次CI仍然存在）
2. **Symlink损坏**：CI显示symlink正确，但实际可能变成实际文件
3. **du命令错误计算**：当symlink损坏时，文件大小计算异常

## 根本原因分析

### 原始构建结构
Xcode构建的Framework结构中：
```
QuickLauncherCore.framework/
├── QuickLauncherCore -> Versions/Current/QuickLauncherCore (symlink)
├── Resources -> Versions/Current/Resources (symlink)
└── Versions/
    ├── A/ (目录，包含实际文件)
    └── Current/ (目录，而不是symlink!)
```

### CI脚本的问题
之前的CI脚本在某个环节破坏了symlinks：
- 可能在文件复制或处理过程中symlink变成实际文件
- 导致du命令重复计算文件大小
- 即使CI显示symlink正确，实际文件系统中的symlink可能已损坏

## 解决方案

### 1. 智能检测和处理
```bash
# 检查Versions/Current的类型
if [ -L "$FRAMEWORKS_DIR/Versions/Current" ]; then
    # 已经是symlink，不需要修改
    echo "Framework structure is correct"
elif [ -d "$FRAMEWORKS_DIR/Versions/Current" ]; then
    # 是目录，需要转换为symlink
    mv "Versions/Current" "Versions/A"
    ln -sf A Current
fi
```

### 2. 分阶段构建和打包
```bash
# 阶段1：保存原始构建
cp -R "$APP_PATH" "QuickLauncher-Intel-Original.app"

# 阶段2：Framework修复
# (智能symlink处理)

# 阶段3：Framework修复后的打包
tar -cJf "QuickLauncher-Intel-PostFrameworkFix.tar.xz" "QuickLauncher-Intel.app"

# 阶段4：库清理
./scripts/clean-libs.sh "QuickLauncher-Intel.app"

# 阶段5：最终打包
tar -cJf "QuickLauncher-Intel-Final.tar.xz" "QuickLauncher-Intel.app"
```

### 3. 使用.xz格式避免压缩问题
- GitHub Actions的artifact可能破坏symlinks
- 使用`tar -cJf`创建.xz压缩包，完美保留symlinks
- 提供多个阶段的包供对比分析

## 新的CI工作流程

1. **原始构建保存**：`QuickLauncher-Intel-Original.tar.xz`
2. **Framework修复后**：`QuickLauncher-Intel-PostFrameworkFix.tar.xz`
3. **最终版本**：`QuickLauncher-Intel-Final.tar.xz`

## 验证方法

### 自动验证
- CI中运行`verify-artifact.sh`检查每个包的symlink结构
- 验证symlink指向是否正确
- 检查文件大小变化

### 本地测试
```bash
# 运行本地CI工作流测试
./scripts/test-ci-workflow.sh

# 验证特定包
./scripts/verify-artifact.sh QuickLauncher-Intel-Final
```

## 预期结果

- ✅ Symlinks在压缩和下载过程中保持正确
- ✅ 删除库文件后app大小应该减少，而不是增加
- ✅ Framework结构符合Apple标准
- ✅ 提供完整的构建过程追踪

## 文件清单

### 新增/修改的文件
- `.github/workflows/ci.yml` - 更新的CI工作流
- `scripts/verify-artifact.sh` - 包验证脚本
- `scripts/test-ci-workflow.sh` - 本地CI测试脚本
- `scripts/test-symlinks.sh` - symlink逻辑测试脚本
- `docs/CI-Framework-Fix.md` - 本文档

### 生成的artifacts
- `QuickLauncher-Intel-Original.tar.xz` - 原始构建
- `QuickLauncher-Intel-PostFrameworkFix.tar.xz` - Framework修复后
- `QuickLauncher-Intel-Final.tar.xz` - 最终版本

这个修复确保了symlink在整个CI流程中保持完整，并提供了详细的构建过程追踪和验证机制。