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
    var index: Int { get }
    var value: T { get }
    var selectionIndex: Int? { get }
    init(index: Int, value: T, selection: Binding<Selection<T>?>)
}

extension CollectionCell {
    public var isSelected: Bool {
        selectionIndex == index
    }
}

public struct Collection<Cell: CollectionCell>: View {
    public typealias T = Cell.T
    public let content: [T]
    public var selection: Binding<Selection<T>?>

    public let columnCount: Int
    public let cellMinWidth: CGFloat
    public var spacing: CGFloat?

    public init(
        columnCount: Int = 1,
        content: [T],
        selection: Binding<Selection<T>?>,
        cellMinWidth: CGFloat = minTappableRectSide,
        spacing: CGFloat? = nil
    ) {
        self.columnCount = columnCount
        self.content = content
        self.selection = selection
        self.cellMinWidth = cellMinWidth
        self.spacing = spacing
    }

    public var body: some View {
        if columnCount == 1 {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: cellMinWidth))]) {
                ForEach(content.indices) { index in
                    Cell(index: index, value: content[index], selection: selection)
                }
            }
        }
        else {
            let columns = Array(repeating: GridItem(.flexible()), count: columnCount)
            LazyVGrid(columns: columns) {
                ForEach(content.indices) { index in
                    Cell(index: index, value: content[index], selection: selection)
                }
            }
        }
    }
}
