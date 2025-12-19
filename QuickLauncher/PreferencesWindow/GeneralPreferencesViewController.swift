//
//  GeneralPreferencesViewController.swift
//  QuickLauncher
//
//  Created by Jianing Wang on 2019/4/21.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Cocoa
import QuickLauncherCore
import ServiceManagement

class GeneralPreferencesViewController: PreferencesViewController {

    // MARK: Properties

    @IBOutlet weak var launchButton: NSButton!
    @IBOutlet weak var quickToggleButton: NSButton!
    @IBOutlet weak var chooseToggleActionButton: NSPopUpButton!
    @IBOutlet weak var hideStatusItemButton: NSButton!
    @IBOutlet weak var hideContextMemuItemsButton: NSButton!
    @IBOutlet weak var defaultTerminalButton: NSPopUpButton!
    @IBOutlet weak var defaultEditorButton: NSPopUpButton!
    @IBOutlet weak var languageButton: NSPopUpButton!
    
    lazy var quickToggleTerminalMenuItem: NSMenuItem = {
        return NSMenuItem(title: QuickToggleType.openWithDefaultTerminal.name,
                          action: #selector(quickToggleTerminalClicked),
                          keyEquivalent: "")
    }()
    
    lazy var quickToggleEditorMenuItem: NSMenuItem = {
        return NSMenuItem(title: QuickToggleType.openWithDefaultEditor.name,
                          action: #selector(quickToggleEditorClicked),
                          keyEquivalent: "")
    }()
    
    lazy var quickToggleCopyPathMenuItem: NSMenuItem = {
        return NSMenuItem(title: QuickToggleType.copyPathToClipboard.name,
                          action: #selector(quickToggleCopyPathClicked),
                          keyEquivalent: "")
    }()
    
    var allInstalledApps: Set<String> = Set()
    var installedTerminals: [App]?
    var installedEditors: [App]?
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initQuickToggleAction()
        initLanguageMenu()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        allInstalledApps = FinderManager.shared.getAllInstalledApps()
        refreshButtonState()
        refreshDefaultTerminal()
        refreshDefaultEditor()
        refreshLanguage()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
    }
    
    // MARK: Init UI
    
    func initQuickToggleAction() {
        chooseToggleActionButton.removeAllItems()
        [quickToggleTerminalMenuItem, quickToggleEditorMenuItem,
         quickToggleCopyPathMenuItem].forEach {
            $0.target = self
            chooseToggleActionButton.menu?.addItem($0)
        }
    }
    
    // MARK: Refresh UI
    
    func refreshButtonState() {
        // Use unified launch manager to get current state
        let isLaunchAtLogin: Bool
        if #available(macOS 13.0, *) {
            isLaunchAtLogin = UnifiedLaunchManager.shared.isLaunchAtLoginEnabled
        } else {
            isLaunchAtLogin = DefaultsManager.shared.isLaunchAtLogin
        }
        launchButton.state = isLaunchAtLogin ? .on : .off
        
        let isHideStatusItem = DefaultsManager.shared.isHideStatusItem
        hideStatusItemButton.state = isHideStatusItem ? .on : .off
        
        let isHideContextMenuItems = DefaultsManager.shared.isHideContextMenuItems
        hideContextMemuItemsButton.state = isHideContextMenuItems ? .on : .off
        
        let isQuickToggle = DefaultsManager.shared.isQuickToggle
        quickToggleButton.state = isQuickToggle ? .on : .off
        chooseToggleActionButton.isEnabled = isQuickToggle
        
        if let quickToggleType = DefaultsManager.shared.quickToggleType {
            switch quickToggleType {
            case .openWithDefaultTerminal:
                chooseToggleActionButton.select(quickToggleTerminalMenuItem)
            case .openWithDefaultEditor:
                chooseToggleActionButton.select(quickToggleEditorMenuItem)
            case .copyPathToClipboard:
                chooseToggleActionButton.select(quickToggleCopyPathMenuItem)
            }
        }
    }
    
    func refreshDefaultTerminal() {
        refreshAppList(
            button: defaultTerminalButton,
            supportedApps: SupportedApps.terminals,
            installedAppsStorage: &installedTerminals,
            defaultValue: DefaultsManager.shared.defaultTerminal
        )
    }
    
    func refreshDefaultEditor() {
        refreshAppList(
            button: defaultEditorButton,
            supportedApps: SupportedApps.editors,
            installedAppsStorage: &installedEditors,
            defaultValue: DefaultsManager.shared.defaultEditor
        )
    }
    
    private func refreshAppList(
        button: NSPopUpButton,
        supportedApps: [SupportedApps],
        installedAppsStorage: inout [App]?,
        defaultValue: App?
    ) {
        button.removeAllItems()
        var apps = supportedApps.map { $0.app }
        
        // filter
        apps = apps.filter {
            allInstalledApps.contains($0.name)
        }
        
        // sort
        apps.sort {
            $0.name.localizedCaseInsensitiveCompare($1.name) == ComparisonResult.orderedAscending
        }
        
        apps.forEach {
            button.addItem(withTitle: $0.name)
        }
        
        installedAppsStorage = apps

        if let defaultValue = defaultValue {
            let index = button.indexOfItem(withTitle: defaultValue.name)
            button.selectItem(at: index)
        }
    }
    
    // MARK: Button Actions
    
    @IBAction func launchButtonClicked(_ sender: NSButton) {
        let isLaunch = launchButton.state == .on
        print("🔘 launchButtonClicked: isLaunch = \(isLaunch)")
        
        // 在主线程执行以避免线程安全问题
        do {
            print("🔄 Calling setLaunchAtLoginSync...")
            try UnifiedLaunchManager.shared.setLaunchAtLoginSync(isLaunch)
            print("✅ setLaunchAtLoginSync succeeded")
            
            // Update legacy setting for backward compatibility
            DefaultsManager.shared.isLaunchAtLogin = isLaunch
            print("✅ Updated DefaultsManager")
        } catch {
            print("❌ setLaunchAtLoginSync failed: \(error)")
            
            // Revert button state if failed
            launchButton.state = isLaunch ? .off : .on
            
            // Show error alert
            AppManager.showError(
                title: NSLocalizedString("Failed to update login setting", comment: "Login setting error"),
                message: error.localizedDescription
            )
        }
    }
    
    @IBAction func hideStatusItemButtonTapped(_ sender: NSButton) {
        let isHide = hideStatusItemButton.state == .on
        DefaultsManager.shared.isHideStatusItem = isHide

        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        appDelegate.setStatusItemVisible()
    }
    
    @IBAction func hideContextMenuItemsButtonTapped(_ sender: NSButton) {
        let isHide = hideContextMemuItemsButton.state == .on
        DefaultsManager.shared.isHideContextMenuItems = isHide
    }
    
    @IBAction func quickToggleButtonClicked(_ sender: NSButton) {
        let isQuickToggle = quickToggleButton.state == .on
        DefaultsManager.shared.isQuickToggle = isQuickToggle
        chooseToggleActionButton.isEnabled = isQuickToggle

        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        appDelegate.setStatusToggle()
        logw("Quick Toggle set to \(sender.state.rawValue)")
    }
    
    @IBAction func defaultTerminalButtonClicked(_ sender: NSPopUpButton) {
        handleAppSelection(
            sender: sender,
            installedApps: installedTerminals
        ) { selectedApp in
            DefaultsManager.shared.defaultTerminal = selectedApp
        }
    }
    
    @IBAction func defaultEditorButtonClicked(_ sender: NSPopUpButton) {
        handleAppSelection(
            sender: sender,
            installedApps: installedEditors
        ) { selectedApp in
            DefaultsManager.shared.defaultEditor = selectedApp
        }
    }
    
    private func handleAppSelection(
        sender: NSPopUpButton,
        installedApps: [App]?,
        setValue: (App) -> Void
    ) {
        guard let installedApps = installedApps else { return }
        
        let itemTitles = sender.itemTitles
        let index = sender.indexOfSelectedItem
        let title = itemTitles[index]
        
        installedApps.forEach {
            if $0.name == title {
                setValue($0)
            }
        }
    }
    
    // MARK: - Language Configuration
    
    func initLanguageMenu() {
        languageButton.removeAllItems()
        
        let availableLanguages = DefaultsManager.shared.availableLanguages
        for language in availableLanguages {
            languageButton.addItem(withTitle: language.localizedName)
            let menuItem = languageButton.menu?.item(withTitle: language.localizedName)
            menuItem?.target = self
            menuItem?.action = #selector(languageChangedFromMenuItem(_:))
            menuItem?.representedObject = language.code
        }
    }
    
    func refreshLanguage() {
        let selectedLanguage = DefaultsManager.shared.selectedLanguage
        let availableLanguages = DefaultsManager.shared.availableLanguages
        
        if let index = availableLanguages.firstIndex(where: { $0.code == selectedLanguage }) {
            languageButton.selectItem(at: index)
        } else {
            languageButton.selectItem(at: 0) // 默认选择 Auto
        }
    }
    
    @IBAction func languageChanged(_ sender: NSPopUpButton) {
        guard let menuItem = sender.selectedItem,
              let languageCode = menuItem.representedObject as? String else {
            return
        }
        
        handleLanguageChange(languageCode: languageCode)
    }
    
    @objc func languageChangedFromMenuItem(_ sender: NSMenuItem) {
        guard let languageCode = sender.representedObject as? String else { return }
        
        handleLanguageChange(languageCode: languageCode)
    }
    
    private func handleLanguageChange(languageCode: String) {
        let currentLanguage = DefaultsManager.shared.selectedLanguage
        if currentLanguage != languageCode {
            AppManager.showChoice(
                title: NSLocalizedString("Language Change Requires Restart", comment: ""),
                message: NSLocalizedString("The application needs to be restarted for the language change to take effect. Do you want to restart now?", comment: ""),
                primaryButtonTitle: NSLocalizedString("Restart Now", comment: ""),
                secondaryButtonTitle: NSLocalizedString("Later", comment: "")
            ) { result in
                if result == .primary {
                    // 应用语言更改并重启
                    DefaultsManager.shared.setLanguage(languageCode)
                    
                    // 延迟重启以确保设置保存
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        let appDelegate = NSApplication.shared.delegate as? AppDelegate
                        appDelegate?.restartApplication()
                    }
                }
            }
        }
    }
    
    @objc func quickToggleTerminalClicked(_ sender: NSMenuItem) {
        handleQuickToggle(
            toggleType: .openWithDefaultTerminal,
            menuItem: quickToggleTerminalMenuItem
        )
    }
    
    @objc func quickToggleEditorClicked(_ sender: NSMenuItem) {
        handleQuickToggle(
            toggleType: .openWithDefaultEditor,
            menuItem: quickToggleEditorMenuItem
        )
    }
    
    @objc func quickToggleCopyPathClicked(_ sender: NSMenuItem) {
        handleQuickToggle(
            toggleType: .copyPathToClipboard,
            menuItem: quickToggleCopyPathMenuItem
        )
    }
    
    private func handleQuickToggle(toggleType: QuickToggleType, menuItem: NSMenuItem) {
        DefaultsManager.shared.quickToggleType = toggleType
        chooseToggleActionButton.select(menuItem)
    }
}
