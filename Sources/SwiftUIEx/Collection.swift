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
