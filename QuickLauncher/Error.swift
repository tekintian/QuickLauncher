//
//  Error.swift
//  QuickLauncher
//
//  Created by Jianing Wang on 2019/10/15.
//  Copyright © 2019 Jianing Wang. All rights reserved.
//

import Foundation
import QuickLauncherCore

// MARK: - Legacy compatibility (deprecated)
// Use QuickLauncherError from QuickLauncherCore instead
@available(*, deprecated, message: "Use QuickLauncherError from QuickLauncherCore instead")
enum OITMError: Error {
    
    case cannotAccessPath(_ path: String)
    
}

@available(*, deprecated, message: "Use QuickLauncherError from QuickLauncherCore instead")
extension OITMError : CustomStringConvertible {
    
    var description: String {
        switch self {
        case .cannotAccessPath(let path):
            return "Cannot access path: \(path)"
        }
    }
    
    /// Convert to new unified error type
    func toUnifiedError() -> QuickLauncherError {
        switch self {
        case .cannotAccessPath(let path):
            return .cannotAccessPath(path)
        }
    }
}
