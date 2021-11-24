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

public protocol NavigationItemContent: Identifiable {
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

    func done(_ done: @escaping (Value?) -> Void) -> NavigationItemView<Self, EmptyView> {
        NavigationItemView(self, done: done)
    }
}

// The sheet content may have the same structural identity, which would lead to showing the same data model
// (or a reducer store) for the sheet every time the sheet is presented if `navContent` was a value.
// The closure type for `navContent` helps ensure that the sheet model is new on every presentation.
public struct SheetNavigation<NavItemContent: NavigationItemContent>: ViewModifier {
    let isPresented: Binding<Bool>
    // The return type is optional because .sheet() is attached to a view unconditionally,
    // even if the content cannot be constructed from the available data.
    let navContent: () -> NavItemContent?
    let done: (NavItemContent.Value) -> Void

    // https://stackoverflow.com/questions/60485329/swiftui-modal-presentation-works-only-once-from-navigationbaritems
    @State private var contentID = UUID()

    init(isPresented: Binding<Bool>, content: @escaping () -> NavItemContent?, done: @escaping (NavItemContent.Value) -> Void) {
        self.isPresented = isPresented
        navContent = content
        self.done = done
    }                                                       

    public func body(content: Content) -> some View {
        content
            .id(contentID)
            .sheet(isPresented: isPresented) {
                navContent()?.done { value in
                    contentID = UUID()
                    isPresented.wrappedValue = false
                    if let value = value {
                        done(value)
                    }
                }
            }
    }
}

public extension View {
    func sheet<NavItemContent: NavigationItemContent>(
        isPresented: Binding<Bool>,
        content: @escaping () -> NavItemContent?,
        done: @escaping (NavItemContent.Value) -> Void
    )
    -> some View {
        modifier(SheetNavigation(isPresented: isPresented, content: content, done: done))
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

    public init(_ content: Content, done: @escaping (Content.Value?) -> Void) {
        self.content = content
        self.linksToDetails = false
        super.init()

        content.value.replaceErrorWithNil()
            .sink { [unowned self] in
                value = $0
                done(value)
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

    init(_ content: Content, done: @escaping (Content.Value?) -> Void) {
        self.navigationItem = NavigationItem(content, done: done)
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
