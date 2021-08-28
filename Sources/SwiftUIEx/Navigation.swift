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
        endFlow { item.linkIsActive = false }
    }
}

public class AnyNavigationItem: ObservableObject {
    @Published public var linkIsActive = false
}

public class NavigationItem<Content: NavigationItemContent>: AnyNavigationItem {
    public let content: Content
    public let linksToDetails: Bool
    private var subscriptions = Set<AnyCancellable>()

    @Published var value: Content.Value?

    public init(_ content: Content, linksToDetails: Bool, sideEffect: (() -> Void)? = nil) {
        self.content = content
        self.linksToDetails = linksToDetails
        super.init()

        content.value.replaceErrorWithNil()
            .sink { [unowned self] in
                value = $0
                linkIsActive = true
                sideEffect?()
            }
            .store(in: &subscriptions)
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
