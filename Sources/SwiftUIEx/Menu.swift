//
//  Menu.swift
//  Rocket Insights
//
//  Created by Ilya Belenkiy on 11/8/21.
//

import SwiftUI

public func menuItem(
    destructive: Bool = false,
    text: String, iconName: String? = nil,
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

    let items: [UIMenuElement]

    public init(
        title: String = "",
        imageSystemName: String? = nil,
        imageName: String? = nil,
        color: Color = Color.accentColor,
        fontSize: CGFloat? = nil,
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
        self.items = items
    }

    public func makeUIView(context: Context) -> some UIView {
        let button = UIButton()
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

    public func updateUIView(_ uiView: UIViewType, context: Context) {
    }
}
