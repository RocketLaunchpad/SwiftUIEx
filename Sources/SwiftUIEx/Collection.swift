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

    @State private var contentWidth: CGFloat?

    func evalContentWidth(availableWidth: CGFloat) -> CGFloat {
        guard let cellWidth = cellWidth else {
            return availableWidth
        }

        func width(columnCount: Int, cellWidth: CGFloat) -> CGFloat {
            CGFloat(columnCount) * cellWidth + CGFloat(columnCount - 1) * (columnSpacing ?? 0)
        }

        if let count = columnCount {
            return width(columnCount: count, cellWidth: cellWidth)
        }
        else {
            let w = availableWidth
            let d1 = cellWidth
            let d2 = columnSpacing ?? 0
            // c * d1 + (c-1) * d2 <= w
            return width(columnCount: Int(floor((w + d2) / (d1 + d2))), cellWidth: cellWidth)
        }
    }

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
        .measure(ContentWidthKey.self, { $0.size.width }) {
            contentWidth = $0.flatMap { evalContentWidth(availableWidth: $0) }
        }
    }
}
