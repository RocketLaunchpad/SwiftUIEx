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

private struct AnimatablePath_Previews: PreviewProvider {
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
