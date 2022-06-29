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
}

public enum NavigationItemLinkAction {
    case activateLink
    case endFlow
}

@MainActor
public extension NavigationItemContent {
    func then<V: View>(
        sideEffect: ((Value?) -> NavigationItemLinkAction)? = nil,
        @ViewBuilder next: @escaping (Value, AnyNavigationItem) -> V
    )
    -> NavigationItemView<Self, V> {
        NavigationItemView(self, sideEffect: sideEffect, next: next)
    }

    func thenDetails<V: View>(@ViewBuilder next: @escaping (Value, AnyNavigationItem) -> V) -> NavigationItemView<Self, V> {
        NavigationItemView(self, linksToDetails: true, next: next)
    }

    func endFlow(with sideEffect: ((Value?) -> Void)? = nil) -> NavigationItemView<Self, EmptyView> {
        NavigationItemView(self, sideEffect: sideEffect)
    }

    func thenPop(to item: AnyNavigationItem) -> some View {
        endFlow { _ in item.deactivateLink() }
    }

    func done(_ done: @escaping (Value?) -> Void) -> NavigationItemView<Self, EmptyView> {
        NavigationItemView(self, done: done)
    }
}

// The sheet content may have the same structural identity, which would lead to showing the same data model
// (or a reducer store) for the sheet every time the sheet is presented if `navContent` was a value.
// The closure type for `navContent` helps ensure that the sheet model is new on every presentation.
public struct SheetNavigation<NavItemContent: NavigationItemContent>: ViewModifier {
    @Binding var isPresented: Bool
    // The return type is optional because .sheet() is attached to a view unconditionally,
    // even if the content cannot be constructed from the available data.
    let navContent: () -> NavItemContent?
    let fullScreen: Bool
    let wrapInNavigationView: Bool
    let done: (NavItemContent.Value) -> Void
    let onDismiss: () -> Void

    init(
        isPresented: Binding<Bool>,
        content: @escaping () -> NavItemContent?,
        fullScreen: Bool = false,
        wrapInNavigationView: Bool = false,
        done: @escaping (NavItemContent.Value) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        _isPresented = isPresented
        navContent = content
        self.fullScreen = fullScreen
        self.wrapInNavigationView = wrapInNavigationView
        self.done = done
        self.onDismiss = onDismiss
    }                                                       

    public func body(content: Content) -> some View {
        let presentedContent = {
            navContent()?.done { value in
                isPresented = false
                if let value = value {
                    done(value)
                }
            }
        }

        if fullScreen {
            content.fullScreenCover(isPresented: $isPresented, onDismiss: onDismiss) {
                if wrapInNavigationView {
                    NavigationView {
                        presentedContent()
                    }
                    .navigationViewStyle(.stack)
                }
                else {
                    presentedContent()
                }
            }
        }
        else {
            content.sheet(isPresented: $isPresented, onDismiss: onDismiss) {
                if wrapInNavigationView {
                    NavigationView {
                        presentedContent()
                    }
                    .navigationViewStyle(.stack)
                }
                else {
                    presentedContent()
                }
            }
        }
    }
}

public extension View {
    func sheet<NavItemContent: NavigationItemContent>(
        isPresented: Binding<Bool>,
        content: @escaping () -> NavItemContent?,
        fullScreen: Bool = false,
        wrapInNavigationView: Bool = false,
        done: @escaping (NavItemContent.Value) -> Void,
        onDismiss: @escaping () -> Void
    )
    -> some View {
        modifier(
            SheetNavigation(
                isPresented: isPresented,
                content: content,
                fullScreen: fullScreen,
                wrapInNavigationView: wrapInNavigationView,
                done: done,
                onDismiss: onDismiss
            )
        )
    }
}

@MainActor
public class AnyNavigationItem {
    func deactivateLink() {}

    public func popToSelf() -> EmptyView {
        deactivateLink()
        return EmptyView()
    }
}

@MainActor
public final class NavigationItem<Content: NavigationItemContent>: AnyNavigationItem, ObservableObject {
    public let content: Content
    public let linksToDetails: Bool
    private var subscriptions = Set<AnyCancellable>()

    @Published public var linkIsActive = false
    @Published var value: Content.Value?

    public init(_ content: Content, linksToDetails: Bool, sideEffect: ((Content.Value?) -> NavigationItemLinkAction)? = nil) {
        self.content = content
        self.linksToDetails = linksToDetails
        super.init()

        content.value.replaceErrorWithNil()
            .sink { [unowned self] in
                value = $0
                let linkAction = sideEffect?(value) ?? .activateLink
                if value != nil, linkAction == .activateLink {
                    linkIsActive = true
                }
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

    public init(
        _ content: Content, linksToDetails: Bool = false,
        sideEffect: ((Content.Value?) -> NavigationItemLinkAction)? = nil,
        @ViewBuilder next: @escaping (Content.Value, AnyNavigationItem) -> NextView
    )
    {
        self.navigationItem = NavigationItem(content, linksToDetails: linksToDetails, sideEffect: sideEffect)
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
    init(_ content: Content, sideEffect: ((Content.Value?) -> Void)? = nil) {
        self.navigationItem = NavigationItem(
            content,
            linksToDetails: false,
            sideEffect: sideEffect.map { f in { f($0); return .endFlow } }
        )
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
                Image(systemName:"chevron.right")
                    .foregroundColor(.systemGray3)
                    .font(.body.weight(.semibold))
                    .padding(.horizontal, 15)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(NavigationCellButtonStyle())
    }
}

public struct NavigationRowLink<V: View, D: View>: View {
    @Binding var linkIsActive: Bool
    public let label: V
    public let destination: D

    public init(isActive: Binding<Bool>, @ViewBuilder label: () -> V, @ViewBuilder destination: () -> D) {
        self._linkIsActive = isActive
        self.label = label()
        self.destination = destination()
    }

    public init(isActive: Binding<Bool>, @ViewBuilder destination: () -> D) where V == EmptyView {
        self._linkIsActive = isActive
        self.label = EmptyView()
        self.destination = destination()
    }

    public var body: some View {
        VStack(spacing: 0) {
            NavigationRow(action: { linkIsActive = true }, label: label)
            NavigationLink(isActive: _linkIsActive, destination: { destination }, label: { EmptyView() })
        }
    }
}

public struct NavigationCellButtonStyle: ButtonStyle {
    public func makeBody(configuration config: Configuration) -> some View {
        config.label.background(config.isPressed ? Color.systemGray5 : .clear )
    }
}
