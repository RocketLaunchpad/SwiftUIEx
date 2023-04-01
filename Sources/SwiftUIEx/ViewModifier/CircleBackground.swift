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

public struct CircleBackground: ViewModifier {
    enum MaxSideLengthTag {}
    typealias MaxSideLengthKey = MeasurementKey<CGFloat, MaxSideLengthTag>

    struct Container<C: View>: View {
        @State var radius: CGFloat?

        let content: C
        let fillColor: Color
        let borderColor: Color
        let borderWidth: CGFloat

        var body: some View {
            let shape = Circle()
            return content
                .frame(width: radius.map { 2 * $0 }, height: radius.map { 2 * $0})
                .background(shape.fill(fillColor))
                .overlay(shape.stroke(borderColor, lineWidth: borderWidth))
                .clipShape(shape)
                .onPreferenceChange(MaxSideLengthKey.self) {
                    if let sideLength = $0 {
                        radius = sideLength / 2.0
                    }
                }
        }
    }

    public let fillColor: Color
    public let borderColor: Color
    public let borderWidth: CGFloat

    public func body(content: Content) -> some View {
        Container(
            content: content.measurement(MaxSideLengthKey.self) {
                max($0.size.width, $0.size.height)
            },
            fillColor: fillColor,
            borderColor: borderColor,
            borderWidth: borderWidth
        )
    }
}

public extension View {
    func circleBackground(fillColor: Color = .clear, borderColor: Color = .clear, borderWidth: CGFloat = 0) -> some View {
        modifier(CircleBackground(fillColor: fillColor, borderColor: borderColor, borderWidth: borderWidth))
    }
}
