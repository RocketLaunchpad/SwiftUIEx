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

public func menuItem(
    destructive: Bool = false,
    text: String,
    iconName: String? = nil,
    disabled: Bool = false,
    action: @escaping () -> Void
)
-> UIAction
{
    var attributes: UIMenuElement.Attributes = []
    if destructive {
        attributes.insert(.destructive)
    }
    if disabled {
        attributes.insert(.disabled)
    }

    return .init(
        title: text,
        image: iconName.flatMap { UIImage(systemName: $0) },
        attributes: attributes,
        handler: { _ in action() }
    )
}

public func menuItem(
    destructive: Bool = false,
    text: String,
    imageSystemName: String? = nil,
    imageName: String? = nil,
    disabled: Bool = false,
    action: @escaping () -> Void
)
-> UIAction
{
    var attributes: UIMenuElement.Attributes = []
    if destructive {
        attributes.insert(.destructive)
    }
    if disabled {
        attributes.insert(.disabled)
    }

    return .init(
        title: text,
        image: imageName.flatMap { UIImage(named: $0) } ?? imageSystemName.flatMap { UIImage(systemName: $0) },
        attributes: attributes,
        handler: { _ in action() }
    )
}

public func submenuItem(text: String, iconName: String? = nil, items: [UIMenuElement]) -> UIMenu {
    .init(
        title: text,
        image: iconName.flatMap { UIImage(systemName: $0) },
        children: items
    )
}

public struct MenuButton: UIViewRepresentable {
    let title: String
    let image: UIImage?
    let color: UIColor
    let padding: CGFloat

    let items: [UIMenuElement]

    public init(
        title: String = "",
        imageSystemName: String? = nil,
        imageName: String? = nil,
        color: Color = Color.accentColor,
        fontSize: CGFloat? = nil,
        padding: CGFloat = 0,
        items: [UIMenuElement]
    ) {
        self.title = title

        if let name = imageSystemName {
            let config: UIImage.SymbolConfiguration?
            if let fontSize = fontSize {
                config = UIImage.SymbolConfiguration(pointSize: fontSize, weight: .regular)
            }
            else {
                config = nil
            }
            image = UIImage(systemName: name, withConfiguration: config)
        }
        else if let name = imageName {
            image = UIImage(named: name)
        }
        else {
            self.image = nil
        }

        self.color = .init(color)
        self.padding = padding
        self.items = items
    }

    public func makeButton() -> UIButton {
        let button = UIButton()
        button.contentEdgeInsets = .init(top: padding, left: padding, bottom: padding, right: padding)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentHuggingPriority(.required, for: .vertical)

        button.setTitleColor(color, for: .normal)
        if !title.isEmpty {
            button.setTitle(title, for: .normal)
        }
        button.setImage(image, for: .normal)
        button.tintColor = color

        button.menu = UIMenu(children: items)
        button.showsMenuAsPrimaryAction = true

        return button
    }

    public func makeUIView(context: Context) -> some UIView {
        makeButton()
    }

    public func updateUIView(_ uiView: UIViewType, context: Context) {
    }
}
