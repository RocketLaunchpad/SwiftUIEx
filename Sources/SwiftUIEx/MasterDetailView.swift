//
//  MasterDetailView.swift
//  Rocket Insights
//
//  Created by Ilya Belenkiy on 8/20/21.
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
