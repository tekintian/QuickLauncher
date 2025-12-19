//
//  Notification+Name.swift
//  QuickLauncherCore
//
//  Created by Assistant on 2024/12/18.
//  Copyright © 2024 Jianing Wang. All rights reserved.
//

import Foundation

public extension Notification.Name {
    static let languageDidChange = Notification.Name("LanguageDidChange")
}

// MARK: - Localized Strings for Language Configuration
extension String {
    static let languageAuto = NSLocalizedString("Language Auto", comment: "")
    static let languageChangeRequiresRestart = NSLocalizedString("Language Change Requires Restart", comment: "")
    static let languageChangeMessage = NSLocalizedString("The application needs to be restarted for the language change to take effect. Do you want to restart now?", comment: "")
    static let restartNow = NSLocalizedString("Restart Now", comment: "")
    static let later = NSLocalizedString("Later", comment: "")
    static let language = NSLocalizedString("Language", comment: "")
}