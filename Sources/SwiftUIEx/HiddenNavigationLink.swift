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

import Foundation
import SwiftUI

public struct HiddenNavigationLink<Destination: View>: View {
    @Binding var linkIsActive: Bool
    let destination: () -> Destination?

    public init(isActive: Binding<Bool>, @ViewBuilder destination: @escaping () -> Destination) {
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
