//
//  Color.swift
//  Rocket Insights
//
//  Created by Ilya Belenkiy on 8/26/21.
//

import SwiftUI
import FoundationEx

#if canImport(UIKit)
import UIKit

extension UIColor {
    var swiftUIcolor: Color {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return .init(red: Double(red), green: Double(green), blue: Double(blue), opacity: Double(alpha))
    }
}

public extension Color {
    init(_uiColor: UIColor) {
        #if swift(>=5.5) // should be #if available, but Xcode 12 cannot handle it
        if #available(iOS 15.0, *) {
            self = Color(uiColor: _uiColor)
        }
        else {
            self = _uiColor.swiftUIcolor
        }
        #else
        self = _uiColor.swiftUIcolor
        #endif
    }

    init(hex: String) {
        guard let (red, green, blue, alpha) = try? hex.parseAsHexColor() else {
            assertionFailure()
            self = .clear
            return
        }
        self.init(red: Double(red), green: Double(green), blue: Double(blue), opacity: Double(alpha))
    }

    static var systemGray2: Self { .init(_uiColor: .systemGray2) }
    static var systemGray3: Self { .init(_uiColor: .systemGray3) }
    static var systemGray4: Self { .init(_uiColor: .systemGray4) }
    static var systemGray5: Self { .init(_uiColor: .systemGray5) }
    static var systemGray6: Self { .init(_uiColor: .systemGray6) }

    static var label: Self { .init(_uiColor: .label) }
    static var secondaryLabel: Self { .init(_uiColor: .secondaryLabel) }
    static var tertiaryLabel: Self { .init(_uiColor: .tertiaryLabel) }
    static var quaternaryLabel: Self { .init(_uiColor: .quaternaryLabel) }
    static var placeholderText: Self { .init(_uiColor: .placeholderText) }

    static var systemFill: Self { .init(_uiColor: .systemFill) }
    static var secondarySystemFill: Self { .init(_uiColor: .secondarySystemFill) }
    static var tetriarySystemFill: Self { .init(_uiColor: .tertiarySystemFill) }
    static var quaternarySystemFill: Self { .init(_uiColor: .quaternarySystemFill) }

    static var systemBackground: Self { .init(_uiColor: .systemBackground) }
    static var secondarySystemBackground: Self { .init(_uiColor: .secondarySystemBackground) }
    static var tertiarySystemBackground: Self { .init(_uiColor: .tertiarySystemBackground) }
}

#endif
