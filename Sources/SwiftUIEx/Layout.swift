//
//  Layout.swift
//  Rocket Insights
//
//  Created by Ilya Belenkiy on 8/5/21.
//

import SwiftUI

public let minTappableRectSide: CGFloat = 44

public protocol AnyMeasurementKey: PreferenceKey {
    associatedtype Tag
}

public struct FirstMeasurementKey<T, Tag>: AnyMeasurementKey {
    public typealias Value = T?
    public static var defaultValue: Value { nil }
    public static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value ?? nextValue()
    }
}

public typealias MeasurementKey = FirstMeasurementKey

public struct MaxMeasurementKey<T: Comparable, Tag>: AnyMeasurementKey {
    public typealias Value = T?
    public static var defaultValue: Value { nil }
    public static func reduce(value: inout Value, nextValue: () -> Value) {
        switch (value, nextValue()) {
        case (nil, nil):
            value = nil
        case (nil, let value2?):
            value = value2
            return
        case (let value1?, nil):
            value = value1
            return
        case (let value1?, let value2?):
            value = max(value1, value2)
        }
    }
}

public struct Measurement<M: AnyMeasurementKey>: ViewModifier {
    let eval: (GeometryProxy) -> M.Value

    public func body(content: Content) -> some View {
        content.background(
            GeometryReader { proxy in
                Color.clear.preference(key: M.self, value: eval(proxy))
            }
        )
    }
}

public extension View {
    func measurement<M: AnyMeasurementKey>(_ keyType: M.Type, _ eval: @escaping (GeometryProxy) -> M.Value) -> some View {
        modifier(Measurement<M>(eval: eval))
    }

    func widthMeasurement<M: AnyMeasurementKey>(_ keyType: M.Type) -> some View where M.Value == CGFloat? {
        measurement(keyType, { $0.size.width })
    }

    func heightMeasurement<M: AnyMeasurementKey>(_ keyType: M.Type) -> some View where M.Value == CGFloat? {
        measurement(keyType, { $0.size.height })
    }

    func sizeMeasurement<M: AnyMeasurementKey>(_ keyType: M.Type) -> some View where M.Value == CGSize? {
        measurement(keyType, { $0.size })
    }

    func measure<M: AnyMeasurementKey>(
        _ keyType: M.Type,
        _ eval: @escaping (GeometryProxy) -> M.Value,
        save: @escaping (M.Value) -> Void
    )
    -> some View where M.Value: Equatable
    {
        measurement(keyType, eval).onPreferenceChange(M.self, perform: save)
    }

    func measureWidth<M: AnyMeasurementKey>(_ keyType: M.Type, save: @escaping (M.Value) -> Void)
    -> some View where M.Value == CGFloat?
    {
        widthMeasurement(keyType).onPreferenceChange(M.self, perform: save)
    }

    func measureHeight<M: AnyMeasurementKey>(_ keyType: M.Type, save: @escaping (M.Value) -> Void)
    -> some View where M.Value == CGFloat?
    {
        heightMeasurement(keyType).onPreferenceChange(M.self, perform: save)
    }

    func measureSize<M: AnyMeasurementKey>(_ keyType: M.Type, save: @escaping (M.Value) -> Void)
    -> some View where M.Value == CGSize?
    {
        sizeMeasurement(keyType).onPreferenceChange(M.self, perform: save)
    }
}
