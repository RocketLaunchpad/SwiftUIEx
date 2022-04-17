//
//  HiddenNavigationLink.swift
//  Rocket Insights
//
//  Created by Ilya Belenkiy on 4/13/22.
//

import Foundation
import SwiftUI

public struct HiddenNavigationLink<Destination: View>: View {
    @Binding var linkIsActive: Bool
    let destination: () -> Destination?

    public init(isActive: Binding<Bool>, destination: @autoclosure @escaping () -> Destination) {
        self._linkIsActive = isActive
        self.destination = destination
    }

    public init<T: NavigationItemContent>(isActive: Binding<Bool>, content: @escaping () -> T?)
    where Destination == NavigationItemView<T, EmptyView>
    {
        self._linkIsActive = isActive
        self.destination = {
            content().map { NavigationItemView($0) }
        }
    }

    public var body: some View {
        NavigationLink(isActive: $linkIsActive, destination: destination, label: { EmptyView() })
    }
}
