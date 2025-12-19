//
//  DefaultsManager.swift
//  QuickLauncherCore
//
//  Created by Jianing Wang on 2019/10/14.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Foundation

public class DefaultsManager {
    
    public static var shared = DefaultsManager()
    
    // MARK: - Preferences - General
    
    public var isFirstSetup: Bool {
        get {
            return Defaults[.firstSetup]
        }
        
        set {
            Defaults[.firstSetup] = newValue
        }
    }
    
    public var isLaunchAtLogin: Bool {
        get {
            return Defaults[.launchAtLogin]
        }
        
        set {
            Defaults[.launchAtLogin] = newValue
        }
    }
    
    public var isQuickToggle: Bool {
        get {
            return Defaults[.quickToggle]
        }
        
        set {
            Defaults[.quickToggle] = newValue
        }
    }
    
    public var quickToggleType: QuickToggleType? {
        get {
            guard let stringValue = Defaults[.quickToggleType] else { return nil }
            return QuickToggleType(rawValue: stringValue)
        }
        
        set {
            Defaults[.quickToggleType] = newValue?.rawValue
        }
    }
    
    public var isHideStatusItem: Bool {
        get {
            return Defaults[.hideStatusItem]
        }
        
        set {
            Defaults[.hideStatusItem] = newValue
        }
    }
    
    public var isHideContextMenuItems: Bool {
        get {
            return Defaults[.hideContextMenuItems]
        }
        
        set {
            Defaults[.hideContextMenuItems] = newValue
        }
    }
    
    public var defaultTerminal: App? {
        get {
            guard let terminalName = Defaults[.defaultTerminal] else { return nil }
            let app = App(name: terminalName, type: .terminal)
            return app
        }
        
        set {
            guard let newValue = newValue else { return }
            Defaults[.defaultTerminal] = newValue.name
        }
    }
    
    public var defaultEditor: App? {
        get {
            guard let editorName = Defaults[.defaultEditor] else { return nil }
            let app = App(name: editorName, type: .editor)
            return app
        }
        
        set {
            guard let newValue = newValue else { return }
            Defaults[.defaultEditor] = newValue.name
        }
    }
    
    // MARK: - Language Configuration
    
    public var selectedLanguage: String {
        get {
            return Defaults[.selectedLanguage] ?? "auto" // 默认跟随系统
        }
        
        set {
            Defaults[.selectedLanguage] = newValue
        }
    }
    
    public var availableLanguages: [(code: String, name: String, localizedName: String)] {
        return [
            ("auto", "Auto", NSLocalizedString("Language Auto", comment: "Auto detect language")),
            ("en", "English", "English"),
            ("zh-Hans", "简体中文", "简体中文"),
            ("de", "Deutsch", "Deutsch"),
            ("es", "Español", "Español"),
            ("fr", "Français", "Français"),
            ("it", "Italiano", "Italiano"),
            ("ko", "한국어", "한국어"),
            ("ru", "Русский", "Русский"),
            ("tr", "Türkçe", "Türkçe")
        ]
    }
    
    public func setLanguage(_ languageCode: String) {
        selectedLanguage = languageCode
        
        // 应用语言更改
        if languageCode == "auto" {
            // 重置为系统语言
            UserDefaults.standard.removeObject(forKey: "AppleLanguages")
        } else {
            // 设置指定语言
            UserDefaults.standard.set([languageCode], forKey: "AppleLanguages")
        }
        
        UserDefaults.standard.synchronize()
        
        // 发送通知提示需要重启应用
        NotificationCenter.default.post(name: Notification.Name("LanguageDidChange"), object: nil)
    }
    
    public var liteDefaultTerminal: String? {
        get {
            return Defaults[.liteDefaultTerminal]
        }
        
        set {
            Defaults[.liteDefaultTerminal] = newValue
        }
    }
    
    public var liteDefaultEditor: String? {
        get {
            return Defaults[.liteDefaultEditor]
        }
        
        set {
            Defaults[.liteDefaultEditor] = newValue
        }
    }
    
    // MARK: - Preferences - Custom
    
    public func getNewOption(_ app: SupportedApps) -> NewOptionType? {
        var option: String?
        switch app {
        case .iTerm:
            option = Defaults[.iTermNewOption]
        default:
            return nil
        }
        return option.flatMap { NewOptionType(rawValue: $0) }
    }
    
    public func setNewOption(_ app: SupportedApps, _ newOption: NewOptionType) {
        switch app {
        case .iTerm:
            Defaults[.iTermNewOption] = newOption.rawValue
            let option = newOption == .window ? "true" : "false"
            let source = """
            do shell script "defaults write \(SupportedApps.iTerm.bundleId) OpenFileInNewWindows -bool \(option)"
            """
            let script = NSAppleScript(source: source)!
            var error: NSDictionary?
            script.executeAndReturnError(&error)
            if error != nil {
                logw("Setting iTerm new option failed: \(String(describing: error))")
            }
        default:
            return
        }
    }
    
    public var customMenuOptions: [App]? {
        get {
            guard let appsData = Defaults[.customMenuOptions] else { return nil }
            do {
                let apps = try decoder.decode([App].self, from: appsData)
                return apps
            } catch {
                return nil
            }
        }
        
        set {
            guard let newValue = newValue else { return }
            do {
                let data = try encoder.encode(newValue)
                Defaults[.customMenuOptions] = data
            } catch {
                logw("save custom menu options failed: \(error)")
            }
        }
    }
    
    public var isCustomMenuApplyToToolbar: Bool {
        get {
            return Defaults[.customMenuApplyToToolbar]
        }
        
        set {
            Defaults[.customMenuApplyToToolbar] = newValue
        }
    }
    
    public var isCustomMenuApplyToContext: Bool {
        get {
            return Defaults[.customMenuApplyToContext]
        }
        
        set {
            Defaults[.customMenuApplyToContext] = newValue
        }
    }
    
    public var customMenuIconOption: CustomMenuIconOption {
        get {
            let optionValue = Defaults[.customMenuIconOption] ?? "no"
            let option = CustomMenuIconOption(rawValue: optionValue)
            return option ?? .no
        }
        
        set {
            Defaults[.customMenuIconOption] = newValue.rawValue
        }
    }
    
    public var isPathEscaped: Bool {
        get {
            return Defaults[.pathEscapeOption]
        }
        
        set {
            Defaults[.pathEscapeOption] = newValue
        }
    }

    public func getAppIcon(_ app: App) -> NSImage? {
        switch customMenuIconOption {
        case .no:
            return nil
        case .simple:
            if app.type == .terminal {
                return NSImage(named: "context_menu_icon_terminal")
            } else {
                return NSImage(named: "context_menu_icon_editor")
            }
        case .original:
            if SupportedApps.isSupported(app),
               let icon = NSImage(named: app.name) {
                return icon
            }
            if app.type == .terminal {
                return NSImage(named: "context_menu_icon_color_terminal")
            } else {
                return NSImage(named: "context_menu_icon_color_editor")
            }
        }
    }
    
    // MARK: - Open Commands
    
    public var kittyCommand: String {
        get {
            return Defaults[.kittyCommand] ?? AppConfiguration.Commands.kitty
        }
        
        set {
            Defaults[.kittyCommand] = newValue
        }
    }

    public var neovimCommand: String {
        get {
            return Defaults[.neovimCommand] ?? AppConfiguration.Commands.neovim
        }
        
        set {
            Defaults[.neovimCommand] = newValue
        }
    }

    public func getOpenCommand(_ app: App, escapeCount: Int = 1) -> String {
        if SupportedApps.is(app, is: .alacritty) {
            return AppConfiguration.Commands.alacritty
        } else if SupportedApps.is(app, is: .kitty) {
            return kittyCommand
        } else if SupportedApps.is(app, is: .wezterm) {
            return AppConfiguration.Commands.wezterm
        } else if SupportedApps.is(app, is: .tabby) {
            return AppConfiguration.Commands.tabby
        } else if SupportedApps.is(app, is: .neovim) {
            return neovimCommand
        } else {
            return "open -a \(app.name.nameSpaceEscaped(escapeCount))"
        }
    }
    
    // MARK: - Advanced Settings
    
    public func firstSetup() {
        guard isFirstSetup == false else { return }
        logw("First Setup")
        isFirstSetup = true
        isLaunchAtLogin = false
        isQuickToggle = false
        quickToggleType = .openWithDefaultTerminal
        isHideStatusItem = false
        isHideContextMenuItems = false
        defaultTerminal = SupportedApps.terminal.app
        defaultEditor = SupportedApps.textEdit.app
        selectedLanguage = "auto" // 默认跟随系统语言
        setNewOption(.terminal, .window)
        setNewOption(.iTerm, .window)
        isCustomMenuApplyToToolbar = false
        isCustomMenuApplyToContext = false
        customMenuIconOption = .no
        isPathEscaped = true
        Defaults.synchronize()
    }
    
    public func removeAllUserDefaults() {
        logw("Remove all UserDefaults")
        Defaults.removePersistentDomain(forName: AppConfiguration.Identifiers.group)
        Defaults.synchronize()
    }
    
}
