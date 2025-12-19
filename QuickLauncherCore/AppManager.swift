//
//  AppManager.swift
//  QuickLauncherCore
//
//  Created by Jianing Wang on 2020/12/18.
//  Copyright © 2020 Jianing Wang. All rights reserved.
//

import Foundation
import AppKit

/// Result type for choice alerts
public enum AlertChoiceResult {
    case primary
    case secondary
    case tertiary
    case cancelled
}

public class AppManager {
    
    public static var shared = AppManager()
    
    /// Launch a terminal application with fallback to user selection
    public static func launchTerminal() {
        launchApp(
            type: .terminal,
            getDefault: { DefaultsManager.shared.defaultTerminal },
            pickAlert: { shared.pickTerminalAlert() },
            setDefault: { DefaultsManager.shared.defaultTerminal = $0 }
        )
    }
    
    /// Launch an editor application with fallback to user selection
    public static func launchEditor() {
        launchApp(
            type: .editor,
            getDefault: { DefaultsManager.shared.defaultEditor },
            pickAlert: { shared.pickEditorAlert() },
            setDefault: { DefaultsManager.shared.defaultEditor = $0 }
        )
    }
    
    /// Generic method to launch an application with unified error handling
    private static func launchApp(
        type: AppType,
        getDefault: () -> App?,
        pickAlert: () -> App?,
        setDefault: (App) -> Void
    ) {
        var app: App
        
        if let defaultApp = getDefault() {
            app = defaultApp
        } else {
            // If there is no default app, then pick one
            guard let selectedApp = pickAlert() else {
                print("User cancelled app selection for \(type)")
                return
            }
            setDefault(selectedApp)
            app = selectedApp
        }
        
        do {
            try app.openOutsideSandbox()
            print("Successfully launched \(type): \(app.name)")
        } catch {
            print("Failed to launch \(type) \(app.name): \(error)")
        }
    }
    
    /// Enum to represent app types for logging
    private enum AppType {
        case terminal
        case editor
        
        var description: String {
            switch self {
            case .terminal:
                return "terminal"
            case .editor:
                return "editor"
            }
        }
    }
    
    public func pickTerminalAlert() -> App? {
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("alert.pick_terminal_title", comment: "Open In?")
        alert.informativeText = NSLocalizedString("alert.pick_terminal_description", comment: "Please select one of the following terminals as the default terminal to open.")
        // Add button and avoid the focus ring
        let cancelString = NSLocalizedString("general.cancel", comment: "Cancel")
        alert.addButton(withTitle: cancelString).refusesFirstResponder = true
        alert.addButton(withTitle: SupportedApps.terminal.name).refusesFirstResponder = true
        alert.addButton(withTitle: SupportedApps.iTerm.name).refusesFirstResponder = true
        alert.addButton(withTitle: SupportedApps.hyper.name).refusesFirstResponder = true
        let modalResult = alert.runModal()
        switch modalResult {
        case .alertFirstButtonReturn:
            return nil
        case .alertSecondButtonReturn:
            return SupportedApps.terminal.app
        case .alertThirdButtonReturn:
            return SupportedApps.iTerm.app
        default:
            return SupportedApps.hyper.app
        }
    }
    
    public func pickEditorAlert() -> App? {
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("alert.pick_editor_title", comment: "Open In?")
        alert.informativeText = NSLocalizedString("alert.pick_editor_description", comment: "Please select one of the following editors as the default editor to open.")
        // Add button and avoid the focus ring
        let cancelString = NSLocalizedString("general.cancel", comment: "Cancel")
        alert.addButton(withTitle: cancelString).refusesFirstResponder = true
        alert.addButton(withTitle: SupportedApps.vscode.name).refusesFirstResponder = true
        alert.addButton(withTitle: SupportedApps.sublime.name).refusesFirstResponder = true
        alert.addButton(withTitle: SupportedApps.atom.name).refusesFirstResponder = true
        let modalResult = alert.runModal()
        switch modalResult {
        case .alertFirstButtonReturn:
            return nil
        case .alertSecondButtonReturn:
            return SupportedApps.vscode.app
        case .alertThirdButtonReturn:
            return SupportedApps.sublime.app
        default:
            return SupportedApps.atom.app
        }
    }
    
    // MARK: - Alert Helper Methods
    
    /// Show a choice alert with custom buttons
    public static func showChoice(
        title: String,
        message: String,
        primaryButtonTitle: String,
        secondaryButtonTitle: String? = nil,
        tertiaryButtonTitle: String? = nil,
        completion: @escaping (AlertChoiceResult) -> Void
    ) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .informational
        
        // Add buttons in order
        let primaryButton = alert.addButton(withTitle: primaryButtonTitle)
        primaryButton.refusesFirstResponder = true
        
        if let secondary = secondaryButtonTitle {
            let secondaryButton = alert.addButton(withTitle: secondary)
            secondaryButton.refusesFirstResponder = true
        }
        
        if let tertiary = tertiaryButtonTitle {
            let tertiaryButton = alert.addButton(withTitle: tertiary)
            tertiaryButton.refusesFirstResponder = true
        }
        
        let response = alert.runModal()
        
        // Map response to result
        let result: AlertChoiceResult
        switch response {
        case .alertFirstButtonReturn:
            result = .primary
        case .alertSecondButtonReturn:
            result = .secondary
        case .alertThirdButtonReturn:
            result = .tertiary
        default:
            result = .cancelled
        }
        
        completion(result)
    }
    
    /// Show an error alert with OK button
    public static func showError(
        title: String,
        message: String
    ) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .critical
        
        let okButton = alert.addButton(withTitle: NSLocalizedString("general.ok", comment: "OK"))
        okButton.refusesFirstResponder = true
        
        alert.runModal()
    }
    
    public static func getApplicationName(from path: String?) -> String {
        guard let validPath = path else {
            return "Invalid Name"
        }
        guard let validBundle = Bundle.init(url: URL.init(fileURLWithPath: validPath)) else {
            return getApplicationFileName(from: validPath)
        }
        let CFBundleDisplayName = validBundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
        let CFBundleName = validBundle.object(forInfoDictionaryKey: "CFBundleName") as? String
        let FileName = getApplicationFileName(from: validPath)
        return CFBundleDisplayName ?? CFBundleName ?? FileName
    }
    
    public static func getApplicationName(from path: URL) -> String {
        return getApplicationName(from: path.path)
    }
    
    public static func getApplicationFileName(from path: String) -> String {
        var rawName = FileManager().displayName(atPath: path).removingPercentEncoding!
        let lowercased = rawName.lowercased()
        if lowercased.hasSuffix(".app") {
            let start = rawName.startIndex
            let end = rawName.index(rawName.endIndex, offsetBy: -4)
            rawName = String(rawName[start..<end])
        }
        return rawName
    }
    
    // 从路径获取应用图标
    public static func getApplicationIcon(from path: String?) -> NSImage {
        guard let validPath = path else {
            return #imageLiteral(resourceName: "SF.cube")
        }
        return NSWorkspace.shared.icon(forFile: validPath)
    }
    
    public static func getApplicationIcon(from path: URL) -> NSImage {
        return getApplicationIcon(from: path.path)
    }
}
