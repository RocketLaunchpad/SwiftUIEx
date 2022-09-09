//
//  ExplicitAnimation.swift
//  Rocket Insights
//
//  Created by Ilya Belenkiy on 8/23/21.
//

import SwiftUI
import Tagged

/// Provides a modifier to set the actual animated property value
public protocol ExplicitAnimationModifierProvider {
    associatedtype Result: ViewModifier
    associatedtype Value: VectorArithmetic & Numeric
    static func modifier(value: Value) -> Result
}

public enum ExplicitAnimation {
    public enum TriggerTag {}
    public typealias Trigger = Tagged<TriggerTag, Double>

    /// Evaluates the current value for the animated property
    /// from the value that is mapped to the range between 0 and 1.
    public struct ScaledValueEvaluator<T: VectorArithmetic & Numeric> {
        public let eval: (_ scaledValue: Double) -> T
    }

    /// Evaluates the scaled value for the animated property
    /// from the animation progress. The result represents the
    /// animated property mapping to the range between 0 and 1.
    /// The animation progress is also in the range between 0 and 1 where
    /// 0 means the start of the animation, and 1 means the end.
    public struct ProgressEvaluator {
        let eval: (_ progress: Double) -> Double
    }

    public struct TriggerModifier<ModifierProvider: ExplicitAnimationModifierProvider>: AnimatableModifier {
        typealias Value = ModifierProvider.Value

        var trigger: Trigger
        let progressEvaluator: ProgressEvaluator
        let scaledValueEvaluator: ScaledValueEvaluator<Value>

        public var animatableData: Double {
            get { trigger.rawValue }
            set { trigger.rawValue = newValue }
        }

        public func body(content: Content) -> some View {
            let x = trigger.rawValue
            let progress = progressEvaluator.eval(x - floor(x))
            let value = scaledValueEvaluator.eval(progress)
            let modifier = ModifierProvider.modifier(value: value)
            content.modifier(modifier)
        }
    }
}

public extension ExplicitAnimation.Trigger {
    mutating func animate() {
        rawValue += 1
    }

    init() {
        self.init(rawValue: 0)
    }
}

public extension ExplicitAnimation.ScaledValueEvaluator where T == Double {
    static let identity: Self = .init { $0 }
    
    static let radians: Self = .init { 2 * .pi * $0 }
}

public extension ExplicitAnimation.ProgressEvaluator {
    static let zero_one_zero_sin: Self = .init { x in
        sin(x * .pi)
    }

    static let zero_one_zero3: Self = .init { x in
        if x < 1.0 / 4.0 {
            return 4.0 * x
        }
        else if x < 3.0 / 4.0 {
            return 1
        }
        else {
            return 4.0 * (1 - x)
        }
    }

    static let one_zero_one3: Self = .init { x in
        if x < 1.0 / 4.0 {
            return 1 - 4.0 * x
        }
        else if x < 3.0 / 4.0 {
            return 0
        }
        else {
            return 1 - 4.0 * (1 - x)
        }
    }
    
    static let damped_oscillations_3: Self = .init { x in
        // break up each expresion to improve the compilation time
        let a, b, c: Double
        let pi = Double.pi
        if x < 1.0 / 4.0 {
            a = 1.0 / 2.0
            b = sin(4.0 * pi * x - pi / 2.0)
            c = 1.0 / 2.0
        }
        else if x < 2.0 / 4.0 {
            a = (3.0 / 4.0)
            b = sin(4 * pi * x - pi / 2)
            c = 1.0 / 4.0
        }
        else if x < 3.0 / 4.0 {
            a = (3.0 / 8.0)
            b = sin(4 * pi * x - pi / 2)
            c = -(1.0 / 8.0)
        }
        else {
            a = 1.0 / 8.0
            b = sin(4 * pi * x - pi / 2)
            c = 1.0 / 8.0
        }
        return a * b + c
    }
}

// MARK: Opacity

public struct AnimationOpacityModifier: ViewModifier {
    public let value: Double

    public func body(content: Content) -> some View {
        content.opacity(value)
    }
}

public enum OpacityModifierProvider: ExplicitAnimationModifierProvider {
    public static func modifier(value: Double) -> AnimationOpacityModifier {
        .init(value: value)
    }
}

public typealias AnimatedOpacityTriggerModifier = ExplicitAnimation.TriggerModifier<OpacityModifierProvider>

extension AnimatedOpacityTriggerModifier {
    init(trigger: ExplicitAnimation.Trigger, progressEvaluator: ExplicitAnimation.ProgressEvaluator) {
        self.init(trigger: trigger, progressEvaluator: progressEvaluator, scaledValueEvaluator: .identity)
    }
}

public extension View {
    func animatedOpacity(trigger: ExplicitAnimation.Trigger, progressEvaluator: ExplicitAnimation.ProgressEvaluator) -> some View {
        modifier(AnimatedOpacityTriggerModifier(trigger: trigger, progressEvaluator: progressEvaluator))
    }
}

// MARK: Z Rotation

public struct AnimationZRotationModifier: ViewModifier {
    public let value: Double

    public func body(content: Content) -> some View {
        content.rotationEffect(.init(radians: value))
    }
}

public enum ZRotationModifierProvider: ExplicitAnimationModifierProvider {
    public static func modifier(value: Double) -> AnimationZRotationModifier {
        .init(value: value)
    }
}

public typealias AnimatedZRotationTriggerModifier = ExplicitAnimation.TriggerModifier<ZRotationModifierProvider>

extension AnimatedZRotationTriggerModifier {
    init(maxAngle: Double, trigger: ExplicitAnimation.Trigger, progressEvaluator: ExplicitAnimation.ProgressEvaluator) {
        self.init(
            trigger: trigger,
            progressEvaluator: progressEvaluator,
            scaledValueEvaluator: .init { x in
                maxAngle * x
            }
        )
    }
}

public extension View {
    func animatedZRotation(
        maxAngle: Double,
        trigger: ExplicitAnimation.Trigger, progressEvaluator:
        ExplicitAnimation.ProgressEvaluator
    )
    -> some View
    {
        modifier(AnimatedZRotationTriggerModifier(maxAngle: maxAngle, trigger: trigger, progressEvaluator: progressEvaluator))
    }
}

