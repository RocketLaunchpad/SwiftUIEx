//
//  RoundedRectBackground.swift
//  Rocket Insights
//
//  Created by Ilya Belenkiy on 8/6/21.
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
            return content.background(shape.fill(fillColor))
                .clipShape(shape)
                .overlay(shape.stroke(borderColor, lineWidth: borderWidth))
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
