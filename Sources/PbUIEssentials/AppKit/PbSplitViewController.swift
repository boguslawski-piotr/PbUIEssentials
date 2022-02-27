/// Swift PbUIEssentials
/// Copyright (c) Piotr Boguslawski
/// MIT license, see License.md file for details.

#if os(macOS)

import SwiftUI
import PbEssentials
import PbRepository

open class PbSplitViewController: NSSplitViewController, PbObservableObject {
    // MARK: Definitions
    
    public struct State: Codable, Equatable {
        var sidebarFrame: String = NSStringFromRect(NSZeroRect)
        var isSidebarCollapsed: Bool = false
    }
    
    @PbPublished(.withLock) open var restoreStateDidEnd = false
    @PbStored("") open var state = State()
    
    open var views: [AnyView]!
    open var name: String = "" {
        didSet {
            nameDidSet()
        }
    }
    
    open func nameDidSet() {
        if !name.isEmpty {
            _state.name = name + ".\(self.classForCoder)"
            saveState()
        }
    }

    open override var title: String? {
        get { super.title }
        set {
            objectWillChange.send()
            super.title = newValue
        }
    }
    
    // MARK: Initialization
    
    public init(name: String? = nil, _ views: [AnyView]) {
        super.init(nibName: nil, bundle: nil)
        self.views = views.map { AnyView($0.environmentObject(self)) }
        self.name = name?.asPathComponent() ?? ""
        nameDidSet()
    }
    
    public convenience init<V: View>(name: String? = nil, _ view: V) {
        self.init(name: name, [AnyView(view)])
    }

    public convenience init<V: View>(name: String? = nil, @ViewBuilder _ view: () -> V) {
        self.init(name: name, [AnyView(view())])
    }

    public convenience init<V1: View, V2: View>(name: String? = nil, _ sidebarView: V1, _ view: V2) {
        self.init(name: name, [AnyView(sidebarView), AnyView(view)])
    }
    
    public convenience init<V1: View, V2: View>(name: String? = nil, @ViewBuilder _ sidebarView: () -> V1, @ViewBuilder _ view: () -> V2) {
        self.init(name: name, [AnyView(sidebarView()), AnyView(view())])
    }
    
    // MARK: Creating view(s)
    
    open func makeViewController(_ view: AnyView) -> PbViewController {
        PbViewController(view)
    }
    
    open override func loadView() {
        super.loadView()
        splitView.delegate = self
        
        var idx = 0
        if views.count > 1 {
            insertSplitViewItem(
                NSSplitViewItem(sidebarWithViewController: makeViewController(views[idx])),
                at: idx
            )
            idx += 1
        }
        for i in idx ..< views.count {
            insertSplitViewItem(
                NSSplitViewItem(viewController: makeViewController(views[i])),
                at: i
            )
        }
        
        restoreState()
    }
    
    // MARK: Utilities
    
    open override func splitViewDidResizeSubviews(_ notification: Notification) {
        saveState()
    }
    
    open func saveState() {
        guard restoreStateDidEnd else { return }
        guard views.count > 1 else { return }
        state = State(
            sidebarFrame: NSStringFromRect(splitViewItems[0].viewController.view.frame),
            isSidebarCollapsed: splitViewItems[0].isCollapsed
        )
    }
    
    open func restoreState() {
        let frame = NSRectFromString(state.sidebarFrame)
        if views.count > 1, !frame.isEmpty {
            DispatchQueue.main.async { [self] in
                splitView.setPosition(frame.width, ofDividerAt: 0)
                if state.isSidebarCollapsed {
                    toggleSidebar(self)
                }
                restoreStateDidEnd = true
            }
        } else {
            restoreStateDidEnd = true
        }
    }
    
    // MARK: Very unimportant code ;)
    
    public required init?(coder: NSCoder) {
        fatalError("PbSplitViewController.init(coder:) has not been implemented.")
    }
}

#endif

