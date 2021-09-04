//
//  SilhouetteInverseFill.swift
//  Rocket Insights
//
//  Created by Ilya Belenkiy on 8/6/21.
//

import SwiftUI

public struct SilhouetteInverseFill: ViewModifier {
    public let color: Color

    public func body(content: Content) -> some View {
        let mask = content
            .compositingGroup()
            .luminanceToAlpha()

        return content
            .overlay(color)
            .mask(mask)
            .compositingGroup() // necessary if the caller changes opacity
    }
}

public extension View {
    func silhouetteInverseFill(color: Color) -> some View {
        modifier(SilhouetteInverseFill(color: color))
    }
}
