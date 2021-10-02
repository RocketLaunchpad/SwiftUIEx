//
//  AnimatablePath.swift
//  Rocket Insights
//
//  Created by Ilya Belenkiy on 10/1/21.
//

import SwiftUI

public struct AnimatablePath: View {
    struct PathWrapper: Shape {
        let path: Path
        var end: CGFloat

        init(path: Path, end: CGFloat) {
            self.path = path
            self.end = end
        }

        var animatableData: CGFloat {
            get { end }
            set { end = newValue }
        }

        func path(in rect: CGRect) -> Path {
            return path.trimmedPath(from: 0, to: end)
        }
    }

    public let path: Path
    public var end: CGFloat
    public let strokeStyle: StrokeStyle

    /// - Parameters:
    ///   - path: the path to animate
    ///   - end: the end of the visible stroke (0 is the start of the path, and 1 is the end)
    ///   - strokeStyle: the stroke style
    public init(path: Path, end: CGFloat, strokeStyle: StrokeStyle) {
        self.path = path
        self.end = end
        self.strokeStyle = strokeStyle
    }

    public var body: some View {
        let size = path.boundingRect.size
        PathWrapper(path: path, end: end)
            .stroke(style: strokeStyle)
            .frame(width: size.width, height: size.height)
    }
}

struct AnimatablePath_Previews: PreviewProvider {
    private struct Container: View {
        static let checkMark: Path = {
            let rect = CGRect(x: 0, y: 0, width: 30, height: 30)
            var path = Path()
            path.move(to: .init(x: rect.minX, y: rect.midY))
            path.addLine(to: .init(x: rect.width / 3, y: rect.maxY))
            path.addLine(to: .init(x: rect.maxX, y: rect.minY))
            return path
        }()

        @State private var showCheckmark = false

        var body: some View {
            VStack(spacing: 25) {
                HStack(spacing: 50) {
                    Button("Draw") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showCheckmark = true
                        }
                    }

                    Button("Erase") {
                        showCheckmark = false
                    }
                }

                AnimatablePath(
                    path: Self.checkMark,
                    end: showCheckmark ? 1 : 0,
                    strokeStyle: .init(lineWidth: 4, lineCap: .round, lineJoin: .round)
                )
                .foregroundColor(.blue)
            }
        }
    }
    
    static var preview: some View {
        Container()
    }

    static var previews: some View {
        preview
    }
}
