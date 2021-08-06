//
//  File.swift
//  File
//
//  Created by Ilya Belenkiy on 8/5/21.
//

import SwiftUI

public struct MeasurementKey<Value, Tag>: PreferenceKey {
    public static var defaultValue: Value? { nil }
    public static func reduce(value: inout Value?, nextValue: () -> Value?) {
        value = value ?? nextValue()
    }
}

public struct Measurement<Value, Tag>: ViewModifier {
    let eval: (GeometryProxy) -> Value?

    public func body(content: Content) -> some View {
        content.background(
            GeometryReader { proxy in
                Color.clear.preference(key: MeasurementKey<Value, Tag>.self, value: eval(proxy))
            }
        )
    }
}

public extension View {
    func measurement<Value, Tag>(_ keyType: MeasurementKey<Value, Tag>.Type, _ eval: @escaping (GeometryProxy) -> Value?) -> some View {
        modifier(Measurement<Value, Tag>(eval: eval))
    }
}
