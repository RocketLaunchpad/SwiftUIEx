//
//  AnimatedBinding.swift
//  Rocket Insights
//
//  Created by Ilya Belenkiy on 8/11/21.
//

import SwiftUI

public extension Animation {
    func `repeat`(while value: Bool, autoreverses: Bool = true) -> Animation {
        value ? repeatForever(autoreverses: autoreverses) : self
    }
}

public func withAnimation<Result>(_ animation: Animation? = .default, while value: Bool, _ body: () throws -> Result) rethrows -> Result {
    guard let animation = animation else { return try body() }
    return try withAnimation(animation.repeat(while: value), body)
}

public struct Animated<ContentView: View, T: Equatable>: View {
    @Binding var binding: T
    @State private var value: T
    private var animation: (T) -> Animation
    private var content: (T) -> ContentView

    public init(_ binding: Binding<T>, with animation: @escaping (T) -> Animation, @ViewBuilder content: @escaping (T) -> ContentView) {
        self._binding = binding
        self._value = State(initialValue: binding.wrappedValue)
        self.animation = animation
        self.content = content
    }

    public var body: some View {
        content(value)
            .onChange(of: binding) { value in
                withAnimation(animation(value)) {
                    self.value = value
                }
            }
    }
}
