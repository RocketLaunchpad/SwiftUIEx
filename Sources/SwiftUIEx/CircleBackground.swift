//
//  CircleBackground.swift
//  Rocket Insights
//
//  Created by Ilya Belenkiy on 8/6/21.
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
            let r = radius ?? 0
            let shape = Circle()
            return content
                .frame(width: 2.0 * r, height: 2.0 * r)
                .background(shape.fill(fillColor))
                .overlay(shape.stroke(borderColor, lineWidth: borderWidth))
                .onPreferenceChange(MaxSideLengthKey.self) {
                    radius = ($0 ?? 0) / 2.0
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
