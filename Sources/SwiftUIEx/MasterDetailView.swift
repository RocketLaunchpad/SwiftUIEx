//
//  MasterDetailView.swift
//  Rocket Insights
//
//  Created by Ilya Belenkiy on 8/20/21.
//

import SwiftUI

public struct MasterDetailView<Master: View, Detail: View>: View {
    let master: Master
    let detail: Detail
    let masterWidth: CGFloat

    public init(master: Master, detail: Detail, masterWidth: CGFloat = 375) {
        self.master = master
        self.detail = detail
        self.masterWidth = masterWidth
    }

    public var body: some View {
        HStack(spacing: 0) {
            master.frame(width: masterWidth)
            Divider()
            detail
        }
    }
}
