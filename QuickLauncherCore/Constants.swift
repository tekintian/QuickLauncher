//
//  Config.swift
//  QuickLauncher
//
//  Created by tekintian@gmail.com
//  Copyright © 2025 Tekin.cn. All rights reserved.
//

import Foundation

// MARK: - App Configuration
/// 应用配置统一管理
public struct AppConfiguration {
    
    /// 应用标识符
    public struct Identifiers {
        public static let group = "group.cn.tekin.QuickLauncher"
        public static let quickLauncher = "cn.tekin.QuickLauncher"
        public static let quickLauncherEditor = "cn.tekin.QuickLauncherEditor"
        public static let finder = "com.apple.Finder"
        public static let finderExtension = "cn.tekin.app.QuickLauncher.QuickLauncherFinderExtension"
    }
    
    /// 应用命令配置
    public struct Commands {
        public static let alacritty = "open -na Alacritty --args --working-directory"
        public static let kitty = "open -na kitty --args --single-instance --instance-group 1 --directory"
        public static let wezterm = "open -na wezterm --args start --cwd"
        public static let tabby = "open -na tabby --args --directory"
        public static let neovim = "open -na kitty --args /opt/homebrew/bin/nvim PATH"
    }
    
    /// 脚本名称
    public struct Scripts {
        public static let generalScript = "generalScript"
        public static let terminalNewTabScript = "terminalNewTabScript"
    }
    
    /// UserDefaults键名
    public struct UserDefaultsKeys {
        public static let defaultTerminalShortcut = "defaultTerminalShortcut"
        public static let defaultEditorShortcut = "defaultEditorShortcut"
        public static let copyPathShortcut = "copyPathShortcut"
    }
    
    /// 应用信息
    public struct AppInfo {
        public static let bundleIdentifier = AppConfiguration.Identifiers.quickLauncher
        public static let name = "QuickLauncher"
        public static let version = "3.0.0"
    }
}

// MARK: - Legacy compatibility (deprecated)
// Use AppConfiguration from the new unified system instead
@available(*, deprecated, message: "Use AppConfiguration instead")
struct Constants {
    
    /// Identifier
    @available(*, deprecated, message: "Use AppConfiguration.Identifiers instead")
    struct Id {
        static let Group = AppConfiguration.Identifiers.group
        @available(*, deprecated, message: "Lite versions have been removed")
        static let QuickLauncherLite = "cn.tekin.app.QuickLauncher-Lite"
        @available(*, deprecated, message: "Lite versions have been removed")
        static let OpenInEditorLite = "cn.tekin.app.OpenInEditor-Lite"
        static let Finder = AppConfiguration.Identifiers.finder
        static let FinderExtension = AppConfiguration.Identifiers.finderExtension
        static let QuickLauncher = AppConfiguration.Identifiers.quickLauncher
        static let OpenInEditor = AppConfiguration.Identifiers.quickLauncherEditor
        static let CustomInputViewController = "CustomInputViewController"
    }
    
    /// General AppleScript for opening apps
    static let generalScript = "generalScript"
    /// AppleScript for opening a new tab in Terminal
    static let terminalNewTabScript = "terminalNewTabScript"
    
    @available(*, deprecated, message: "Use AppConfiguration.Commands instead")
    struct Commands {
        static let alacritty = "open -na Alacritty --args --working-directory"
        static let kitty = "open -na kitty --args --single-instance --instance-group 1 --directory"
        static let wezterm = "open -na wezterm --args start --cwd"
        static let tabby = "open -na tabby --args --directory"
        /// "Open In NeoVim" only supports Alacritty, wezterm, and kitty.
        static let neovim = "open -na kitty --args /opt/homebrew/bin/nvim PATH"
//        static let neovim = "open -na wezterm --args start /opt/homebrew/bin/nvim PATH"
//        static let neovim = "open -na Alacritty --args -e /opt/homebrew/bin/nvim PATH"

    }
    
    @available(*, deprecated, message: "Use AppConfiguration.UserDefaultsKeys instead")
    struct Key {
        static let defaultTerminalShortcut = "defaultTerminalShortcut"
        static let defaultEditorShortcut = "defaultEditorShortcut"
        static let copyPathShortcut = "copyPathShortcut"
    }
    
    @available(*, deprecated, message: "Use proper constants instead")
    struct Preferences {
        static let storyboard = "Preferences"
    }
    
    @available(*, deprecated, message: "Use AppConfiguration.Scripts instead")
    struct Scripts {
        static let general = AppConfiguration.Scripts.generalScript
        static let terminalNewTab = AppConfiguration.Scripts.terminalNewTabScript
    }
    
}

public enum QuickToggleType: String {
    
    case openWithDefaultTerminal
    case openWithDefaultEditor
    case copyPathToClipboard
    
    public var name: String {
        switch self {
        case .openWithDefaultTerminal:
        return NSLocalizedString("menu.open_with_default_terminal", comment: "Open with default Terminal")
        case .openWithDefaultEditor:
        return NSLocalizedString("menu.open_with_default_editor", comment: "Open with default Editor")
        case .copyPathToClipboard:
        return NSLocalizedString("menu.copy_path_to_clipboard", comment: "Copy path to Clipboard")
        }
    }
}

public enum NewOptionType: String {
    case tab
    case window
}

let encoder = JSONEncoder()
let decoder = JSONDecoder()

public enum CustomMenuIconOption: String {
    case no
    case simple
    case original
}
