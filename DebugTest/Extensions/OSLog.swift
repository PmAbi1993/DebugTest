//
//  OSLog.swift
//  DebugTest
//
//  Created by Abhijith Pm on 10/9/25.
//

import Foundation
import OSLog

enum AppLogger {
    static let subsystem = "Duuuude"
    
    enum Category {
        static let api = "API"
        static let ui = "UI"
        static let debug = "Debug"
    }
    
    static func log(_ message: String, category: String = Category.debug, level: OSLogType = .default) {
        let logger = Logger(subsystem: subsystem, category: category)
        switch level {
        case .info:
            logger.info("\(message, privacy: .public)")
        case .debug:
            logger.debug("\(message, privacy: .public)")
        case .error:
            logger.error("\(message, privacy: .public)")
        case .fault:
            logger.critical("\(message, privacy: .public)")
        default:
            logger.notice("\(message, privacy: .public)")
        }
    }
    
    static func info(_ message: String, category: String = Category.debug) {
        log(message, category: category, level: .info)
    }
    
    static func error(_ message: String, category: String = Category.debug) {
        log(message, category: category, level: .error)
    }
    
    static func debug(_ message: String, category: String = Category.debug) {
        log(message, category: category, level: .debug)
    }
}
