//
//  LANGUAGE_USAGE_EXAMPLE.swift
//  QuickLauncher
//
//  语言功能使用示例
//

import Cocoa
import QuickLauncherCore

class LanguageUsageExample {
    
    // MARK: - 获取当前语言设置
    
    func getCurrentLanguage() -> String {
        return DefaultsManager.shared.selectedLanguage
    }
    
    // MARK: - 获取可用语言列表
    
    func getAvailableLanguages() -> [(code: String, name: String, localizedName: String)] {
        return DefaultsManager.shared.availableLanguages
    }
    
    // MARK: - 设置语言
    
    func setLanguage(_ languageCode: String) {
        DefaultsManager.shared.setLanguage(languageCode)
    }
    
    // MARK: - 监听语言更改
    
    func setupLanguageChangeObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(languageDidChange(_:)),
            name: .languageDidChange,
            object: nil
        )
    }
    
    @objc func languageDidChange(_ notification: Notification) {
        print("语言设置已更改，应用需要重启")
    }
    
    // MARK: - 获取本地化字符串示例
    
    func getLocalizedStrings() {
        print("Auto Language: \(String.languageAuto)")
        print("Restart Now: \(String.restartNow)")
        print("Later: \(String.later)")
        print("Language: \(String.language)")
    }
}

// MARK: - 界面集成示例

class LanguagePreferenceIntegration {
    
    func setupLanguageMenu(in popupButton: NSPopUpButton) {
        let defaultsManager = DefaultsManager.shared
        popupButton.removeAllItems()
        
        // 添加所有可用语言
        for language in defaultsManager.availableLanguages {
            let menuItem = NSMenuItem(title: language.localizedName,
                                     action: #selector(languageChanged(_:)),
                                     keyEquivalent: "")
            menuItem.target = self
            menuItem.representedObject = language.code
            popupButton.menu?.addItem(menuItem)
        }
        
        // 选择当前语言
        refreshLanguageSelection(in: popupButton)
    }
    
    func refreshLanguageSelection(in popupButton: NSPopUpButton) {
        let currentLanguage = DefaultsManager.shared.selectedLanguage
        let availableLanguages = DefaultsManager.shared.availableLanguages
        
        if let index = availableLanguages.firstIndex(where: { $0.code == currentLanguage }) {
            popupButton.selectItem(at: index)
        } else {
            popupButton.selectItem(at: 0) // 默认选择 Auto
        }
    }
    
    @IBAction func languageChanged(_ sender: NSPopUpButton) {
        guard let menuItem = sender.selectedItem,
              let languageCode = menuItem.representedObject as? String else {
            return
        }
        
        let currentLanguage = DefaultsManager.shared.selectedLanguage
        if currentLanguage != languageCode {
            showLanguageChangeConfirmation(for: languageCode)
        }
    }
    
    private func showLanguageChangeConfirmation(for languageCode: String) {
        let alert = NSAlert()
        alert.messageText = String.languageChangeRequiresRestart
        alert.informativeText = String.languageChangeMessage
        alert.alertStyle = .informational
        alert.addButton(withTitle: String.restartNow)
        alert.addButton(withTitle: String.later)
        
        let response = alert.runModal()
        
        if response == .alertFirstButtonReturn {
            // 应用语言更改
            DefaultsManager.shared.setLanguage(languageCode)
            
            // 延迟重启以确保设置保存
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                restartApplication()
            }
        }
    }
    
    private func restartApplication() {
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = [Bundle.main.bundlePath]
        task.launch()
        
        NSApp.terminate(nil)
    }
}

// MARK: - 使用示例

// 在 viewDidLoad 中设置语言菜单
/*
class GeneralPreferencesViewController: PreferencesViewController {
    @IBOutlet weak var languageButton: NSPopUpButton!
    private let languageIntegration = LanguagePreferenceIntegration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        languageIntegration.setupLanguageMenu(in: languageButton)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        languageIntegration.refreshLanguageSelection(in: languageButton)
    }
    
    @IBAction func languageChanged(_ sender: NSPopUpButton) {
        languageIntegration.languageChanged(sender)
    }
}
*/