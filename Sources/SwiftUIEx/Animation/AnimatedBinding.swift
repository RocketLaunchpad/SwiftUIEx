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
        VStack { // use VStack to work around a bug in iOS 14
            content(value)
        }
        .onChange(of: binding) { value in
            withAnimation(animation(value)) {
                self.value = value
            }
        }
    }
}
