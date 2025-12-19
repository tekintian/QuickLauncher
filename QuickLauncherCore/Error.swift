//
//  Error.swift
//  cd2swiftTest
//
//  Created by Jianing Wang on 2019/4/10.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Foundation



/// 统一的错误类型
public enum QuickLauncherError: Error, LocalizedError {
    case cannotAccessPath(String)
    case cannotGetApp(AppType)
    case cannotAccessFinder
    case cannotAccessApp(String)
    case wrongUrl
    case cannotCreateAppleScript(String)
    case cannotExecuteAppleScript(Error)
    case appNotFound(String)
    case commandExecutionFailed(String)
    case unknown(Error)
    
    public var errorDescription: String? {
        switch self {
        case .cannotAccessPath(let path):
            return NSLocalizedString("Cannot access path: \(path)", comment: "Path access error")
        case .cannotGetApp(let appType):
            return NSLocalizedString("Cannot get default \(appType.localizedDescription)", comment: "App selection error")
        case .cannotAccessFinder:
            return NSLocalizedString("Cannot access Finder", comment: "Finder access error")
        case .cannotAccessApp(let appName):
            return NSLocalizedString("Cannot access app: \(appName)", comment: "App access error")
        case .wrongUrl:
            return NSLocalizedString("Invalid URL", comment: "Invalid URL error")
        case .cannotCreateAppleScript(let source):
            return NSLocalizedString("Cannot create AppleScript: \(source)", comment: "AppleScript creation error")
        case .cannotExecuteAppleScript(let error):
            return NSLocalizedString("Cannot execute AppleScript: \(error.localizedDescription)", comment: "AppleScript execution error")
        case .appNotFound(let appName):
            return NSLocalizedString("App not found: \(appName)", comment: "App not found error")
        case .commandExecutionFailed(let command):
            return NSLocalizedString("Command execution failed: \(command)", comment: "Command execution error")
        case .unknown(let error):
            return NSLocalizedString("Unknown error: \(error.localizedDescription)", comment: "Unknown error")
        }
    }
}

/// 错误日志记录
public extension QuickLauncherError {
    static func log(_ error: Error, context: String = "") {
        let oitError: QuickLauncherError
        if error is QuickLauncherError {
            oitError = error as! QuickLauncherError
        } else {
            oitError = .unknown(error)
        }
        
        let message = context.isEmpty ? oitError.localizedDescription : "[\(context)] \(oitError.localizedDescription)"
        print("QuickLauncher Error: \(message)")
        
        // 在实际应用中，这里可以集成更完善的日志系统
        // Logger.shared.error(message, error: oitError)
    }
}

// MARK: - Legacy compatibility (deprecated)
// Use QuickLauncherError instead
@available(*, deprecated, message: "Use QuickLauncherError instead")
enum OITError: Error {
    case cannotAccessFinder
    case cannotAccessApp(_ appName: String)
    case wrongUrl
    case cannotCreateAppleScript(_ source: String)
    case cannotExcuteAppleScript(_ error: Error)
}

@available(*, deprecated, message: "Use QuickLauncherError instead")
extension OITError : CustomStringConvertible {
    var description: String {
        switch self {
        case .cannotAccessFinder:
            return "Cannot access Finder, please check permissions."
        case .cannotAccessApp(let appName):
            return "Cannot access \(appName), please check permissions."
        case .wrongUrl:
            return "Oops, got a wrong url"
        case .cannotCreateAppleScript(let source):
            return "Cannot create AppleScript:\n\(source)"
        case .cannotExcuteAppleScript(let error):
            return "Cannot excute AppleScript:\n\(error)"
        }
    }
    
    /// Convert to new unified error type
    func toUnifiedError() -> QuickLauncherError {
        switch self {
        case .cannotAccessFinder:
            return .cannotAccessFinder
        case .cannotAccessApp(let appName):
            return .cannotAccessApp(appName)
        case .wrongUrl:
            return .wrongUrl
        case .cannotCreateAppleScript(let source):
            return .cannotCreateAppleScript(source)
        case .cannotExcuteAppleScript(let error):
            return .cannotExecuteAppleScript(error)
        }
    }
}
