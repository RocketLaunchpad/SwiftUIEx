//
//  CGRect.swift
//  Rocket Insights
//
//  Created by Ilya Belenkiy on 9/4/21.
//

import CoreGraphics

public extension CGRect {
    var center: CGPoint {
        .init(x: midX, y: midY)
    }
}
