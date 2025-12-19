//
//  AdvancedPreferencesViewController.swift
//  QuickLauncher
//
//  Created by Jianing Wang on 2019/5/5.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Cocoa
import QuickLauncherCore
import ServiceManagement
import ShortcutRecorder

class AdvancedPreferencesViewController: PreferencesViewController {
    
    @IBOutlet weak var defaultTerminalShortcut: RecorderControl!
    @IBOutlet weak var defaultEditorShortcut: RecorderControl!
    @IBOutlet weak var copyPathShortcut: RecorderControl!
    @IBOutlet weak var resetPreferencesButton: NSButton!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 修复ShortcutRecorder本地化问题
        fixShortcutRecorderLocalization()
        
        defaultTerminalShortcut.bind(.value, to: Defaults, withKeyPath: Constants.Key.defaultTerminalShortcut)
        defaultEditorShortcut.bind(.value, to: Defaults, withKeyPath: Constants.Key.defaultEditorShortcut)
        copyPathShortcut.bind(.value, to: Defaults, withKeyPath: Constants.Key.copyPathShortcut)
    }
    
    private func fixShortcutRecorderLocalization() {
        // SRCommon.m已经修复了bundle查找逻辑，这里只需要确保语言设置正确
        // 获取当前选择的语言并确保AppleLanguages设置正确
        let selectedLanguage = DefaultsManager.shared.selectedLanguage
        if selectedLanguage != "auto" {
            UserDefaults.standard.set([selectedLanguage], forKey: "AppleLanguages")
        }
        UserDefaults.standard.synchronize()
        
        // 检查并手动复制本地化文件（如果需要）
        ensureLocalizationFilesExist()
    }
    
    private func ensureLocalizationFilesExist() {
        let mainBundle = Bundle.main
        let selectedLanguage = DefaultsManager.shared.selectedLanguage
        
        if selectedLanguage != "auto" {
            let langCode = selectedLanguage
            let langDir = mainBundle.resourcePath! + "/\(langCode).lproj"
            let preferencesStrings = langDir + "/Preferences.strings"
            
            // 检查本地化文件是否存在
            if !FileManager.default.fileExists(atPath: preferencesStrings) {
                print("⚠️ 警告：找不到本地化文件 \(preferencesStrings)")
                print("请运行构建脚本确保本地化文件被正确复制")
            }
        }
    }
    
    
    // MARK: Button Actions
    
    @IBAction func resetPreferencesButtonClicked(_ sender: NSButton) {
        let alert = NSAlert()
        
        alert.messageText = NSLocalizedString("alert.reset_preferences_title", comment: "Reset User Preferences?")
        alert.informativeText = NSLocalizedString("alert.reset_preferences_description", comment: "⚠️ Note that this will reset all user preferences")
        
        // Add button and avoid the focus ring
        let cancelString = NSLocalizedString("general.cancel", comment: "Cancel")
        alert.addButton(withTitle: cancelString).refusesFirstResponder = true
        
        let yesString = NSLocalizedString("general.yes", comment: "Yes")
        alert.addButton(withTitle: yesString).refusesFirstResponder = true
        
        let modalResult = alert.runModal()
        
        switch modalResult {
        case .alertFirstButtonReturn:
            print("Cancel Resetting User Preferences")
        case .alertSecondButtonReturn:
            logw("Reset User Preferences")
            
            // Reset login item using ServiceManagement
            DispatchQueue.global(qos: .background).async {
                do {
                    // Remove login item for the current app
                    if let bundleId = Bundle.main.bundleIdentifier {
                        SMLoginItemSetEnabled(bundleId as CFString, false)
                    }
                } catch {
                    DispatchQueue.main.async {
                        logw("Failed to reset login item: \(error)")
                    }
                }
            }
            
            DefaultsManager.shared.removeAllUserDefaults()
            DefaultsManager.shared.firstSetup()
            let appDelegate = NSApplication.shared.delegate as! AppDelegate
            appDelegate.setStatusToggle()
        default:
            print("Cancel Resetting User Preferences")
        }
    }
    
    @IBAction func quitButtonClicked(_ sender: NSButton) {
        LaunchNotifier.postNotification(.terminateApp, object: Bundle.main.bundleIdentifier!)
        NSApp.terminate(self)
    }
    
}
