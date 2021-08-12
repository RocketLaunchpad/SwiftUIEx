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

public struct Animated<ContentView: View>: View {
    @Binding var binding: Bool
    @State private var value: Bool
    private let animation: (Bool) -> Animation
    private let content: (Bool) -> ContentView

    public init(_ binding: Binding<Bool>, with animation: @escaping (Bool) -> Animation, @ViewBuilder content: @escaping (Bool) -> ContentView) {
        _binding = binding
        self.value = _binding.wrappedValue
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
