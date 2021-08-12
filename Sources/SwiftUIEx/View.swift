//
//  View.swift
//  Rocket Insights
//
//  Created by Ilya Belenkiy on 8/8/21.
//

import SwiftUI

public extension View {
    func sideEffect(_ f: () -> Void) -> Self {
        f()
        return self
    }
}
