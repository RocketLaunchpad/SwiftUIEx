//
//  PlainNavigationLink.swift
//  Rocket Insights
//
//  Created by Ilya Belenkiy on 11/17/21.
//

import Foundation
import SwiftUI

public struct PlainNavigationLink<Label: View, Destination: View>: View {
    let label: () -> Label
    let enabled: Bool
    let destination: () -> Destination

    @State private var linkIsActive = false

    public init(destination: @autoclosure @escaping () -> Destination, enabled: Bool = true, @ViewBuilder label: @escaping () -> Label) {
        self.label = label
        self.enabled = enabled
        self.destination = destination
    }

    public var body: some View {
        VStack(spacing: 0) {
            label().onTapGesture {
                guard enabled else { return }
                linkIsActive = true
            }
            if enabled {
                NavigationLink(isActive: $linkIsActive, destination: destination, label: { EmptyView() })
            }
        }
    }
}
