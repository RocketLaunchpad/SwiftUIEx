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

public struct RoundedRectBackground: ViewModifier {
    enum RadiusTag {}
    typealias RadiusKey = MeasurementKey<CGFloat, RadiusTag>

    struct Container<C: View>: View {
        @State var cornerRadius: CGFloat?

        let content: C
        let fillColor: Color
        let borderColor: Color
        let borderWidth: CGFloat

        var body: some View {
            let shape = RoundedRectangle(cornerRadius: cornerRadius ?? 0)
            return content
                .background(shape.fill(fillColor))
                .overlay(shape.stroke(borderColor, lineWidth: borderWidth))
                .clipShape(shape)
                .onPreferenceChange(RadiusKey.self) {
                    cornerRadius = $0
                }
        }
    }

    public enum CornerRadius {
        case value(CGFloat)
        case max
    }

    let fillColor: Color
    let borderColor: Color
    let cornerRadius: CornerRadius
    let borderWidth: CGFloat

    public func body(content: Content) -> some View {
        Container(
            content: content.measurement(RadiusKey.self) { proxy in
                switch cornerRadius {
                case .value(let value):
                    return value
                case .max:
                    return proxy.size.height / 2
                }
            },
            fillColor: fillColor,
            borderColor: borderColor,
            borderWidth: borderWidth
        )
    }
}

public extension View {
    func roundedRectBackground(
        fillColor: Color = .clear,
        borderColor: Color = .clear,
        cornerRadius: RoundedRectBackground.CornerRadius = .max,
        borderWidth: CGFloat = 0
    )
    -> some View
    {
        let view = RoundedRectBackground(
            fillColor: fillColor,
            borderColor: borderColor,
            cornerRadius: cornerRadius,
            borderWidth: borderWidth
        )
        return modifier(view)
    }
}
