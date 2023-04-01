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

public protocol DetailView: View {
    var showBackButton: Bool { get set }
    var backAction: () -> Void { get set }
}

public extension Animation {
    static let slide: Self = spring(response: 0.3, dampingFraction: 1)
}

public struct MasterDetailView<Master: View, Detail: DetailView>: View {
    let master: Master
    var detail: Detail
    let masterWidth: CGFloat
    let showAll: Bool

    @Binding var showDetail: Bool

    public init(master: () -> Master, detail: () -> Detail, masterWidth: CGFloat = 375, showAll: Bool, showDetail: Binding<Bool>) {
        self.master = master()
        self.detail = detail()
        self.detail.showBackButton = !showAll
        self.detail.backAction = { showDetail.wrappedValue = false }
        self.masterWidth = masterWidth
        self.showAll = showAll
        self._showDetail = showDetail
    }

    public var body: some View {
        GeometryReader { proxy in
            ZStack {
                master
                    .frame(width: showAll ? masterWidth : nil)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .zIndex(0)

                if showAll {
                    HStack {
                        Spacer()
                            .frame(width: masterWidth)
                        Divider()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .zIndex(2)
                }

                if showDetail || showAll {
                    detail
                        .frame(width: showAll ? proxy.size.width - masterWidth : nil)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .zIndex(1)
                        .transition(showAll ? .identity : .move(edge: .trailing))
                }
            }
        }
    }
}
