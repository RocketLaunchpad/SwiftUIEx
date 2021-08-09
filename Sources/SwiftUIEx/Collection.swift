//
//  Collection.swift
//  Rocket Insights
//
//  Created by Ilya Belenkiy on 8/7/21.
//

import SwiftUI

public struct Selection<T> {
    public let index: Int
    public let value: T

    public init(index: Int, value: T) {
        self.index = index
        self.value = value
    }
}

public protocol CollectionCell: View {
    associatedtype T
    init(index: Int, value: T, selection: Binding<Selection<T>?>)
}

public struct Collection<Cell: CollectionCell>: View {
    public typealias T = Cell.T
    public let content: [T]
    public var selection: Binding<Selection<T>?>

    public let cellMinWidth: CGFloat
    public var spacing: CGFloat?

    public init(content: [T], selection: Binding<Selection<T>?>, cellMinWidth: CGFloat = minTappableRectSide, spacing: CGFloat? = nil) {
        self.content = content
        self.selection = selection
        self.cellMinWidth = cellMinWidth
        self.spacing = spacing
    }

    public var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: cellMinWidth))]) {
            ForEach(content.indices) { index in
                Cell(index: index, value: content[index], selection: selection)
            }
        }
    }
}
