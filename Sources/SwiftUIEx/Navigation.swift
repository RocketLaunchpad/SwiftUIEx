//
//  Navigation.swift
//  Navigation
//
//  Created by Ilya Belenkiy on 8/1/21.
//

import Foundation
import Combine
import CombineEx
import SwiftUI

public protocol NavigationItemContent {
    associatedtype ContentView: View
    associatedtype Value

    func makeView() -> ContentView
    var value: AnyPublisher<Value, Cancel> { get }

    func canActivateLink(_ value: Value) -> Bool
}

public extension NavigationItemContent {
    func canActivateLink(_ value: Value) -> Bool {
        true
    }
}

public extension NavigationItemContent {
    func then<V: View>(@ViewBuilder next: @escaping (Value, AnyNavigationItem) -> V) -> NavigationItemView<Self, V> {
        NavigationItemView(self, next: next)
    }

    func thenDetails<V: View>(@ViewBuilder next: @escaping (Value, AnyNavigationItem) -> V) -> NavigationItemView<Self, V> {
        NavigationItemView(self, linksToDetails: true, next: next)
    }

    func endFlow(with sideEffect: (() -> Void)? = nil) -> NavigationItemView<Self, EmptyView> {
        NavigationItemView(self, sideEffect: sideEffect)
    }

    func thenPop(to item: AnyNavigationItem) -> some View {
        endFlow { item.deactivateLink() }
    }
}

public class AnyNavigationItem {
    func deactivateLink() {}

    public func popToSelf() -> EmptyView {
        deactivateLink()
        return EmptyView()
    }
}

public final class NavigationItem<Content: NavigationItemContent>: AnyNavigationItem, ObservableObject {
    public let content: Content
    public let linksToDetails: Bool
    private var subscriptions = Set<AnyCancellable>()

    @Published public var linkIsActive = false
    @Published var value: Content.Value?

    public init(_ content: Content, linksToDetails: Bool, sideEffect: (() -> Void)? = nil) {
        self.content = content
        self.linksToDetails = linksToDetails
        super.init()

        content.value.replaceErrorWithNil()
            .sink { [unowned self] in
                value = $0
                if let value = value {
                    linkIsActive = self.content.canActivateLink(value)
                }
                sideEffect?()
            }
            .store(in: &subscriptions)
    }

    override func deactivateLink() {
        super.deactivateLink()
        linkIsActive = false
    }
}

public struct NavigationItemView<Content: NavigationItemContent, NextView: View>: View {
    @ObservedObject public var navigationItem: NavigationItem<Content>
    public let nextView: (Content.Value, AnyNavigationItem) -> NextView

    public init(_ content: Content, linksToDetails: Bool = false, @ViewBuilder next: @escaping (Content.Value, AnyNavigationItem) -> NextView) {
        self.navigationItem = NavigationItem(content, linksToDetails: linksToDetails)
        self.nextView = next
    }

    @ViewBuilder
    private func makeNextView() -> some View {
        if let value = navigationItem.value {
            nextView(value, navigationItem)
        }
        else {
            EmptyView()
        }
    }

    public var body: some View {
        VStack {
            navigationItem.content.makeView()
            if NextView.self != EmptyView.self {
                NavigationLink(
                    destination: makeNextView(),
                    isActive: $navigationItem.linkIsActive,
                    label: { EmptyView() }
                )
                .isDetailLink(navigationItem.linksToDetails)
            }
        }
    }
}

public extension NavigationItemView where NextView == EmptyView {
    init(_ content: Content, sideEffect: (() -> Void)? = nil) {
        self.navigationItem = NavigationItem(content, linksToDetails: false, sideEffect: sideEffect)
        self.nextView = { _, _ in EmptyView() }
    }
}

public struct NavigationRow<V: View>: View {
    public let label: V
    public let action: () -> Void

    public init(action: @escaping () -> Void, label: @autoclosure () -> V) {
        self.label = label()
        self.action = action
    }

    public init(_ titleKey: LocalizedStringKey, action: @escaping () -> Void) where V == Text {
        self.init(action: action, label: Text(titleKey))
    }

    public init(_ title: String, action: @escaping () -> Void) where V == Text {
        self.init(action: action, label: Text(title))
    }

    public var body: some View {
        Button(action: action) {
            HStack {
                label
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}
