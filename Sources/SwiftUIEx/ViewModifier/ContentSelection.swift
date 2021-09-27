//
//  ContentSelection.swift
//  Rocket Insights
//
//  Created by Ilya Belenkiy on 8/9/21.
//

import SwiftUI

public struct AccentColorSelection: ViewModifier {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    public let isSelected: Bool
    public let cornerRadius: CGFloat

    var systemBackgroundColor: Color {
        switch colorScheme {
        case .light:
            return .white
        default:
            return .black
        }
    }

    public func body(content: Content) -> some View {
        content
            .foregroundColor(isSelected ? systemBackgroundColor : nil)
            .roundedRectBackground(
                fillColor: isSelected ? .accentColor : .clear,
                cornerRadius: .value(cornerRadius)
            )
    }
}

public extension View {
    func accentColorSelection(isSelected: Bool, cornerRadius: CGFloat = 7) -> some View {
        modifier(AccentColorSelection(isSelected: isSelected, cornerRadius: cornerRadius))
    }
}

public struct UnderlineSelection: ViewModifier {
    public let isSelected: Bool
    public var color: Color
    public var thickness: CGFloat

    public func body(content: Content) -> some View {
        content
            .padding(.bottom, thickness)
            .background(
                Rectangle().fill(isSelected ? color : .clear).frame(height: thickness),
                alignment: .bottom
            )
    }
}

public extension View {
    func underlineSelection(isSelected: Bool, color: Color = .primary, thickness: CGFloat = 2) -> some View {
        modifier(UnderlineSelection(isSelected: isSelected, color: color, thickness: thickness))
    }
}
