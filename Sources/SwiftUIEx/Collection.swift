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

    public enum CellWidth {
        case fixed(CGFloat)
        case min(CGFloat)
    }

    public typealias T = Cell.T
    public let content: [T]
    public var selection: Binding<T?>

    public let cellWidth: CellWidth
    public let columnCount: Int?
    public let columnSpacing: CGFloat?
    public let rowSpacing: CGFloat?

    private let gridItem: GridItem

    @State private var contentWidth: CGFloat?

    func evalContentWidth(availableWidth: CGFloat) -> CGFloat? {
        func width(columnCount: Int, cellWidth: CGFloat) -> CGFloat {
            CGFloat(columnCount) * cellWidth + CGFloat(columnCount - 1) * (columnSpacing ?? 0)
        }

        switch cellWidth {
        case .fixed(let value):
            if let count = columnCount {
                return width(columnCount: count, cellWidth: value)                
            }
            else {
                let w = availableWidth
                let d1 = value
                let d2 = columnSpacing ?? 0
                // c * d1 + (c-1) * d2 <= w
                return width(columnCount: Int(floor((w + d2) / (d1 + d2))), cellWidth: value)
            }
        case .min:
            return nil
        }
    }

    public init(
        content: [T],
        selection: Binding<T?>,
        columnCount: Int? = nil,
        columnSpacing: CGFloat? = nil,
        rowSpacing: CGFloat? = nil,
        cellWidth: CellWidth? = nil
    ) {
        self.content = content
        self.selection = selection

        self.cellWidth = cellWidth ?? .min(minTappableRectSide)
        self.columnCount = columnCount
        self.columnSpacing = columnSpacing
        self.rowSpacing = rowSpacing

        switch self.cellWidth {
        case .fixed(let value):
            gridItem = GridItem(
                columnCount != nil ? .fixed(value) : .adaptive(minimum: value, maximum: value),
                spacing: columnSpacing
            )

        case .min(let value):
            gridItem = GridItem(
                columnCount != nil ? .flexible(minimum: value) : .adaptive(minimum: value),
                spacing: columnSpacing
            )
        }
    }

    public var body: some View {
        let columns = Array(repeating: gridItem, count: columnCount ?? 1)
        LazyVGrid(columns: columns, spacing: rowSpacing) {
            ForEach(content) {
                Cell(value: $0, selection: selection)
            }
        }
        .measurement(ContentWidthKey.self) { $0.size.width }
        .onPreferenceChange(ContentWidthKey.self) { width in
            contentWidth = width.flatMap { evalContentWidth(availableWidth: $0) }
        }
    }
}
