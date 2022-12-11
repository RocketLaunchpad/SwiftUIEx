//
//  ShowIf.swift
//  Rocket Insights
//
//  Created by Ilya Belenkiy on 9/1/21.
//

import SwiftUI

public struct ShowIf: ViewModifier {
    public let value: Bool
    public let animation: Animation?

    public func body(content: Content) -> some View {
        if value {
            content.transition(.opacity.animation(animation))
        }
    }
}

public extension View {
    func showIf(_ value: Bool, animation: Animation? = nil) -> some View {
        modifier(ShowIf(value: value, animation: animation))
    }
}
