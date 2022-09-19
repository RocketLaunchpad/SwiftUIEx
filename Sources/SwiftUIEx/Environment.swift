//
//  Environment.swift
//  
//
//  Created by Ilya Belenkiy on 9/19/22.
//

import Foundation

public enum SwiftUIEx {
    public struct Environment {
        public var logCodingError: (String) -> Void
    }

    private static func logError(_ string: String) {
        NSLog("SwiftUIEx Error:\n\(string)")
    }

    public static var env = Environment(
        logCodingError: logError(_:)
    )
}
