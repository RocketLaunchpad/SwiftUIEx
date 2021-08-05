//
//  File.swift
//  File
//
//  Created by Ilya Belenkiy on 8/5/21.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
import UIKitEx

@available(iOS 15.0, *)
public extension Color {
    init(_ color: Styling.Color) {
        self.init(UIColor(dynamicProvider: {
            switch $0.userInterfaceStyle {
            case .dark:
                return UIColor(red: 1.0 - color.red, green: 1.0 - color.green, blue: 1.0 - color.blue, alpha: color.opacity)
            default:
                return UIColor(red: color.red, green: color.green, blue: color.blue, alpha: color.opacity)
            }
        }))
    }

    init(hex: String) {
        self.init(.literal(hex: hex, opacity: 1.0))
    }

    static let systemGray2: Self = .init(uiColor: .systemGray2)
    static let systemGray3: Self = .init(uiColor: .systemGray3)
    static let systemGray4: Self = .init(uiColor: .systemGray4)
    static let systemGray5: Self = .init(uiColor: .systemGray5)
    static let systemGray6: Self = .init(uiColor: .systemGray6)

    static let label: Self = .init(uiColor: .label)
    static let secondaryLabel: Self = .init(uiColor: .secondaryLabel)
    static let tertiaryLabel: Self = .init(uiColor: .tertiaryLabel)
    static let quaternaryLabel: Self = .init(uiColor: .quaternaryLabel)
    static let placeholderText: Self = .init(uiColor: .placeholderText)

    static let systemFill: Self = .init(uiColor: .systemFill)
    static let secondarySystemFill: Self = .init(uiColor: .secondarySystemFill)
    static let tetriarySystemFill: Self = .init(uiColor: .tertiarySystemFill)
    static let quaternarySystemFill: Self = .init(uiColor: .quaternarySystemFill)

    static let systemBackground: Self = .init(uiColor: .systemBackground)
    static let secondarySystemBackground: Self = .init(uiColor: .secondarySystemBackground)
    static let tertiarySystemBackground: Self = .init(uiColor: .tertiarySystemBackground)
}

#endif
