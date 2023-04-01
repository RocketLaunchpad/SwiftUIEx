//
// Copyright (c) 2023 DEPT Digital Products, Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
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
