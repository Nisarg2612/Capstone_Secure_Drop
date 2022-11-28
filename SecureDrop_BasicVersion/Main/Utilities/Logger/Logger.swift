//
//  Logger.swift
//  SecureDrop_BasicVersion
//
//  Created by Suman Chatla on 10/23/22.
//

import Foundation
import UIKit

enum LogType: String { case debug, prod, error, testing }
func Log(_ value: Any, _ type: LogType = .debug, funcName: String = #function, fileName: String = #file, line: Int = #line, col: Int = #column) {
    let logType = type.rawValue
    let testString = "Mock Log: \(value)"
    let string  =   """
                    ----------- Log ---------------
                    Value: "\(value)"
                    LogType: \(logType)
                    From: -------------------------
                    line: [\(line)][\(col)]
                    func: \(funcName)
                    file: \(fileName)
                    ---------- End Log ------------
                    """
#if DEBUG
    print(type == .testing ? testString : string)
#endif
    
}
