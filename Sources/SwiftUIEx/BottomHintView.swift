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

public struct BottomHintView: View {
    @Binding public var show: Bool
    public let text: String
    public var color: Color
    public let zIndex: Double

    public var showDuration: TimeInterval
    public var hideDuration: TimeInterval

    private let xWidth: CGFloat = 50

    public init(
        show: Binding<Bool>,
        text: String,
        color: Color = .blue,
        zIndex: Double,
        showDuration: TimeInterval = 0.2,
        hideDuration: TimeInterval = 0.2
    ) {
        _show = show
        self.text = text
        self.color = color
        self.zIndex = zIndex
        self.showDuration = showDuration
        self.hideDuration = hideDuration
    }

    var transition: AnyTransition {
        .asymmetric(insertion: .move(edge: .bottom), removal: .opacity)
    }

    func animation(show: Bool) -> Animation {
        .easeInOut(duration: show ? showDuration : hideDuration)
    }

    public var body: some View {
        Animated(_show, with: { animation(show: $0) }) { showHint in
            VStack(spacing: 0) {
                if showHint {
                    Spacer()
                    HStack(spacing: 0) {
                        Spacer().frame(width: xWidth)
                        Spacer()
                        Text(text)
                            .padding()
                        Spacer()
                        Button(action: { show = false }) {
                            Image(systemName: "multiply").font(.system(size: 25))
                        }
                        .frame(width: xWidth, height: xWidth)
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .background(color.ignoresSafeArea())
                    .transition(transition)
                }
            }
            .zIndex(zIndex)
        }
    }
}

private struct HintView_Previews: PreviewProvider {
    private struct Container: View {
        @State private var show = true

        var body: some View {
            ZStack {
                Color.white.ignoresSafeArea()
                Button("Toggle Hint") { show.toggle() }
                BottomHintView(
                    show: $show,
                    text: "A useful hint for something you might miss otherwise",
                    color: .red,
                    zIndex: 1
                )
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
