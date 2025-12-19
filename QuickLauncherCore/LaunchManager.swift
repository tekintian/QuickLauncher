//
//  LaunchManager.swift
//  QuickLauncher
//  tekintian@gmail.com
//  Copyright © 2025 dev.tekin.cn. All rights reserved.
//  created by TekinTian 2025-12-18

import Foundation
import ServiceManagement

/// Launch相关错误
enum LaunchError: Error {
    case failedToSetLoginItem
    case bundleIdentifierNotFound
}

extension LaunchError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .failedToSetLoginItem:
            return NSLocalizedString("Failed to set login item", comment: "")
        case .bundleIdentifierNotFound:
            return NSLocalizedString("Bundle identifier not found", comment: "")
        }
    }
}

/// 现代启动管理器，替代 Helper 工具
@available(macOS 13.0, *)
class LaunchManager {
    static let shared = LaunchManager()
    
    var isLaunchAtLoginEnabled = false
    
    private init() {
        // 从UserDefaults获取状态，因为SMLoginItemSetEnabled没有查询功能
        let isEnabled = Defaults[DefaultsKeys.launchAtLogin]
        self.isLaunchAtLoginEnabled = isEnabled
    }
    
    /// 检查登录项状态
    func checkLoginItemStatus() {
        // 使用传统的ServiceManagement API以支持Swift 5.0
        // 从UserDefaults获取状态，因为SMLoginItemSetEnabled没有查询功能
        let isEnabled = Defaults[DefaultsKeys.launchAtLogin]
        DispatchQueue.main.async {
            self.isLaunchAtLoginEnabled = isEnabled
        }
    }
    
    /// 设置登录启动
    func setLaunchAtLogin(_ enabled: Bool) throws {
        // SMLoginItemSetEnabled只适用于Helper应用，不适用于主应用
        // 对于主应用，这个API总是返回false，导致崩溃问题
        // 委托给LegacyLaunchManager处理
        throw LaunchError.failedToSetLoginItem
    }
    
    /// 检查应用是否已经在运行
    static func isMainAppRunning() -> Bool {
        let runningApps = NSWorkspace.shared.runningApplications
        return runningApps.contains { app in
            app.bundleIdentifier == AppConfiguration.AppInfo.bundleIdentifier
        }
    }
    
    /// 确保只有一个应用实例在运行
    static func ensureSingleInstance() -> Bool {
        if isMainAppRunning() {
            // 应用已在运行，激活它并退出当前实例
            NSWorkspace.shared.runningApplications
                .first { $0.bundleIdentifier == AppConfiguration.AppInfo.bundleIdentifier }?
                .activate(options: [.activateIgnoringOtherApps])
            return false
        }
        return true
    }
}

/// 向后兼容的启动管理器（适用于 macOS 12 及以下）
@available(macOS, deprecated: 13.0, message: "Use LaunchManager on macOS 13+ instead")
class LegacyLaunchManager {
    static let shared = LegacyLaunchManager()
    
    var isLaunchAtLoginEnabled = false
    
    private init() {
        // 从UserDefaults获取状态，因为SMLoginItemSetEnabled没有查询功能
        let isEnabled = Defaults[DefaultsKeys.launchAtLogin]
        self.isLaunchAtLoginEnabled = isEnabled
    }
    
    /// 检查登录项状态
    func checkLoginItemStatus() {
        let isEnabled = checkLoginItemStatusSync()
        DispatchQueue.main.async {
            self.isLaunchAtLoginEnabled = isEnabled
        }
    }
    
    /// 同步检查登录项状态
    func checkLoginItemStatusSync() -> Bool {
        // 使用旧的 LSSharedFileList API，正确处理内存管理
        return autoreleasepool {
            let loginItemsRef = kLSSharedFileListSessionLoginItems.takeRetainedValue()
            guard let loginItems = LSSharedFileListCreate(nil, loginItemsRef, nil)?.takeRetainedValue() else {
                return false
            }
            
            guard let loginItemsSnapshot = LSSharedFileListCopySnapshot(loginItems, nil) else {
                return false
            }
            
            let loginItemsArray = loginItemsSnapshot.takeRetainedValue() as! [LSSharedFileListItem]
            let bundleIdentifier = AppConfiguration.AppInfo.bundleIdentifier
            
            for item in loginItemsArray {
                let found = autoreleasepool { () -> Bool in
                    if let itemURLRef = LSSharedFileListItemCopyResolvedURL(item, 0, nil) {
                        let itemURL = itemURLRef.takeRetainedValue() as URL
                        if let bundle = Bundle(url: itemURL),
                           bundle.bundleIdentifier == bundleIdentifier {
                            return true
                        }
                    }
                    return false
                }
                if found {
                    return true
                }
            }
            
            return false
        }
    }
    
    /// 设置登录启动
    func setLaunchAtLogin(_ enabled: Bool) {
        print("🔧 setLaunchAtLogin called with enabled: \(enabled)")
        
        // 使用更简单安全的方法
        let bundleIdentifier = AppConfiguration.AppInfo.bundleIdentifier
        let appUrl = Bundle.main.bundleURL
        
        print("🔧 Bundle identifier: \(bundleIdentifier)")
        print("🔧 App URL: \(appUrl)")
        
        // 直接使用Shell脚本方式处理登录项，避免LSSharedFileList API的内存问题
        let script: String
        if enabled {
            script = """
            tell application "System Events"
                get the name of every login item
            end tell
            tell application "System Events"
                make login item at end with properties {path:"\(appUrl.path)", hidden:false}
            end tell
            """
        } else {
            script = """
            tell application "System Events"
                get the name of every login item
            end tell
            tell application "System Events"
                delete every login item whose name is "QuickLauncher"
            end tell
            """
        }
        
        let appleScript = NSAppleScript(source: script)
        var errorInfo: NSDictionary?
        _ = appleScript?.executeAndReturnError(&errorInfo)
        
        if let error = errorInfo {
            print("❌ AppleScript failed: \(error)")
        } else {
            print("✅ Login item \(enabled ? "added" : "removed") successfully")
        }
        
        // 立即更新状态以确保同步性
        self.isLaunchAtLoginEnabled = enabled
        print("🔧 Updated isLaunchAtLoginEnabled to: \(enabled)")
        
        // 同步更新 UserDefaults
        Defaults[DefaultsKeys.launchAtLogin] = enabled
        print("🔧 Updated UserDefaults")
    }
    
    /// 检查应用是否已经在运行
    static func isMainAppRunning() -> Bool {
        let runningApps = NSWorkspace.shared.runningApplications
        return runningApps.contains { app in
            app.bundleIdentifier == AppConfiguration.AppInfo.bundleIdentifier
        }
    }
    
    /// 确保只有一个应用实例在运行
    static func ensureSingleInstance() -> Bool {
        if isMainAppRunning() {
            // 应用已在运行，激活它并退出当前实例
            NSWorkspace.shared.runningApplications
                .first { $0.bundleIdentifier == AppConfiguration.AppInfo.bundleIdentifier }?
                .activate(options: [.activateIgnoringOtherApps])
            return false
        }
        return true
    }
}

/// 统一的启动管理器接口
public class UnifiedLaunchManager: NSObject {
    public var isLaunchAtLoginEnabled = false
    
    private var legacyManager: LegacyLaunchManager?
    
    public static let shared = UnifiedLaunchManager()
    
    private override init() {
        // 为了兼容性，只使用 LegacyLaunchManager
        legacyManager = LegacyLaunchManager.shared
        // 同步获取当前登录项状态
        isLaunchAtLoginEnabled = legacyManager?.checkLoginItemStatusSync() ?? false
    }
    
    /// 设置登录启动
    public func setLaunchAtLogin(_ enabled: Bool) throws {
        // 为了兼容性，只使用 LegacyLaunchManager
        legacyManager?.setLaunchAtLogin(enabled)
        
        // 更新本地状态
        isLaunchAtLoginEnabled = enabled
        
        // 同步更新 UserDefaults
        Defaults[DefaultsKeys.launchAtLogin] = enabled
    }
    
    /// 设置登录启动（同步版本，用于Swift 5.0兼容）
    public func setLaunchAtLoginSync(_ enabled: Bool) throws {
        // 为了兼容性，只使用 LegacyLaunchManager
        legacyManager?.setLaunchAtLogin(enabled)
        
        // 更新本地状态
        isLaunchAtLoginEnabled = enabled
        
        // 同步更新 UserDefaults
        Defaults[DefaultsKeys.launchAtLogin] = enabled
    }
    
    /// 确保只有一个应用实例在运行
    public static func ensureSingleInstance() -> Bool {
        return LegacyLaunchManager.ensureSingleInstance()
    }
}