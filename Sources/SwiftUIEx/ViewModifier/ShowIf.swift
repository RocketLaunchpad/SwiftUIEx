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
        content.opacity(value ? 1 : 0).animation(animation, value: value)
    }
}

public extension View {
    func showIf(_ value: Bool, animation: Animation? = nil) -> some View {
        modifier(ShowIf(value: value, animation: animation))
    }
}
