//
//  PipelineErrorLogger.swift
//  
//
//  Created by Jing Wei Li on 1/1/21.
//

import Foundation

/// Reference: https://project-pipeline.atlassian.net/wiki/spaces/DEV/pages/70123575/Backend+Error+Codes
enum PipelineErrorCode: Int {
    case invalidJWT = 0
    case websocketDisconnectError = 1
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter
}()

/// Log an error message with the appropriate error code
func PPL_LOG_ERROR(_ code: PipelineErrorCode, _ message: String) {
    print("\(dateFormatter.string(from: Date())) - error code \(code.rawValue), message: \(message)")
}

/// Log an error message with the appropriate error code
func PPL_LOG_ERROR(_ code: PipelineErrorCode, _ error: Error) {
    print("\(dateFormatter.string(from: Date())) - error code \(code.rawValue), message: \(error.localizedDescription)")
}

