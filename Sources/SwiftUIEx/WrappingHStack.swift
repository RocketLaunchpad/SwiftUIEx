//
//  WrappingHStack.swift
//  
//
//  Created by Ilya Belenkiy on 8/27/21.
//

import SwiftUI
import FoundationEx
import Tagged

public struct WrappingHStack<Data, Cell>: View where Data: RandomAccessCollection, Data.Element: Identifiable, Cell: View {
    enum ContentWidthTag {}
    typealias ContentWidthKey = MeasurementKey<CGFloat, ContentWidthTag>

    enum SizeTag {}
    typealias SizeKey = MeasurementKey<CGSize, SizeTag>

    struct Layout {
        let frames: [Data.Element.ID: CGRect]
        let contentWidth: CGFloat
        let contentHeight: CGFloat
    }

    let rowAlignment: VerticalAlignment
    let spacing: CGFloat
    let rowSpacing: CGFloat
    let data: [Data.Element]
    let cellFunc: (Data.Element) -> Cell

    @State private var cellSizes: [Data.Element.ID: CGSize] = [:]
    @State private var availableWidth: CGFloat?

    func layout(availableWidth: CGFloat) -> Layout {
        var frames: [Data.Element.ID: CGRect] = [:]
        var contentWidth: CGFloat = 0
        var contentHeight: CGFloat = 0

        var row: [Data.Element] = []
        var offsetX: CGFloat = 0
        var offsetY: CGFloat = 0
        var rowHeight: CGFloat = 0

        func getCellSize(_ element: Data.Element) -> CGSize {
            cellSizes[element.id] ?? .zero
        }

        func addToRow(_ element: Data.Element, _ cellSize: CGSize) {
            row.append(element)
            let toElementSpacing = (element.id == data.first?.id) ? 0 : spacing
            offsetX += (toElementSpacing + cellSize.width)
            rowHeight = max(rowHeight, cellSize.height)
        }

        func processRow() {
            guard !row.isEmpty else { return }

            contentWidth = max(contentWidth, offsetX)
            offsetX = 0

            let toRowSpacing = (row.first?.id == data.first?.id) ? 0 : rowSpacing
            offsetY += toRowSpacing
            contentHeight = offsetY + rowHeight

            for element in row {
                let cellSize = getCellSize(element)

                let originY: CGFloat
                switch rowAlignment {
                case .top:
                    originY = offsetY
                case .center:
                    originY = offsetY + rowHeight / 2.0 - cellSize.height / 2.0
                case .bottom:
                    originY = offsetY + rowHeight - cellSize.height
                default:
                    assertionFailure("Not implemented")
                    originY = offsetY + rowHeight - cellSize.height
                }
                frames[element.id] = CGRect(x: offsetX, y: originY, width: cellSize.width, height: cellSize.height)
                offsetX += cellSize.width + spacing
            }

            row.removeAll()
            offsetX = 0
            offsetY += rowHeight
            rowHeight = 0
        }

        for element in data {
            let cellSize = getCellSize(element)
            if offsetX + spacing + cellSize.width <= availableWidth {
                addToRow(element, cellSize)
            }
            else {
                processRow()
                addToRow(element, cellSize)
            }
        }
        processRow()

        return .init(frames: frames, contentWidth: contentWidth, contentHeight: contentHeight)
    }

    public init(
        rowAlignment: VerticalAlignment = .center,
        spacing: CGFloat = 10,
        rowSpacing: CGFloat? = nil,
        _ dataContent: Data,
        content: @escaping (Data.Element) -> Cell
    ) {
        self.rowAlignment = rowAlignment
        self.spacing = spacing
        self.rowSpacing = rowSpacing ?? spacing

        var data: [Data.Element] = []
        for elem in dataContent {
            // inefficient, but most flexible and should not be a problem for a small collection
            // that WrappingHStack is meant to display.
            if !data.contains(where: {$0.id == elem.id }) {
                data.append(elem)
            }
            else {
                SwiftUIEx.env.logCodingError("WrappingHStack expected elements with unique IDs. Found duplicate ID: \(elem.id)")
            }
        }
        self.data = data

        self.cellFunc = content
    }

    public var body: some View {
        ZStack(alignment: .topLeading) {
            Color.clear.frame(height: 1) // take all available space for the measurement

            ForEach(data) { element in
                cellFunc(element)
                    .fixedSize()
                    .measureSize(SizeKey.self) {
                        cellSizes[element.id] = $0
                    }
                    .hidden()
            }

            if let layout = availableWidth.flatMap({ layout(availableWidth: $0) }) {
                ForEach(data) { element in
                    if let frame = layout.frames[element.id] {
                        let center = CGPoint(x: frame.midX, y: frame.midY)
                        cellFunc(element)
                            .fixedSize()
                            .position(center)
                    }
                }
                .frame(width: layout.contentWidth, height: layout.contentHeight)
            }
        }
        .measureWidth(ContentWidthKey.self) {
            availableWidth = $0
        }
    }
}

private struct Container: View {
    struct Tag: Identifiable {
        let text: String
        var id: UUID

        init(_ text: String) {
            self.text = text
            id = UUID()
        }
    }

    static let strings = [
        "#viral",  "#share", "#youtubekids", "#subscribers", "#trending",
        "#comment", "#followforfollowback", "youtubemusic", "#contentcreator", "#explore",
        "#music", "#follow"
    ]

    @State var data: [Tag] = []

    func removeFirst() {
        _ = withAnimation(.easeInOut(duration: 0.5)) {
            data.removeFirst()
        }
    }

    func removeLast() {
        _ = withAnimation(.easeInOut(duration: 0.5)) {
            data.removeLast()
        }
    }

    func addRandom() {
        withAnimation(.easeInOut(duration: 0.5)) {
            data.append(.init(Self.strings.randomElement() ?? ""))
        }
    }

    var body: some View {
        VStack {
            WrappingHStack(data) { tag in
                Text(tag.text)
                    .padding(7)
                    .roundedRectBackground(borderColor: .gray, cornerRadius: .value(7), borderWidth: 2)
                    .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
            }
            .padding()

            HStack(spacing: 30) {
                Button("Add", action: addRandom)
                Button("- First", action: removeFirst)
                Button("- Last", action: removeLast)
            }

            Spacer()
        }
    }
}

public struct WrappingHStack_Previews: PreviewProvider {
    public static var preview: some View {
         Container()
    }

    public static var previews: some View {
        preview
    }
}
