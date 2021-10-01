//
//  Collection.swift
//  Rocket Insights
//
//  Created by Ilya Belenkiy on 8/7/21.
//

import SwiftUI

public protocol CollectionCell: View {
    associatedtype T: Identifiable
    var value: T { get }
    var selection: T? { get }
    init(value: T, selection: Binding<T?>)
}

extension CollectionCell {
    public var isSelected: Bool {
        selection?.id == value.id
    }
}

public struct Collection<Cell: CollectionCell>: View {
    enum ContentWidthTag {}
    typealias ContentWidthKey = MeasurementKey<CGFloat, ContentWidthTag>

    public typealias T = Cell.T
    public let content: [T]
    public var selection: Binding<T?>

    public let cellWidth: CGFloat?
    public let columnCount: Int?
    public let columnSpacing: CGFloat?
    public let rowSpacing: CGFloat?

    private let gridItem: GridItem

    public init(
        content: [T],
        selection: Binding<T?>,
        columnCount: Int? = nil,
        columnSpacing: CGFloat? = nil,
        rowSpacing: CGFloat? = nil,
        cellWidth: CGFloat? = nil
    ) {
        self.content = content
        self.selection = selection

        self.cellWidth = cellWidth
        self.columnCount = columnCount
        self.columnSpacing = columnSpacing
        self.rowSpacing = rowSpacing

        if let cellWidth = cellWidth {
            gridItem = GridItem(
                columnCount != nil ? .fixed(cellWidth) : .adaptive(minimum: cellWidth, maximum: cellWidth),
                spacing: columnSpacing
            )
        }
        else if columnCount != nil {
            gridItem = GridItem(.flexible(), spacing: columnSpacing)
        }
        else {
            assertionFailure("Expected either columnCount or cellWidth to not be nil")
            gridItem = GridItem(.fixed(50))
        }
    }

    public var body: some View {
        let columns = Array(repeating: gridItem, count: columnCount ?? 1)
        LazyVGrid(columns: columns, spacing: rowSpacing) {
            ForEach(content) {
                Cell(value: $0, selection: selection)
            }
        }
    }
}
