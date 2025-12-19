//
//  Config.swift
//  QuickLauncher
//
//  Created by Jianing Wang on 2019/4/20.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Cocoa
import Foundation
import QuickLauncherCore

// MARK: - Legacy compatibility (deprecated)
// Use AppConfiguration from QuickLauncherCore instead
struct Constants {
    
    @available(*, deprecated, message: "Use AppConfiguration.Identifiers.finderExtension instead")
    struct Id {
        @available(*, deprecated, message: "Launcher app has been removed")
        static let LauncherApp = "cn.tekin.app.QuickLauncherHelper"
        
        static let FinderExtension = AppConfiguration.Identifiers.finderExtension
        static let CustomAppCell = NSUserInterfaceItemIdentifier(rawValue: "customAppCell")
        static let CustomMenuCell = NSUserInterfaceItemIdentifier(rawValue: "customMenuCell")
        static let CustomInputViewController = "CustomInputViewController"
    }
    
    static let none = "None"
    
    @available(*, deprecated, message: "Use AppConfiguration.UserDefaultsKeys instead")
    struct Key {
        static let defaultTerminalShortcut = AppConfiguration.UserDefaultsKeys.defaultTerminalShortcut
        static let defaultEditorShortcut = AppConfiguration.UserDefaultsKeys.defaultEditorShortcut
        static let copyPathShortcut = "OIT_CopyPathShortcut"
    }
    
    static let PreferencesStoryboard = NSStoryboard(name: "Preferences", bundle: nil)
}

extension NSImage {
    
    enum AssetIdentifier: String {
        case StatusBarIcon
    }
    
    convenience init(assetIdentifier: AssetIdentifier) {
        self.init(named: assetIdentifier.rawValue)!
    }
}

extension NSStoryboard {
    
    enum StoryboardIdentifier: String {
        case Preferences
    }
    
    convenience init(storyboardIdentifier: StoryboardIdentifier) {
        self.init(name: storyboardIdentifier.rawValue, bundle: nil)
    }
}
