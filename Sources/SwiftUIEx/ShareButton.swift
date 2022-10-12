//
//  ShareButton.swift
//  Rocket Insights
//
//  Created by Ilya Belenkiy on 9/25/22.
//

import UIKit
import SwiftUI

public struct ShareButton: UIViewRepresentable {
    public class Coordinator {
        var parent: ShareButton
        
        init(parent: ShareButton) {
            self.parent = parent
        }
    }
    
    public struct ShareContext {
        let activityItems: [Any]
        let applicationActivities: [UIActivity]?
        let excludedActivityTypes: [UIActivity.ActivityType]?
        
        public init(activityItems: [Any], applicationActivities: [UIActivity]?, excludedActivityTypes: [UIActivity.ActivityType]?) {
            self.activityItems = activityItems
            self.applicationActivities = applicationActivities
            self.excludedActivityTypes = excludedActivityTypes
        }
    }
    
    @Environment(\.isEnabled) var isEnabled

    @Binding var isPresented: Bool
    let action: () -> Void
    let menuItems: [UIMenuElement]
    @Binding var shareContext: ShareContext
    
    public init(isPresented: Binding<Bool>, action: @escaping () -> Void, menuItems: [UIMenuElement], shareContext: Binding<ShareContext>) {
        self._isPresented = isPresented
        self.action = action
        self.menuItems = menuItems
        self._shareContext = shareContext
    }
        
    public func makeUIView(context: Context) -> some UIView {
        ShareButtonContainerView(coordinator: context.coordinator, action: action, menuItems: menuItems, shareContext: shareContext)
    }

    public func updateUIView(_ uiView: UIViewType, context: Context) {
        guard let view = uiView as? ShareButtonContainerView else {
            assertionFailure()
            return
        }
        
        view.shareContext = shareContext
        view.vc.updateIsEnabled(isEnabled)
        if isPresented {
            view.vc.showShareSheet()
        }
        else {
            view.vc.hideShareSheetIfNeeded()
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}

class ShareButtonContainerView: UIView {
    var shareContext: ShareButton.ShareContext {
        didSet {
            vc.shareContext = shareContext
        }
    }
    
    let vc: ShareButtonVC
    
    init(coordinator: ShareButton.Coordinator, action: @escaping () -> Void, menuItems: [UIMenuElement], shareContext: ShareButton.ShareContext) {
        self.shareContext = shareContext
        self.vc = ShareButtonVC(coordinator: coordinator, action: action, menuItems: menuItems, shareContext: shareContext)
        
        super.init(frame: .zero)
        
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(vc.view)
        self.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor).isActive = true
        self.topAnchor.constraint(equalTo: vc.view.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor).isActive = true
    }
    
    override var intrinsicContentSize: CGSize {
        vc.view.intrinsicContentSize
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class ShareButtonVC: UIViewController {
    let coordinator: ShareButton.Coordinator
    let action: () -> Void
    let menuItems: [UIMenuElement]
    var shareContext: ShareButton.ShareContext

    private var button: UIButton!
    
    init(coordinator: ShareButton.Coordinator, action: @escaping () -> Void, menuItems: [UIMenuElement], shareContext: ShareButton.ShareContext) {
        self.coordinator = coordinator
        self.action = action
        self.menuItems = menuItems
        self.shareContext = shareContext
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        button = UIButton()
        view = button
        
        let image = UIImage(
            systemName: "square.and.arrow.up",
            withConfiguration: UIImage.SymbolConfiguration(font: .preferredFont(forTextStyle: .title3))
        )
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(runAction), for: .touchUpInside)
        if !menuItems.isEmpty {
            button.menu = UIMenu(children: menuItems)
        }
    }
    
    func updateIsEnabled(_ value: Bool) {
        button.isEnabled = value
    }
    
    @IBAction func runAction() {
        action()
    }
    
    func showShareSheet() {
        guard presentedViewController == nil else { return }        
        let shareSheet = ShareSheetVC(coordinator: coordinator, shareContext: shareContext)
        shareSheet.popoverPresentationController?.sourceView = button
        present(shareSheet, animated: true)
    }
    
    func hideShareSheetIfNeeded() {
        presentedViewController?.dismiss(animated: true)
    }
    
    public override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag) { [weak self] in
            completion?()
            self?.coordinator.parent.isPresented = false
        }
    }

}

fileprivate class ShareSheetVC: UIActivityViewController {
    let coordinator: ShareButton.Coordinator

    init(coordinator: ShareButton.Coordinator, shareContext: ShareButton.ShareContext) {
        self.coordinator = coordinator
        super.init(activityItems: shareContext.activityItems, applicationActivities: shareContext.applicationActivities)
        excludedActivityTypes = shareContext.excludedActivityTypes
    }
}
