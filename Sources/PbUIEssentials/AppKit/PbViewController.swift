/// Swift PbUIEssentials
/// Copyright (c) Piotr Boguslawski
/// MIT license, see License.md file for details.

#if os(macOS)

import SwiftUI
import PbEssentials

public extension NSViewController {
    var viewWindow: NSWindow? {
        view.window
    }
    
    var topWindow: NSWindow! {
        if let window = viewWindow?.attachedSheet { return window }
        else {
            assert(viewWindow != nil, "This property should not be used unless the view is installed in the window.")
            return viewWindow
        }
    }
}

open class PbViewController: NSViewController, PbObservableObject {
    // MARK: Definitions
    
    open override var title: String? {
        get { super.title }
        set {
            objectWillChange.send()
            super.title = newValue
        }
    }

    // MARK: Initialization
    
    public init<V: View>(name: String? = nil, _ view: V) {
        super.init(nibName: nil, bundle: nil)
        self.view = NSHostingView(rootView: view.environmentObject(self))
    }

    public convenience init<V: View>(name: String? = nil, @ViewBuilder _ view: () -> V) {
        self.init(name: name, view())
    }

    deinit {
        releasePublishers()
    }

    // MARK: Very unimportant code ;)
    
    public required init?(coder: NSCoder) {
        fatalError("PbViewController.init(coder:) has not been implemented.")
    }
}

#endif
