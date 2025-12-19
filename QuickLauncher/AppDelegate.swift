//
//  AppDelegate.swift
//  QuickLauncher
//
//  Created by Cameron Ingham on 4/17/19.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Cocoa
import QuickLauncherCore
import ShortcutRecorder
import ServiceManagement

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    // MARK: - Properties
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    @IBOutlet weak var statusBarMenu: NSMenu!
    
    // MARK: - Lifecycle
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 确保只有一个应用实例在运行
        guard UnifiedLaunchManager.ensureSingleInstance() else {
            NSApp.terminate(self)
            return
        }
        
        DefaultsManager.shared.firstSetup()
        
        // 应用语言设置
        applyLanguageSettings()
        
        addObserver()
        
        // Helper 工具已移除，无需终止
        // terminateQuickLauncherHelper()
        
        setStatusItemIcon()
        setStatusItemVisible()
        setStatusToggle()
        
        logw("")
        logw("App launched")
        logw("macOS \(ProcessInfo().operatingSystemVersionString)")
        logw("QuickLauncher Version \(AppConfiguration.AppInfo.version)")
        
        // bind global shortcuts
        bindShortcuts()
        
        do {
            // check scripts and install them if needed
            try checkScripts()
        } catch {
            logw(error.localizedDescription)
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        NSStatusBar.system.removeStatusItem(statusItem)
        
        removeObserver()
        logw("App terminated")
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            showPreferencesWindow()
        }
        return true
    }
    
}

extension AppDelegate {
    
    // MARK: - Status Bar Item
    
    func setStatusItemIcon() {
        let icon = NSImage(assetIdentifier: .StatusBarIcon)
        icon.isTemplate = true // Support Dark Mode
        DispatchQueue.main.async {
            self.statusItem.button?.image = icon
        }
    }
    
    func setStatusItemVisible() {
        let isHideStatusItem = DefaultsManager.shared.isHideStatusItem
        statusItem.isVisible = !isHideStatusItem
    }
    
    func setStatusToggle() {
        let isQuickToogle = DefaultsManager.shared.isQuickToggle
        if isQuickToogle {
            statusItem.menu = nil
            if let button = statusItem.button {
                button.action = #selector(statusBarButtonClicked)
                button.sendAction(on: [.leftMouseUp, .leftMouseDown,
                                       .rightMouseUp, .rightMouseDown])
            }
        } else {
            statusItem.menu = statusBarMenu
        }
    }
    
    @objc func statusBarButtonClicked(sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        if event.type == .rightMouseDown || event.type == .rightMouseUp
            || event.modifierFlags.contains(.control)
        {
            statusItem.menu = statusBarMenu
            statusItem.button?.performClick(self)
            statusItem.menu = nil
        } else if event.type == .leftMouseUp {
            if let quickToggleType = DefaultsManager.shared.quickToggleType {
                switch quickToggleType {
                case .openWithDefaultTerminal:
                    openDefaultTerminal()
                case .openWithDefaultEditor:
                    openDefaultEditor()
                case .copyPathToClipboard:
                    copyPathToClipboard()
                }
            }
        }
    }
    
    // MARK: - Helper methods
    // Helper application has been removed - no longer needed to terminate
    // This method is kept for backward compatibility but does nothing
    func terminateQuickLauncherHelper() {
        // Helper tool has been removed, this method is deprecated
        // Modern launch management is handled by UnifiedLaunchManager
    }
    
    func showPreferencesWindow() {
        NSApp.setActivationPolicy(.regular) // show icon in Dock
        let preferencesWindowController: PreferencesWindowController = {
            let storyboard = NSStoryboard(storyboardIdentifier: .Preferences)
            let windowController = storyboard.instantiateInitialController() as? PreferencesWindowController ?? PreferencesWindowController()
            return windowController
        }()
        preferencesWindowController.window?.delegate = self
        NSApp.activate(ignoringOtherApps: true)
        preferencesWindowController.showWindow(self)
        preferencesWindowController.window?.makeKeyAndOrderFront(self)
    }
    
    // MARK: - Notification
    
    func addObserver() {
        OpenNotifier.addObserver(observer: self,
                                 selector: #selector(openDefaultTerminal),
                                 notification: .openDefaultTerminal)
        OpenNotifier.addObserver(observer: self,
                                 selector: #selector(openDefaultEditor),
                                 notification: .openDefaultEditor)
        OpenNotifier.addObserver(observer: self,
                                 selector: #selector(copyPathToClipboard),
                                 notification: .copyPathToClipboard)
    }
    
    func removeObserver() {
        OpenNotifier.removeObserver(observer: self, notification: .openDefaultTerminal)
        OpenNotifier.removeObserver(observer: self, notification: .openDefaultEditor)
        OpenNotifier.removeObserver(observer: self, notification: .copyPathToClipboard)
    }
    
    // MARK: Notification Actions
    
    @objc func openDefaultTerminal() {
        AppManager.launchTerminal()
    }
    
    @objc func openDefaultEditor() {
        AppManager.launchEditor()
    }
    
    @objc func copyPathToClipboard() {
        do {
            var urls = try FinderManager.shared.getFullUrlsToFrontFinderWindowOrSelectedFile()
            if urls.count == 0 {
                // No Finder window and no file selected.
                let homePath = NSHomeDirectory()
                guard let homeUrl = URL(string: homePath) else { return }
                urls.append(homeUrl.appendingPathComponent("Desktop"))
            }
            let paths = urls.map { $0.path }
            let pathString = paths.joined(separator: "\n")
            // Set string
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(pathString, forType: .string)
        } catch {
            logw(error.localizedDescription)
        }
    }
    
//    func writeimage() {
//        SupportedApps.allCases.forEach {
//            let path = "/Applications/\($0.name).app"
//            guard FileManager.default.fileExists(atPath: path) else { return }
//
//            let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
//            let destinationURL = desktopURL.appendingPathComponent("\($0.name).png")
//            let icon = AppManager.getApplicationIcon(from: path)
//
//            guard let tiffRepresentation = icon.tiffRepresentation,
//                  let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else { return }
//            let pngData = bitmapImage.representation(using: .png, properties: [:])
//            do {
//                try pngData?.write(to: destinationURL, options: .atomic)
//            } catch {
//                print("\($0.name)")
//                print(error)
//            }
//        }
//    }
}

extension AppDelegate {
    
    // MARK: - Global Shortcuts
    
    func bindShortcuts() {
        let oitAction = ShortcutAction(keyPath: AppConfiguration.UserDefaultsKeys.defaultTerminalShortcut, of: Defaults) { _ in
            let appDelegate = NSApplication.shared.delegate as! AppDelegate
            appDelegate.openDefaultTerminal()
            return true
        }
        GlobalShortcutMonitor.shared.addAction(oitAction, forKeyEvent: .down)
        
        let oieAction = ShortcutAction(keyPath: AppConfiguration.UserDefaultsKeys.defaultEditorShortcut, of: Defaults) { _ in
            let appDelegate = NSApplication.shared.delegate as! AppDelegate
            appDelegate.openDefaultEditor()
            return true
        }
        GlobalShortcutMonitor.shared.addAction(oieAction, forKeyEvent: .down)
        
        let copyPathAction = ShortcutAction(keyPath: AppConfiguration.UserDefaultsKeys.copyPathShortcut, of: Defaults) { _ in
            let appDelegate = NSApplication.shared.delegate as! AppDelegate
            appDelegate.copyPathToClipboard()
            return true
        }
        GlobalShortcutMonitor.shared.addAction(copyPathAction, forKeyEvent: .down)
    }
}

extension AppDelegate: NSWindowDelegate {
    
    func windowWillClose(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory) // hide icon in Dock
    }
}

// MARK: - Application Restart
extension AppDelegate {
    
    func applyLanguageSettings() {
        let selectedLanguage = DefaultsManager.shared.selectedLanguage
        
        if selectedLanguage != "auto" {
            // 设置指定语言
            UserDefaults.standard.set([selectedLanguage], forKey: "AppleLanguages")
        } else {
            // 重置为系统语言
            UserDefaults.standard.removeObject(forKey: "AppleLanguages")
        }
        
        UserDefaults.standard.synchronize()
    }
    
    func restartApplication() {
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = [Bundle.main.bundlePath]
        
        // 启动新实例
        task.launch()
        
        // 退出当前实例
        NSApp.terminate(nil)
    }
}
